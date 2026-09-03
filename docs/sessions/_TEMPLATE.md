---
ended: "YYYY-MM-DDTHH:MM+ZZZZ"
author: <who ran the session>
topic: <one short line, sentence case>
agent: <claude-code | codex | cursor | copilot | gemini-cli | aider | windsurf | other>
model: <exact identifier, or unknown>
status: <complete | wip | abandoned>
spec: <docs/specs/<slug>.md, or null>
branch: <git branch>
base_commit: <short sha at session start, or unknown>
head_commit: <short sha at session end, or unknown>
build: <passing | failing | not-run>
tickets: []
tags: []
files_changed: 0
---

# <Topic>

## Intent

<2–4 sentences: what we set out to do and why it came up now, including the constraint that
shaped the work.>

## Decisions

1. **<the decision, stated as a choice>** — <why, 1–2 sentences>.
   Rejected: <alternative> (<one-line reason>).

<If the session deviated from its spec, add an entry: "Deviated from the spec: <what> —
<why>." Then say whether the spec was updated or is now stale.>

<If nothing was decided: "None — execution only.">

## Changes

- `<path>` — <what and why, one line>.

<Call out on their own lines: schema migrations, new/changed config keys, new dependencies,
changed public API or wire format, deploy-order constraints.>

## Verification

- `<command>` — <outcome>.
- Not covered: <gap>.

<Where this session implemented a spec, list each of its acceptance criteria as met /
not met / not checked, with the command that decided it. Only what actually ran.>

## Open questions & risks

- <question> — <what would resolve it>.

## Context for the next agent

<The non-obvious thing that would cost a fresh agent an hour to rediscover. "None." is an
acceptable answer — do not pad.>
