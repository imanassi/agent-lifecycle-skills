# Examples

Two slate documents from a fictional Java project (`com.acme.payments`).

Two files showing the pair in use: a spec, and the session wrap that implemented it.

- `spec-payment-retry-backoff.md` — as it would live at `docs/specs/payment-retry-backoff.md`
- `wrap-2026-08-24-payment-retry-backoff.md` — as it would live at
  `docs/sessions/2026-08-24-payment-retry-backoff.md`

They are kept here rather than in `docs/` so `install.sh` does not copy them into real
projects. Paths *inside* them are repo-root-relative and written as they would be in a real
repository, so the wrap's `spec: docs/specs/payment-retry-backoff.md` will not resolve from
this folder. That is expected.

Worth reading for one thing in particular: the wrap's decision 2 records a **deviation from
the approved spec** — 429 backoff was changed during implementation, the spec's acceptance
criterion is now wrong, and the wrap says so instead of quietly reconciling the two. That
sentence is the reason both documents exist.
