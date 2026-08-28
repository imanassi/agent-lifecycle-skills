# Session Wraps

This folder holds **session wraps**: short, structured records of what happened during a
working session with a coding agent (Claude Code, Codex, Cursor, …).

A wrap captures what `git log` cannot — *why* we did it, *what we decided and rejected*,
and *what the next person or agent needs to know*. The diff already shows what changed; a
wrap explains the reasoning that produced it.

**This file is the single source of truth for the wrap format.** The `/wrap` command runs
the same procedure in every agent (`.agents/skills/wrap/SKILL.md`), and that procedure
reads this file. Change the format here and every agent picks it up.

---

## How to create a wrap

At the end of a working session:

| Agent | Command |
| --- | --- |
| Claude Code, Cursor | `/wrap` |
| Codex CLI | `$wrap` |
| Anything else | "Read `docs/sessions/README.md` and write a wrap for this session." |

Optionally pass a topic: `/wrap payment retry backoff`.

---

## File naming

```
docs/sessions/YYYY-MM-DD-<slug>.md
```

- `YYYY-MM-DD` — the date the session **ended**, local time.
- `<slug>` — 2–5 lowercase hyphenated words describing the work. Not the agent name, not
  "session". Good: `payment-retry-backoff`, `flyway-baseline-fix`. Bad: `session-2`,
  `claude-work`, `updates`.
- If the filename exists, append `-2`, then `-3`.

Never overwrite a wrap. Never edit a previous wrap except to correct a factual error.
Wraps are append-only history — that is what makes them trustworthy. Specs, in
`docs/specs/`, are the mutable half of this pair.

---

## Format

YAML frontmatter, then six fixed sections. Copy [`_TEMPLATE.md`](_TEMPLATE.md).

### Frontmatter

```yaml
---
date: 2026-08-24             # required, YYYY-MM-DD, session end date
topic: Payment retry backoff # required, one short line, sentence case
agent: claude-code           # required, controlled vocabulary below
model: claude-opus-4-5       # required, or "unknown" — see the honesty rule
status: complete             # required: complete | wip | abandoned
spec: docs/specs/payment-retry-backoff.md   # the spec this implements, or null
branch: feature/PAY-412-retry
base_commit: a1b2c3d         # HEAD when the session started, short sha
head_commit: e4f5a6b         # HEAD when the session ended, short sha
build: passing               # passing | failing | not-run
tickets: [PAY-412]           # issue keys, or []
tags: [payments, resilience, spring-retry]
files_changed: 7
---
```

**Controlled vocabulary for `agent`:** `claude-code`, `codex`, `cursor`, `copilot`,
`gemini-cli`, `aider`, `windsurf`, `other`. Lowercase, hyphenated. Keeping it closed is
what makes the folder greppable.

**The honesty rule for `model`:** record the exact identifier only if you actually know it
— from the session banner, `/status`, `/model`, or the configuration the agent was launched
with. Agents frequently do not know which model is serving them, and the serving model can
differ from the configured one or change mid-session. If not certain, write `unknown`.
Never guess a marketing name from memory. A confidently wrong model string silently
poisons every later comparison; an absent one costs nothing.

**`spec:`** points at the spec in `docs/specs/` this session was implementing, if there is
one. This is the join that makes both folders worth keeping: intent → spec → the sessions
that built it → the diff.

`status: wip` means deliberately unfinished and someone is expected to pick it up.
`abandoned` means the approach was tried and dropped — often the most valuable wraps in the
folder, so write them.

### Body sections

All six headings appear in every wrap, in this order, even when the answer is "None."

#### `## Intent`

Two to four sentences. What we set out to do and **why it came up now**. Include the user's
own framing where it was specific, and the constraint that shaped the work — a deadline, a
production incident, an API we do not control.

#### `## Decisions`

The core of the wrap. A numbered list:

```markdown
1. **<the decision, stated as a choice>** — <why, one or two sentences>.
   Rejected: <alternative> (<one-line reason>).
```

Record only decisions **actually made and acted on** in this session, where a reasonable
engineer could have chosen otherwise. Skip what the framework or the existing code decided
for you. Drop the `Rejected:` line when no real alternative was weighed — do not invent one
for symmetry.

**If the session deviated from its spec, say so here, explicitly, as its own entry**, in the
form *"Deviated from the spec: <what> — <why we learned it was wrong>."* That sentence is
the single most valuable line either document will ever contain. Then say whether the spec
was updated to match, or is now stale.

If nothing was decided: `None — execution only against decisions in <spec or other wrap>.`

#### `## Changes`

What changed, grouped by area, paths relative to the repo root. One line per meaningful
change. Do not restate the diff line by line; name the unit of work and its entry point.

```markdown
- `payments/src/main/java/.../RetryPolicy.java` — exponential backoff with jitter.
- Flyway `V27__add_retry_audit.sql` — new table, forward-only, no backfill.
```

Call out on their own lines: **schema migrations, new or changed configuration keys, new
dependencies, changed public API or wire format, deploy-order constraints.** These are what
break other people.

#### `## Verification`

How we know it works. Exact commands and outcomes.

```markdown
- `./mvnw -pl payments verify` — pass (142 tests).
- `RetryPolicyTest#backoffIsJittered` — new, covers the jitter bounds.
- Not covered: behaviour under a partitioned Redis; needs an integration environment.
```

Report only what actually ran and what you actually saw. "The tests should pass" is not a
verification result; neither is "the implementation looks correct." If a command did not run
in this session, it did not run — `build: not-run` and one sentence on why.

Where this session implemented a spec, work through that spec's `## Acceptance criteria` and
`## How to verify` and state each criterion as **met**, **not met**, or **not checked**, with
the command that decided it. A criterion silently omitted reads as met, which is how an
unverified change ships.

If nothing was run and the spec has a verification loop, say so and offer to run it before
writing the wrap. Recording an unverified session honestly is fine; recording it as though it
were verified is not.

#### `## Open questions & risks`

Unresolved things, in priority order. Each names what would resolve it.

#### `## Context for the next agent`

The most valuable section and the hardest to write. Assume a fresh agent with no memory
opens the repo tomorrow. What non-obvious thing would cost it an hour to rediscover?
Load-bearing coupling, a test that is flaky for a known reason, a config key that looks
unused but is not, a place where the obvious refactor is wrong.

Write nothing rather than filler. `None.` is an acceptable and honest answer.

---

## Rules for the agent writing a wrap

1. **Only what happened in this session.** Do not summarize the project or describe code you
   merely read. A short session gets a short wrap.
2. **Never invent.** If you do not know the base commit, the model, or whether the build
   passed, write `unknown` or `not-run`. An empty field is a fact; a plausible wrong one is
   a bug.
3. **Distinguish what the user decided from what you decided.** Where the user overruled or
   corrected you, record it — that is the highest-signal content in the file.
4. **Roughly one page.** Past ~150 lines the session should have been two wraps, or you are
   padding.
5. **Write for a reader who was not there** and does not have the conversation.
6. **Do not commit the wrap.** Write the file and stop. The human decides when it lands.

---

## Reading wraps back

```bash
grep -rl "payments" docs/sessions/                 # everything touching payments
grep -l "^status: abandoned" docs/sessions/*.md    # every approach we dropped
grep -rl "docs/specs/payment-retry" docs/sessions/ # every session on one spec
```

When picking up unfamiliar work: *"Read the three most recent wraps in `docs/sessions/`
before you start."*
