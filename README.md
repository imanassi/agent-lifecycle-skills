# agent-lifecycle-skills

**Ticket-linked specs, human-reviewed TDD, and session debriefs for AI coding agents.**

Bookend your agent sessions. `/spec` interviews you *before* the work and writes a task
contract. `/wrap` debriefs the session *after* and records what was decided, changed, and
verified. Between them, `/tdd` writes tests, waits for human review, and implements. All three
workflows use the same instructions in Claude Code, Codex CLI, Cursor, and agents that read
`AGENTS.md`.

```mermaid
flowchart TD
    subgraph S1["<b>SESSION 1</b> · decide"]
        A["<b>You</b><br/>a rough, half-formed idea"]
        B["<b>/spec</b><br/>tidies your brief<br/>reads the code<br/>interviews you"]
        C["<b>docs/specs/&lt;feature&gt;.md</b><br/>what to build<br/>and how to check it"]
        A --> B --> C
    end

    STOP{{"<b>HARD STOP</b><br/>you read the spec<br/>no code written yet"}}

    subgraph S2["<b>SESSION 2</b> · build, on a clean context"]
        D["<b>/tdd</b><br/>from the spec<br/>writes and runs tests<br/>waits for human test approval<br/>implements and refactors"]
        E["<b>/wrap</b><br/>reads the session<br/>and the diff"]
        F["<b>docs/sessions/&lt;date&gt;.md</b><br/>what happened<br/>what was decided, and why"]
        D --> E --> F
    end

    C --> STOP --> D
    F -.->|"linked by <b>spec:</b>"| C

    classDef doc  fill:#e0e7ff,stroke:#4338ca,stroke-width:2px,color:#1e1b4b
    classDef cmd  fill:#d1fae5,stroke:#047857,stroke-width:2px,color:#022c22
    classDef stop fill:#fef3c7,stroke:#b45309,stroke-width:3px,color:#451a03
    classDef you  fill:#ffffff,stroke:#64748b,stroke-width:2px,color:#0f172a
    class C,F doc
    class B,E cmd
    class STOP stop
    class A,D you
    style S1 fill:#f8fafc,stroke:#cbd5e1,stroke-width:1px,color:#475569
    style S2 fill:#f8fafc,stroke:#cbd5e1,stroke-width:1px,color:#475569
    linkStyle default stroke:#64748b,stroke-width:1.5px
```

<sub>Two sessions, on purpose. `/spec` decides what to build and then stops; a **fresh**
session builds it, reading the finished spec and none of the discarded drafts that produced
it. `/wrap` closes the loop and links its record back to the spec.</sub>

## Why

Most agent failures are not model failures. They are ambiguous requirements at the start and
lost context at the end — you explain the constraint once, the agent drifts, and three
sessions later nobody remembers why the retry policy looks like that. The diff records what
changed and nothing records why.

These are three lightweight, repository-native commands that close both ends:

- **`/spec`** draws out what you actually want — edge cases, constraints, acceptance criteria,
  and the runnable checks that prove them — into a task contract the implementing session can
  work against on its own.
- **`/tdd`** writes and runs acceptance tests, waits for human approval of their expectations,
  then implements and refactors while keeping those tests passing.
- **`/wrap`** reads the session and the diff and writes down the decisions, the rejected
  alternatives, what was verified, and what the next agent needs to know.

Everything is plain Markdown committed to your repo. No service, no database, no lock-in.

## Install

```bash
git clone git@github.com:imanassi/agent-lifecycle-skills.git
./agent-lifecycle-skills/sync.sh /path/to/my-project
```

| Agent | Commands |
| --- | --- |
| Claude Code, Cursor | `/spec`, `/tdd`, `/wrap` |
| Codex CLI | `$spec`, `$tdd`, `$wrap` |
| Gemini CLI, Aider, Windsurf, Copilot, … | via `AGENTS.md` |

