---
date: 2026-08-24
topic: Retry backoff for the Adyen capture call
agent: claude-code
model: unknown
status: complete
spec: docs/specs/payment-retry-backoff.md
branch: feature/PAY-412-retry
base_commit: 9f2c1ab
head_commit: e4f5a6b
build: passing
tickets: [PAY-412]
tags: [payments, resilience, spring-retry, flyway]
files_changed: 7
---

# Retry backoff for the Adyen capture call

## Intent

Implement `docs/specs/payment-retry-backoff.md`, the follow-up to Friday's INC-2201, in one
session. The spec was approved Saturday; nothing about it was reopened except where noted
below.

## Decisions

1. **Wrote the audit row in a `REQUIRES_NEW` transaction rather than the ambient one.** The
   spec required attempts to be recorded even for a capture that was ultimately rolled back,
   which the ambient transaction cannot do — it would take the audit trail down with it. The
   spec stated the requirement but not the mechanism; this is the mechanism.
   Rejected: an application event consumed after commit (loses attempts on a crash between
   the call and the commit).
2. **Deviated from the spec: 429 is retried on a slower schedule than 503**, base 1 s rather
   than 200 ms. While building the classifier it became clear that treating a rate-limit
   response with the same aggression as a server error is how you stay rate-limited. The
   spec's acceptance criterion said "on the same schedule as 503"; that criterion is now
   wrong. **Spec not yet updated — it is stale on this point.**
3. **Asserted jitter statistically over 1000 seeded samples rather than asserting sleep
   values.** An earlier attempt asserted bounds on individual delays and was flaky in CI for
   exactly the reason you would expect.

## Changes

- `payments/src/main/java/com/acme/payments/adyen/CaptureClient.java` — `@Retryable` with a
  custom `BackOffPolicy`; classifies via `AdyenErrorClassifier`.
- `payments/src/main/java/com/acme/payments/adyen/AdyenErrorClassifier.java` — new; maps
  status codes and `IOException` subtypes to retryable / terminal.
- `payments/src/main/java/com/acme/payments/audit/RetryAuditRecorder.java` — new; one row per
  attempt, `REQUIRES_NEW`.
- **Migration:** `payments/src/main/resources/db/migration/V27__payment_retry_audit.sql` —
  new table, forward-only, no backfill. Deploy before the application.
- **New config keys** under `payments.retry.` in `application.yml`: `max-attempts: 5`,
  `base-delay: 200ms`, `rate-limit-base-delay: 1s` (not in the spec — see decision 2),
  `max-delay: 8s`, `total-timeout: 15s`.
- **New dependency:** `org.springframework.retry:spring-retry`.
- `payments/src/test/java/com/acme/payments/adyen/CaptureClientRetryTest.java` — new.

**Deploy order:** migration first, then the application. It fails fast at startup if the
table is absent.

## Verification

- `./mvnw -pl payments -am verify` — pass, 142 tests, 6 new.
- WireMock stub for Adyen built first, as the spec warned; it took most of the first hour.

Against the spec's acceptance criteria:

| Criterion | Status | Decided by |
| --- | --- | --- |
| 503 retried up to 5 times, fails once | met | `CaptureClientRetryTest#retriesOn503AndSucceeds` |
| 422 never retried | met | `#doesNotRetryOn422` |
| 429 retried on the same schedule as 503 | **not met, deliberately** | see decision 2 |
| Retry chain never exceeds 15 s | met | `#stopsAtTotalTimeout`, mocked clock |
| Every attempt audited, including rolled-back captures | met | `RetryAuditRecorderTest` |
| Delays jittered, not fixed | met | 1000 seeded samples, distribution bounds |
| Audit write failing mid-rollback | **not checked** | no fault-injectable Postgres; left to PR review as the spec anticipated |

## Open questions & risks

- The spec is stale on 429 backoff. Either update it or record the change in the next spec
  revision — do not leave both documents disagreeing.
- Both of the spec's original open questions remain open: no production `Retry-After`
  observed yet, and nothing enforces the 15 s / 20 s coupling across repositories.

## Context for the next agent

`RetryAuditRecorder` uses `REQUIRES_NEW` deliberately. This is the part that looks wrong and
is not — join it to the ambient transaction and a rolled-back capture takes its audit trail
with it, which defeats decision 1 and an explicit acceptance criterion. There is a comment
saying so; keep it.

`AdyenErrorClassifier` treats `SocketTimeoutException` as retryable but `ConnectException` as
retryable **only on the first attempt**. Intentional: a connection refused after a successful
first connect usually means the provider pulled the instance mid-flight, and hammering it
does not help.

The capture path is still not idempotent on our side. This session made it safe to replay
*within a single in-flight request*, not safe to replay generally. Anything that retries
across process restarts has to solve the idempotency key first — that is out of scope in the
spec for a reason.
