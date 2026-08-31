---
name: spec
description: Ask the user for a short brief in their own words, interview them in a few rounds, then write a spec — problem, constraints, approach, contracts, rollout, acceptance criteria, out of scope — into docs/specs/. Stops without implementing. Use ONLY when the user explicitly invokes /spec or $spec, or asks to write a spec. Never trigger this on your own.
---

# Write a spec

Take the user through defining a piece of work, then write it to `docs/specs/` and **stop**.

This procedure is agent-independent. Every agent runs these same steps.

## Step 1 — get the brief

Start by asking what they are trying to achieve. If the invocation already carried
substantial text — `/spec we keep losing captures when Adyen wobbles, want to retry safely` —
that is the brief; go to step 2. Otherwise ask, in roughly these words, and wait:

> Before we get into it: in a few sentences, what are you trying to achieve here, and why
> now? Rough is completely fine — half-formed is what this is for. Paste a ticket or a
> thread if that is easier.

**Expect the brief to be vague, partly wrong, or hard for them to write.** They are usually
writing it *because* the problem is not yet clear to them. If what comes back is one line, or
they say they are not sure, help them get it out. Useful questions here:

- What happened that made this come up now?
- What have you already tried, or ruled out?
- What would "fixed" look like — how would you notice?
- What happens if we do nothing?

Ask as many of these as it takes. This is not the interview; it is getting to a starting
point, and it is a normal part of the command rather than a fallback.

**The one thing you must not do in this step is supply the idea.** Questions that get them to
say what they mean are the job. Offering an approach before they have said their piece is
not — *"sounds like you want exponential backoff with jitter, shall I write that up?"* hands
them an answer they will anchor on, and everything after that measures your idea rather than
theirs. No solutions, no designs, no technology choices until the brief exists.

### Polish it, then get a yes

Raw first thoughts are rarely what anyone wants committed to a repository. Before the brief
goes into the spec, clean it up and show the result back. Do this whether they wrote it in one
go or you drew it out of them; if it was drawn out, also mark it *(elicited in conversation)*.

**The polish is presentational, never substantive.**

Do: fix grammar and spelling; break a wall of text into sentences; cut filler and false
starts; put related thoughts together; trim a rambling aside down to its point.

Do **not**: add a fact, constraint, or number they did not give; resolve an ambiguity they
left open; insert a technical choice or an approach; reorder to imply a priority they did not
state; make it read as more decided than they were.

**Keep the hedges.** "I think", "not sure but", "maybe we should just" — leave them exactly as
they are. They record what was uncertain on day one, and smoothing them into confident prose
is the specific failure this rule exists to prevent. A brief that reads more certain than they
felt is worse than an unpolished one.

Then show it to them and wait:

> Here's your brief cleaned up — I've only tidied the wording, nothing added or resolved.
> Good to freeze this, or would you rather change something?

Never put a brief in the spec they have not seen. If they prefer their raw version, keep it.

Once they agree and you move to step 2, the brief is frozen. It is not edited again — not
tidied further, not corrected, not revised later when the spec changes. Polish it now or not
at all; polishing after the interview means writing what they wish they had said, which is
exactly what the freeze exists to prevent.

## Step 2 — orient

Run these, tolerating failures:

```bash
git branch --show-current
ls -1 docs/specs/
date +%Y-%m-%d
```

Read `docs/specs/README.md` — the authoritative definition of the format, the frontmatter
schema, the naming convention, and what belongs in each section. Read
`docs/specs/_TEMPLATE.md` for the skeleton. Do not reproduce the format from memory.

If the subject clearly matches an existing spec in the listing, read it and ask whether the
user wants to revise that one rather than create a second.

Take a few minutes to understand the relevant part of the codebase before asking anything.
Questions you could have answered by reading the code waste the user's attention, and the
whole value of the interview is spending that attention on the things only they know.

## Step 3 — interview, in at most three rounds