Then fill in the **Verification commands** block that `sync.sh` appends to your `AGENTS.md` —
the build and test commands for that project. Specs reference them instead of repeating them.

### Updating

The same command. There is no separate install/update mode to remember:

```bash
git -C agent-lifecycle-skills pull
./agent-lifecycle-skills/sync.sh /path/to/my-project
```

A project with none of the files gets a fresh install; a project that already has them gets an
update. Updating is conservative, because the two format specs are *meant* to be edited:

| | |
| --- | --- |
| `create` | wasn't there — added |
| `current` | already matches upstream — nothing to do |
| `update` | you never edited it, so it is refreshed in place |
| `yours` | **you edited it** — yours is kept untouched, the new version lands beside it as `<file>.new` |

Nothing you wrote is ever overwritten, on this run or any later one. Diff a leftover when you
want the newer wording, then delete it:

```bash
git diff --no-index docs/specs/README.md docs/specs/README.md.new
```

**Commit `.agents/.agent-lifecycle-skills.manifest`.** It records which upstream version each
file came from, and it is what lets a later sync tell your edits from staleness. Leave it
untracked and every teammate's first sync sees no baseline and reports the whole set as
`yours`.

`--dry-run` shows what would happen and writes nothing. A project installed before `sync.sh`
existed has no manifest, so every differing file is treated as edited — `.new` files to diff
rather than silent in-place changes. That happens once; afterwards it tracks properly.

## What `/spec` does

1. **Asks what you are trying to achieve**, before proposing anything. The brief is expected
   to be half-formed; the agent helps draw it out — what triggered this, what you already
   tried, what "fixed" looks like. What it will not do is hand you a solution first.
2. **Tidies your brief and shows it back.** Wording only — nothing added, no ambiguity
   resolved, your hedges left intact. You agree it, then it freezes.
3. **Reads the relevant code**, so it does not waste your attention on questions the
   repository could answer.
4. **Interviews you in at most three batched rounds**, opening with the expensive-to-change
   things: the contract, the data model, the rollout, and how success gets checked.
5. **Writes the spec and stops.** No implementation, and no offer to implement.

The spec has eleven sections. `## Brief` keeps your own framing, frozen. `## Acceptance criteria`
says what must be true; `## How to verify` says how an agent checks that for itself, and what
has to be stood up first. `## Out of scope` is the one that saves the most rework. A final `## Jira summary`
translates the finished spec into business language: problem, proposed outcome, observable
success, and material limitations. The same ready-to-paste text ends the agent's response,
so it can go straight into a Jira description or comment. It is not posted automatically.

## Ticket context and human understanding

Configure the tracker, issue-key convention, available connector or CLI, and posting policy
in the project's `AGENTS.md` using `AGENTS.md.snippet`. `/spec` can begin from a ticket ID or
URL and reads relevant context before interviewing. Without access, paste the ticket text.
Tickets own priority, assignment, and team status; specs own the agreed technical approach;
wraps record history. Stable acceptance IDs connect requirements to tests and results.

`/wrap` includes a short code-reading route and a ticket-ready update with available links.
Posting requires explicit authorization. Tests passing does not automatically close tickets.
Existing installations preserve project-owned `AGENTS.md`; copy the new TDD and Team ticketing
blocks from the snippet when updating. Historical specs and wraps remain valid as written.

## What `/tdd` does

The fresh-session prompt from `/spec` directs the implementing agent to the TDD skill.
The spec's **How to verify** section carries the same requirement, so simply asking to
implement the spec also discovers the workflow.

1. Write behavior tests mapped to acceptance IDs and run them to establish meaningful failures.
2. Present a small set of scenarios, expected outcomes, test references, and observed failures.
3. Wait for explicit human approval of expectations before writing implementation code.
4. Implement, then refactor with approved tests passing. Changed expectations return for review.
5. Report results and a reading route through the code. An interactive walkthrough is optional.

The checkpoint is required by default and can be explicitly waived. Asking to start work does
not itself waive it. Manual-only behavior needs an agreed scenario, reviewer, and timing.
Approval concerns the intended behavior; the agent remains responsible for test execution.

