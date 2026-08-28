---
name: wrap
description: Write a session wrap — a structured Markdown record of this session's intent, decisions, and changes — into docs/sessions/. Use ONLY when the user explicitly invokes /wrap or $wrap, or asks in so many words to wrap up or summarize the session. Never trigger this on your own.
---

# Wrap this session

Write a session wrap for the work we just did. If the invocation carried a topic hint, use
it; otherwise infer the topic from the session.

This procedure is agent-independent. Every agent runs these same steps.

## Step 1 — gather repository context

Run these, tolerating failures:

```bash
date +%Y-%m-%d
git branch --show-current
git rev-parse --short HEAD
git status --short
git diff --stat HEAD
git log --oneline -15
ls -1 docs/sessions/
ls -1 docs/specs/
```

## Step 2 — read the format spec

Read `docs/sessions/README.md`. It is the authoritative definition of the format, the
frontmatter schema, the file-naming convention, and what belongs in each section. Read
`docs/sessions/_TEMPLATE.md` for the skeleton. Follow them exactly.

Do not reproduce the format from memory — the spec is versioned in the repo and may have
changed since this file was written.

## Step 3 — determine the frontmatter

- `base_commit` — the commit HEAD pointed at when this session began. If commits were made
  during the session, it is the parent of the first of them. If you cannot determine it,
  write `unknown`. Do not guess.
- `files_changed` — from the diff stat, including uncommitted work.
- `build` — `passing` or `failing` only if a build or test command actually ran in this
  session and you saw its result. Otherwise `not-run`.
- `agent` — the value from the spec's controlled vocabulary matching the agent you are.
- `model` — the model serving this session, only if you actually know it, from the session
  banner or the configuration you were launched with. If you are not certain, write
  `unknown`. Never guess a marketing name from memory.
- `spec` — if this session implemented a spec in `docs/specs/`, its path. Check the listing
  from step 1 and the conversation. Otherwise `null`.

## Step 4 — reconstruct the session

Write from the conversation, not from the diff alone. Intent and decisions live in what was
said — especially wherever the user corrected you, overruled a suggestion, or chose between
options you offered. Those moments are the highest-value content in the wrap and they are
invisible in the diff.

If the session was implementing a spec and departed from it, record that departure and why,
per the format spec. Do not quietly reconcile the two.

## Step 5 — write the file

Choose the filename per the spec's naming rules, checking the step 1 listing for collisions.
Create `docs/sessions/` if it does not exist.

Do not stage or commit anything. Report the path you wrote and, in two or three lines, what
you recorded, so the user can correct you before it lands.

If the session produced no meaningful work — no changes, no decisions — say so and ask
whether to write a wrap anyway, rather than manufacturing content to fill the sections.
