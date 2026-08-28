---
name: wrap
description: Write a session wrap — a structured Markdown record of this session's intent, decisions, and changes — into docs/sessions/. Invoke only when the user asks to wrap up.
argument-hint: "[optional topic]"
disable-model-invocation: true
---

Read `.agents/skills/wrap/SKILL.md` and follow it exactly. It is the single agent-independent
definition of this command; this file exists only because Claude Code does not read
`.agents/skills/`.

Any topic hint the user passed is in `$ARGUMENTS`.
