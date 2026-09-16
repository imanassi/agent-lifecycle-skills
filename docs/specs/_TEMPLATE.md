---
title: <one line>
slug: <matches the filename, lowercase-hyphenated>
status: draft
created: YYYY-MM-DD
updated: YYYY-MM-DD
tickets: []
tags: []
superseded_by: null
---

# <Title>

## Brief

> <The human's own framing, captured before the interview. Allowed to be half-formed.
> Tidied for readability only — nothing added, no ambiguity resolved, hedges left intact —
> and agreed with them before it lands. Frozen once the interview starts: not edited again,
> not corrected, not revised when the spec is.
> Add *(elicited in conversation)* if it was drawn out rather than written in one go.>

## Problem

<What is wrong today and what it costs. Concrete, with evidence where evidence exists.
Do not describe the solution here. Include clickable ticket source links when available.>

## Constraints

- <what is fixed> — <why it binds>.

## Approach

<Components and responsibilities, plus one concrete example of current → proposed behavior.>

**Chose <X> over <Y>** because <reason>.

## Contracts that change

- <API / wire format / event schema> — <before → after>.
- <database schema>
- <new or changed config key> — <default>.
- <new dependency> — <why>.

<If nothing changes: "None.">

## Migration & rollout

<Deploy ordering, backward compatibility during the rolling window, flags, backfills,
rollback. One sentence if there are no rollout concerns.>

## Acceptance criteria

- **AC-1** — <observable behavior; linked ticket requirement where available>.

## How to verify

Use `.agents/skills/tdd/SKILL.md`: write and run acceptance tests first, present scenarios,
expected outcomes, and observed failures, then wait for explicit human approval before
implementation. Implement and refactor with approved tests passing. Changed expectations
require renewed review. Record any explicit waiver; starting implementation is not a waiver.

<For each acceptance ID, name its test scenario and check. "Looks correct" is not verification.>

- `<narrowest command — the tight loop>` — <what it proves, how long it takes>.
- `<full command — before declaring done>`.

<Fixtures, stubs, or seed data the loop needs that do not exist yet.>

<What cannot be checked automatically, who checks it, and when. A criterion with no entry
here and no named owner is decoration — give it a check or move it out of scope.>

## Out of scope

- <not doing> — <why>.

## Open questions

- <question> — <what would resolve it>. <blocks starting | does not block>.

## Jira summary

<Ready-to-paste business summary: current problem and affected people; proposed change and
expected outcome; observable success; material scope limits, dependencies, or open decisions.
Use plain language, normally 100–200 words or fewer. Describe planned work as proposed.
Preserve uncertainty; do not invent benefits or commitments. Omit code paths and test commands.>
