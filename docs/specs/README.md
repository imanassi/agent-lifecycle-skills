# Specs

This folder holds **specs**: short documents that fix the intent, the shape, and the
acceptance criteria of a piece of work *before* it is built.

Specs are the mutable half of a pair. `docs/sessions/` is append-only history — what
happened, dated, never edited. A spec is a living document: you approve it, you start
building, you learn the third decision was wrong, you revise it. Keeping the two in
separate folders with different rules is deliberate. Do not merge them.

**This file is the single source of truth for the spec format.** The `/spec` command runs
the same procedure in every agent (`.agents/skills/spec/SKILL.md`), and that procedure
reads this file.

---

## How to create a spec

At the start of a piece of work:

| Agent | Command |
| --- | --- |
| Claude Code, Cursor | `/spec` |
| Codex CLI | `$spec` |
| Anything else | "Read `docs/specs/README.md` and take me through writing a spec." |

**You say what you want first.** The command's opening move is to ask you for a *brief* — a
few sentences, in your own words, on what you are trying to achieve and why. It is expected
to be half-formed. If you cannot get it out in one go, the agent helps you: it asks what
triggered this, what you have already tried, what "fixed" would look like. That is not a
failure of the process, it is the process.

You can supply the brief inline — `/spec we keep losing captures when Adyen wobbles, want
to retry them safely` — or invoke `/spec` bare and work it out in conversation. Either way it
lands in the spec's `## Brief` section and is frozen there.

