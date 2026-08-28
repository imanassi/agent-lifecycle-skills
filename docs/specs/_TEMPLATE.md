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

> <The human's own framing, captured before the interview. Allowed to be half-formed. Frozen
> once the interview starts: not tidied, not corrected, not revised when the spec is.
> Add *(elicited in conversation)* if it was drawn out rather than written in one go.>

## Problem

<What is wrong today and what it costs. Concrete, with evidence where evidence exists.
Do not describe the solution here.>

## Constraints

- <what is fixed> — <why it binds>.

## Approach

<A few paragraphs at the level of components and responsibilities, not code.>

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

- <observable behaviour someone else could check>.

## How to verify

<Executable checks only. "Looks correct" is not verification.>

- `<narrowest command — the tight loop>` — <what it proves, how long it takes>.
- `<full command — before declaring done>`.

<Fixtures, stubs, or seed data the loop needs that do not exist yet.>

<What cannot be checked automatically, who checks it, and when. A criterion with no entry
here and no named owner is decoration — give it a check or move it out of scope.>

## Out of scope

- <not doing> — <why>.

## Open questions

- <question> — <what would resolve it>. <blocks starting | does not block>.
