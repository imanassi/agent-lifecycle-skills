---
name: spec
description: Interview the user in a few short rounds, then write a spec into docs/specs/ and stop without implementing. Invoke only when the user asks for a spec.
argument-hint: "[optional subject]"
disable-model-invocation: true
---

Read `.agents/skills/spec/SKILL.md` and follow it exactly. It is the single agent-independent
definition of this command; this file exists only because Claude Code does not read
`.agents/skills/`.

Any subject the user passed is in `$ARGUMENTS`.

Where that procedure says to batch the interview questions, use the `AskUserQuestion` tool.
Everything else, including the hard stop at the end, is unchanged.