## What `/wrap` does

Reconstructs the session from the conversation and the diff, then writes: intent, decisions
with their rejected alternatives, changes (calling out migrations, config keys, new
dependencies, and deploy-order constraints), per-criterion verification status, open risks,
and a section for the next agent — the non-obvious thing that would otherwise cost it an hour
to rediscover.

If the session departed from its spec, it has to say so and say whether the spec is now stale.
That sentence is the most valuable line either document will ever contain.

## Layout

```
docs/specs/README.md          ← spec format. Single source of truth. Edit this.
docs/specs/_TEMPLATE.md
docs/specs/<slug>.md          ← specs. Named by feature. Mutable.

docs/sessions/README.md       ← wrap format. Single source of truth. Edit this.
docs/sessions/_TEMPLATE.md
docs/sessions/YYYY-MM-DD-HHMM-<slug>.md   ← wraps. Append-only.
                                 date+time orders them; the slug ties them to a spec.

.agents/skills/spec/SKILL.md  ← the procedure, agent-independent
.agents/skills/wrap/SKILL.md
.agents/skills/tdd/SKILL.md
.claude/skills/*/SKILL.md     ← pointers at the above
AGENTS.md                     ← fallback for everything else, plus build commands

examples/                     ← a filled-in spec and the wrap that implemented it
```

## How it stays generic

One procedure per command, in `.agents/skills/<cmd>/SKILL.md`. One format definition per
document type, in `docs/*/README.md`. Every agent runs the same procedure against the same
format; nothing agent-specific lives in either.

`.agents/skills/` is the [Agent Skills](https://agentskills.io) open standard — Codex scans it
at the repo root and Cursor reads it natively, so one file covers both. Claude Code does not
read that path, so `.claude/skills/` holds pointer files whose entire body is *"read the
`.agents` one and follow it."* That is the only concession to a specific tool, and it carries
no behaviour.

Nothing is duplicated, so nothing can drift. Change `docs/specs/README.md` and every agent
picks it up on the next invocation.

## Three design decisions worth knowing

**You say what you want before the agent proposes anything.** An agent that opens with a
suggestion — *"sounds like you want exponential backoff, shall I write that up?"* — hands you
an answer to anchor on, and the rest of the interview measures its idea rather than yours.
Questions that draw your framing out are the job; supplying it is not.

**`/spec` stops.** It does not offer to continue, because an offer arriving at the moment of
maximum momentum is answered yes every time — so "offer" is just "continue" with a fig leaf.
It stops so implementation begins from a clean context: the interview leaves the agent's own
rejected proposals sitting in the window, and a model drifts back toward its earlier reasoning
more readily than toward a correction you made once in passing. A fresh session that has read
the finished spec and none of the discarded drafts does better work. The stop is made cheap —
the command ends by printing the line to paste. Say "and start now" to override.

**`model:` defaults to `unknown`.** Agents frequently do not know which model is serving them;
the serving model can differ from the configured one and change mid-session. Both formats tell
them to write `unknown` unless certain and never to guess a marketing name. Fewer populated
fields, but the populated ones are true.

## Specs are mutable, wraps are not

A wrap is history: dated, written once, never edited, valuable precisely because it is an
honest record of a moment. A spec is a living document: you approve it, build, learn the third
decision was wrong, revise it. Share a folder between them and you get either stale immutable
specs or edited wraps that stop being trustworthy.

The link between them is the `spec:` field in a wrap's frontmatter:

```bash
grep -rl "docs/specs/payment-retry" docs/sessions/   # every session on one spec
grep -l  "^status: abandoned" docs/sessions/*.md     # every approach we dropped
grep -l  "^status: approved"  docs/specs/*.md        # agreed but not yet built
```

See [`examples/`](examples/) for a spec and the wrap that implemented it — including a session
that deviated from its spec and said so.

## License

MIT