Then the agent interviews you in **at most three short rounds**, writes the spec, and
**stops**. It does not start implementing. See [The brief](#the-brief),
[The interview](#the-interview), and [Why it stops](#why-it-stops).

---

## File naming

```
docs/specs/<slug>.md
```

Named by **feature, not date** — a spec is revised in place, so a date in the filename would
be a lie within a week. `<slug>` is 2–5 lowercase hyphenated words: `payment-retry-backoff`,
`flyway-baseline-repair`.

If a spec is replaced rather than revised, set the old one's `status: superseded` and
`superseded_by:`, and keep it. Dropped approaches are worth reading.

---

## Format

YAML frontmatter, then ten fixed sections. Copy [`_TEMPLATE.md`](_TEMPLATE.md).

### Frontmatter

```yaml
---
title: Retry backoff for the Adyen capture call   # required, one line
slug: payment-retry-backoff                       # required, matches the filename
status: draft            # draft | approved | implemented | superseded
created: 2026-08-22      # date the spec was first written
updated: 2026-08-24      # date of the last substantive revision
tickets: [PAY-412]
tags: [payments, resilience]
superseded_by: null      # docs/specs/<slug>.md when status is superseded
---
```

`status` is the whole lifecycle:

- **draft** — written, not yet agreed. Do not build from it.
- **approved** — agreed. This is what gets implemented.
- **implemented** — built and merged. Kept as the record of intent. Wraps referencing it
  stay valid.
- **superseded** — replaced by another spec. Keep the file; set `superseded_by`.

Whoever moves a spec to `approved` is asserting they read it. That is the entire point of
the status field, and the entire point of the command stopping.

### Body sections

All ten headings appear in every spec, in this order.

#### `## Brief`

The human's own framing of what they want, as a blockquote, captured before the interview
proper begins.

**It is allowed to be half-formed, vague, or partly wrong.** That is what a starting point
looks like. Do not hold the spec hostage to a good brief, and do not improve it on the
human's behalf.

Freeze it anyway. Once the interview starts, the brief is not edited again — not tidied, not
corrected, not revised when the spec is. Its value is precisely that it is naive: six months
on, `## Problem` is the polished consensus and `## Brief` is where the thinking started. When
those two have drifted a long way apart, that gap is the most interesting thing in the file.

```markdown
> We keep losing captures whenever Adyen wobbles. Friday cost us ~340 payments and a pile
> of support tickets. I want retries on that path but I'm nervous because capture isn't
> idempotent on our side. Cannot touch the checkout timeout.
```

Two or three sentences is plenty. If it was thin, leave it thin — do not pad it to look
considered. Where the spec later contradicts the brief, say so in `## Approach` rather than
quietly editing the brief to agree.

If the brief was drawn out in conversation rather than written in one go, the agent drafts it
back in the human's own words, gets it confirmed, and marks it — a trailing
*(elicited in conversation)* is enough. Worth knowing later whether the naivety was the
human's or partly the agent's.

#### `## Problem`

What is wrong today and what it costs. Concrete, with evidence where evidence exists — an
incident number, an error rate, a support volume, a benchmark. If the problem cannot be
stated without hedging, the spec is premature.

Do not describe the solution here.

#### `## Constraints`

What is fixed and not up for negotiation in this work: APIs we do not control, a database we
cannot migrate off, a deadline, a compatibility window, a team convention. Each with one
line on why it binds.

Constraints are what make a spec worth writing. A spec with no constraints section is
usually a wish list.

#### `## Approach`

The chosen approach, in a few paragraphs, at the level of components and their
responsibilities — not code. Then, for each significant fork:

```markdown
**Chose <X> over <Y>** because <reason>.
```

Two or three of these. If there were no forks, the work probably does not need a spec.

#### `## Contracts that change`

The blast radius. Everything here is a thing another person or system can trip over:

- Public API, wire format, or event schema changes — with before and after.
- Database schema changes.
- New or changed configuration keys, with defaults.
- New dependencies.

If nothing changes, write `None.` — that is a meaningful and reassuring statement.

#### `## Migration & rollout`

How this reaches production without breaking anything mid-deploy. Deploy ordering, whether
the change is backward compatible during the rolling window, feature flags, backfills, and
how to roll back. For a change with no rollout concerns, one sentence saying so.

#### `## Acceptance criteria`

**The section that carries the weight.** How we will know it works, written so that someone
who did not write the spec could check each item. Prefer observable behaviour over
implementation:

```markdown
- A capture that receives a 503 is retried up to 5 times and then fails the payment once.
- A capture that receives a 422 is never retried.
- Total time in the retry chain never exceeds 15s.
- Every attempt appears in `payment_retry_audit`, including attempts that failed.
```

These become the `## Verification` section of the wrap that implements this spec. Write them
as things you could hand to a test.

#### `## How to verify`

Acceptance criteria say *what* must be true. This section says **how an agent checks that for
itself, while it works**, without asking anyone. It is the difference between a target and a
feedback loop.

An agent cannot meaningfully audit its own judgement — ask one whether it implemented
something correctly and it will say yes. Self-checking only means something when the check is
**external to that judgement**: a command that exits non-zero, a test that fails, a query that
returns the wrong row. So write executable things. *"Review the code and confirm it looks
right"* is not verification and does not belong here.

Cover three things.

**The loop** — the exact commands to run after each change, narrowest first, so the agent
gets a fast signal rather than a ten-minute one:

```markdown
- `./mvnw -pl payments test -Dtest=CaptureClientRetryTest` — tight loop, ~15s.
- `./mvnw -pl payments -am verify` — before declaring done.
```

Project-wide commands — how to build, how to run a single test, how to start the app — belong
in `AGENTS.md` once, not copied into every spec. Name them here only where this change needs
something unusual.

**What has to be stood up** — fixtures, stubs, seed data, a fake provider: anything the loop
needs that does not exist yet. This is where implementation sessions actually lose their time,
and the spec is where you get to notice it in advance:

```markdown
- Adyen 429s cannot be produced from the sandbox. Needs a WireMock stub; none exists yet.
```

**What cannot be checked automatically, and who checks it.** Be specific:

```markdown
- Behaviour against a partitioned database — no fault-injectable environment. Manual, in
  staging, before release. Owner: whoever runs the release.
```

If an acceptance criterion has no entry here and no named manual owner, it is decoration.
Either give it a check or move it to `## Out of scope`.

#### `## Out of scope`

Explicitly not doing, with one line each on why. **Do not skip this section.** It is the
highest-leverage part of the document: agents and people both expand scope helpfully unless
told not to, and "we deliberately did not do X" is impossible to reconstruct later.

#### `## Open questions`

Everything still unknown when the spec was written, each with what would resolve it and
whether it blocks starting.

An open question left honestly open is worth more than an answer the agent invented. If the
interview did not settle something, it belongs here, not filled in.

---

## The brief

Before the interview, the agent asks what you are trying to achieve and why. It then reads
the relevant code, and only afterwards starts the interview proper.

The ordering is the point. An agent that opens cold has to ask generic questions, because it
does not yet know what you care about, and generic questions get generic answers. With your
framing in hand it can ask about what your framing *left out*, which is where the useful
disagreement lives.

But a brief is a first draft of an idea, not a submission. Most of the time you are writing
it *because* you do not fully understand the problem yet. So the agent is expected to help
you produce one — asking what triggered this, what you already tried, what "fixed" looks
like, what would happen if you did nothing. Those questions are how a vague itch becomes
something writable.

The line that matters is not questions versus no questions. It is this:

- **Draw the brief out; do not supply it.** Questions that get you to say what you mean are
  the job. Proposing an approach before you have said your piece is not — *"sounds like you
  want exponential backoff with jitter, shall I write that up?"* hands you an answer you will
  then anchor on, and the rest of the interview measures the agent's idea rather than yours.
  No solutions, no designs, no technology choices until the brief exists.
- **Expect it to be half-formed.** A one-line brief is a normal starting point, not a
  degraded one. Work with what is there and ask broader round-one questions.
- **Draft it back if it was elicited.** When the brief emerged from conversation, the agent
  writes it up in your words, shows it to you, and marks it *(elicited in conversation)*.
  It never writes a brief you have not seen.
- **Freeze it once the interview starts.** From that point it is a record, not a working
  document.
- **Say what was inferred.** Where the agent fills a gap the brief left, that inference is
  flagged in the interview or lands in `## Open questions` — never silently.

## The interview

After the brief, `/spec` asks questions in **at most three rounds**, batching related
questions together rather than asking one at a time. It stops early once it can write every section without
guessing. You can end it at any point by saying "enough, write it."

The rules the agent follows:

1. **Never invent an answer to a question it did not ask.** Anything unresolved goes to
   `## Open questions`, named as unresolved.
2. **Ask about the expensive-to-change things first** — the contract, the data model, the
   rollout — not naming or file layout.
3. **Say when a spec is not warranted.** If the interview reveals a couple of hours' work
   with no real forks, the agent says so and suggests skipping the spec rather than
   producing ceremony. The answer to "too small for a spec" is not "spec it quickly."
4. **Record what you decided as yours.** Where the human made a call during the interview,
   the spec reflects that call, not the agent's preference.
5. **Ask what the brief left out, not what it already said.** Re-asking something the brief
   answered is the clearest sign the agent did not read it.
6. **For every acceptance criterion, establish how it gets checked** — which command, which
   test, what has to be stood up first. A criterion nobody can check is not a criterion.
   Where there is no way to check something, it goes to `## Open questions` or
   `## Out of scope`, not into the acceptance list as an aspiration.

---

## Why it stops

`/spec` writes the file and stops. It does not offer to start implementing, and that is a
design decision, not an oversight.

An offer to continue is not a neutral middle ground — asked at the moment of maximum
momentum by an agent that just spent ten minutes helping you, the answer is always yes. So
the real choice is stop-by-default or continue-by-default, and stopping wins on two counts:

**The interview is bad context for implementation.** During it the agent proposed approaches
you rejected. They remain in the window as its own prior output, and a model drifts back
toward its own earlier reasoning more readily than toward a correction made once in passing.
A fresh session that reads only the finished spec has no such pull.

**The costs are asymmetric.** Stopping unnecessarily costs seconds. Continuing on a spec you
would have caught an error in costs the implementation — and turns the review into a review
of a fait accompli, where sunk cost quietly converts "this is wrong" into "close enough."

So the stop is made cheap rather than ceremonial: the command ends by printing the exact
line to paste into a fresh session. You can always override by saying "and start now." The
point is that the default requires an action to escape.

---

## Reading specs back

```bash
grep -l "^status: approved" docs/specs/*.md        # what is agreed but not built
grep -l "^status: superseded" docs/specs/*.md      # approaches we replaced
grep -rl "docs/specs/payment-retry" docs/sessions/ # every session on one spec
```
