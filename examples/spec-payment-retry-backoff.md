---
title: Retry backoff for the Adyen capture call
slug: payment-retry-backoff
status: implemented
created: 2026-08-22
updated: 2026-08-24
tickets: [PAY-412]
tags: [payments, resilience]
superseded_by: null
---

# Retry backoff for the Adyen capture call

## Brief

> We keep losing captures whenever Adyen wobbles. Friday was the worst one — a couple of
> minutes of 503s and we dropped ~340 payments, most of which would have gone through on a
> second attempt. I want retries on that path. The thing making me nervous is that capture
> isn't idempotent on our side, so I don't want us double-charging anyone to fix a
> reliability problem. Also we can't touch the checkout timeout, that's another team.

## Problem

INC-2201 (Friday 2026-08-21): Adyen was degraded for roughly 90 seconds and returned 503s.
We have no retry on the capture path, so all 340 captures in that window became failed
payments — each one a customer-visible error and, for about 60 of them, a support ticket.
Adyen's own status page showed the degradation resolving in under two minutes.

The capture call is the only unretried outbound call left on the payment path; authorisation
and refund both already retry.

## Constraints

- **Capture is not idempotent on our side.** The idempotency key belongs to Adyen and is
  minted per request. Any retry has to reuse the same key, which means it has to happen
  inside the request that owns it.
- **The checkout API times us out at 20 s.** That budget is set in another repository and we
  are not changing it in this work.
- **We cannot reproduce Adyen 429s.** The sandbox never returns them, so anything we build
  for rate limiting is designed blind.
- Java 21 / Spring Boot 3.4, Postgres, Flyway. Team convention is forward-only migrations.

## Approach

Retry inside the application, in `CaptureClient`, using Spring Retry. A classifier maps the
provider's response to retryable or terminal; a backoff policy computes the delay; a recorder
writes one row per attempt to a new audit table.

Backoff is exponential with full jitter — 200 ms base, 8 s cap, 5 attempts — under an overall
15 s wall-clock ceiling that sits inside the checkout API's 20 s timeout.

**Chose application-level retry over a gateway (Envoy) retry policy** because the retry must
reuse the idempotency key from `PaymentAttempt`, which the gateway cannot see. A gateway
retry would replay the request without it and risk double captures.

**Chose full jitter over equal jitter** because the incident showed a clean thundering-herd
signature — all clients retrying in lockstep — and full jitter is what Adyen's integration
guidance recommends.

**Chose a database audit table over structured logging** because during the incident we could
not answer "how many times did we actually call them?" from logs: production log level is
ERROR and the attempts would have been WARN.

## Contracts that change

- **Database:** new table `payment_retry_audit` (attempt_id, payment_id, attempt_no,
  status_code, error, started_at, duration_ms). Forward-only, no backfill.
- **Config:** new keys under `payments.retry.` — `max-attempts: 5`, `base-delay: 200ms`,
  `max-delay: 8s`, `total-timeout: 15s`. Defaults ship in `application.yml`, so no
  environment change is needed to deploy.
- **Dependency:** `org.springframework.retry:spring-retry`. Already a transitive dependency
  of `spring-boot-starter-batch` elsewhere in the reactor, so no new licence review.
- **Public API:** unchanged. Callers see the same success and failure shapes; they just see
  fewer failures.

## Migration & rollout

Migration deploys first, application second. The application fails fast at startup if the
table is absent, so do not deploy it against an un-migrated database. The migration is
additive and safe to apply ahead of time with no application change.

No feature flag. Rollback is a normal application rollback; the table can stay.

## Acceptance criteria

- A capture receiving 503 is retried up to 5 times, then fails the payment exactly once.
- A capture receiving 422 is never retried.
- A capture receiving 429 is retried on the same schedule as 503.
- Total elapsed time inside the retry chain never exceeds 15 s, including the final failure.
- Every attempt appears in `payment_retry_audit`, including attempts that failed and
  including attempts belonging to a capture that was ultimately rolled back.
- Delays between attempts are jittered, not fixed — verifiable statistically over repeated
  runs rather than by asserting exact sleep values.

## How to verify

- `./mvnw -pl payments test -Dtest=CaptureClientRetryTest` — tight loop while iterating, ~15 s.
- `./mvnw -pl payments -am verify` — before reporting done. ~4 min.
- Jitter is checked statistically over 1000 seeded samples, asserting the distribution's
  bounds. Do **not** assert individual sleep durations — an earlier attempt did and was flaky
  in CI.
- The 15 s ceiling is asserted with a mocked clock, not by actually sleeping.

**Needs standing up first:**

- A WireMock stub for Adyen returning 503 / 429 / 422 on demand. Does not exist yet; the
  sandbox cannot produce 429 at all. Budget an hour for this before anything else works.
- `payment_retry_audit` must exist locally — run Flyway before the tests.

**Cannot be checked automatically:**

- Failure of the audit write itself while the outer capture is rolling back. Needs a
  fault-injectable Postgres, which we do not have. Manual review of the `REQUIRES_NEW`
  boundary at PR time. Owner: reviewer.
- Real Adyen 429 behaviour, including whether it sends `Retry-After`. Only observable in
  production during a degraded period. Owner: whoever is on call next time it happens.

## Out of scope

- **Retrying across process restarts** (an outbox or a scheduled sweeper). It needs an
  idempotency key we own, which we do not have. Separate piece of work.
- **The authorisation and refund paths.** They already retry, on a different policy. Unifying
  the three is worth doing but not under an incident follow-up.
- **Honouring `Retry-After`.** We have never seen one from Adyen. See open questions.
- **Alerting on retry volume.** Wants a dashboard we do not have yet.

## Open questions

- Does Adyen send `Retry-After` on 429 in production? The sandbox does not. If it does, our
  backoff is ignoring it. Resolved by grepping gateway logs after the next degraded period.
  Does not block starting.
- `total-timeout: 15s` is coupled to the checkout API's 20 s timeout, but the two live in
  different repositories with nothing enforcing the relationship. Resolved by a contract test
  or a shared config source; neither exists. Does not block starting.