Ask in **batched rounds** — three or four related questions at a time — not one at a time.
Where your agent offers a structured multiple-choice question tool, use it; otherwise ask in
prose, numbered, and tell the user they can answer briefly.

**Anchor every question to the brief.** Ask about what it left out or left ambiguous, never
about something it already settled — re-asking a question the brief answered is the clearest
signal you did not read it. A thin brief simply means round 1 is broader; say so rather than
pretending it told you more than it did. Where you had to infer something the brief did not cover, say so
explicitly rather than quietly assuming it.

**Round 1 is always about the expensive-to-change things:** the contract other systems
depend on, the data model, the rollout constraint, and what success looks like. Never open
with naming, file layout, or code style.

For every acceptance criterion you write down, settle **how it gets checked** — which
command, which test, what has to exist first. Ask about it. A criterion nobody can check is
not a criterion, and finding that out now is cheap; finding it out mid-implementation is not.
Where something genuinely cannot be checked, it goes to `## Open questions` or
`## Out of scope` rather than into the acceptance list as an aspiration.

**Round 2** resolves what round 1's answers opened up.

**Round 3, if needed**, is for the last blocking unknown only.

Stop as soon as you can write every section without guessing — often that is one round. Stop
immediately if the user says "enough, write it."

Four rules govern the interview:

1. **Never invent an answer to a question you did not ask.** Anything unresolved goes to
   `## Open questions`, named as unresolved, with what would settle it. An honestly open
   question is worth more than a plausible fabrication, and a fabrication here propagates
   into the implementation.
2. **Ask what only the user knows.** Business rules, priorities, what already burned them,
   what the deadline actually is. Not what the code can tell you.
3. **Say when a spec is not warranted.** If the interview reveals a couple of hours' work
   with no real forks, say so plainly and suggest skipping the spec and just doing it. The
   answer to "this is too small for a spec" is not "then spec it quickly."
4. **Attribute the decisions.** Where the user made a call that differs from what you would
   have chosen, the spec records their call. Note your reservation in `## Open questions` if
   you have one — do not silently write your own preference instead.

## Step 4 — write the file

Filename `docs/specs/<slug>.md` per the naming rules — named by feature, never by date.
Create `docs/specs/` if it does not exist. `status: draft`, `created` and `updated` both
today.

Every section from the format spec appears. `## Brief` holds the user's own words as a
blockquote, unedited, exactly as frozen at the end of step 1. `## Out of scope` is the section agents most often skip and the one
that saves the most rework — do not omit it.

Where the spec ends up contradicting the brief — the work turned out to be something other
than what they first described — say so in `## Approach`. Do not silently rewrite the brief
to agree with the conclusion.

Write acceptance criteria as things someone else could check, not as implementation notes.
They become the `## Verification` section of the wrap that implements this spec.

`## How to verify` must contain **executable** checks — commands that pass or fail on their
own. An agent cannot audit its own judgement, so "review the code and confirm it looks right"
is worthless there. If a criterion has no runnable check, name the human who checks it by
hand and when; if it has neither, it does not belong in the acceptance list.

## Step 5 — stop

**Do not start implementing. Do not offer to start implementing.** Do not begin editing
source files, scaffolding classes, or writing tests, even if the plan now feels obvious.
`docs/specs/README.md` explains why; the short version is that the interview leaves your own
rejected proposals in context, and implementation goes better from a clean session that
reads only the finished spec.

End the turn with exactly this shape, filled in:

```
Spec written: docs/specs/<slug>.md   (status: draft)

<two or three lines on what it says>

Open questions left unresolved: <count, or none>

To implement, open a fresh session and say:
  Read docs/specs/<slug>.md and implement it. Work against its acceptance criteria,
  running the commands in "How to verify" as you go — do not report done until they
  pass. Ask before deviating from the spec.
```

If the user explicitly says to continue anyway — "and start now" or similar — do it. The
default requires an action to escape; it is not a refusal.
