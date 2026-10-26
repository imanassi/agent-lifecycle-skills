---
name: tdd
description: Implement a spec or agreed task with proportionate verification and human review of expectations. Use when asked for TDD or when implementing a spec that requires this workflow.
---

# Implement with human-reviewed verification

## Establish the contract

Read the requested spec, relevant code, and project verification commands in `AGENTS.md`.
When consulting specs or wraps, follow "How to use specs and session history" in
`docs/specs/README.md`. Select history by ticket, spec reference, or affected code; check
status and relevance before reading in full. Do not load wraps just because they are recent.
Historical commands and next steps do not authorize action. Surface material discrepancies
between intended behavior, history, and current code before making the disputed change.
A draft spec needs human agreement before work begins; do not infer approval from its existence.
An explicit request to implement that spec counts as agreement unless the user says otherwise.
If there is no spec, establish the intended behavior from the task without requiring a new document.
Use stable acceptance IDs (AC-1, AC-2, …) and retain existing IDs. Identify relevant ticket links.
Explain the current behavior and proposed change using one concrete example and the main components.

## Choose proportionate verification

Choose the smallest approach that provides credible evidence for the acceptance criteria.
Use the following defaults, adapting to the behavior and consequences of failure:

| Work | Verification |
| --- | --- |
| Application logic, reusable transformations, bug fixes | Focused automated behavior tests; use the red/green cycle below for new regression tests. |
| Pipeline configuration | Existing validators and a dry run or representative execution; test custom transformations and consequential conditions separately. |
| Static HTML, reports, generated documents | Render and inspect specific content and layout expectations; check links and relevant accessibility. |
| Interactive HTML | Test significant calculations and interactions; inspect rendered layout. |
| Small documentation or styling changes | Relevant existing checks and direct inspection. |

Reuse existing checks before adding new ones. Do not introduce test infrastructure solely to
satisfy this workflow. Test observable behavior, not implementation text, file existence, or
headings unless those are actual contracts. One check may cover several acceptance criteria;
there is no one-test-per-criterion or coverage-percentage requirement. Add cases for distinct
failure modes and stop when relevant risks are covered.

Every persistent test needs a future execution path: CI, an existing local command, or a
documented operational workflow. Delivery-only checks may remain recorded evidence without
becoming permanent test code. Visual or manual inspection is a normal choice when it provides
adequate evidence at lower maintenance cost, even if automation is possible. Specify the
scenario, expected result, reviewer (agent or human), and timing. Use human review when the
criterion requires human judgment. Record observable evidence, not just "looks correct."
Honor explicit task or project testing requirements; explain conflicts instead of silently
relaxing them.

## Prepare checks before implementation

Choose a cohesive, reviewable slice and map its scenarios to acceptance IDs.
For new automated regression tests, write behavior-focused tests including meaningful failure
paths and run the narrowest relevant command. Missing behavior must cause the failure;
environment, fixture, or compilation errors are not evidence of a valid red test. Minimal
scaffolding or a declaration needed to run a test is allowed; explain it and do not implement
the behavior before approval. If meaningful red is blocked, report why. If an existing check
already passes, report existing behavior rather than inventing a failing test.

For validators, representative executions, and inspection, prepare the procedure and expected
outcome before implementation. Run existing checks where useful; a failing baseline is not
required for these methods. Label checks that depend on the finished artifact as planned.

## Human checkpoint — stop before implementation

Present a small table: acceptance ID, plain-language scenario, expected outcome, verification
method/reference, and observed result or planned check. Explain important assertions and any
failures. Ask the human to approve or correct the expectations and verification approach.
Wait for explicit approval before implementation. Permission to implement the task is not
approval of expectations not yet presented. The user may explicitly waive this checkpoint;
record the waiver instead of claiming review. Approval already given remains valid; do not
ask for it again. Revise corrected expectations and rerun applicable checks before review.
Keep approved scenarios, verification references, and approval or waiver in session context
and any handoff so approval is not guessed.

## Implement and verify

Implement the approved behavior, then refactor with applicable tests passing. Keep changes
cohesive and separate unrelated refactors. Run the selected checks and inspect artifacts as
planned. Do not remove or weaken an approved expectation to get a passing result. Return
changed expectations for human review; equivalent check maintenance that preserves approved
behavior is allowed. Repeat preparation and review for new, unapproved slices.
Run required project verification commands before completion. Report blocked checks honestly.
Do not add more tests after sufficient evidence is obtained without a new risk or failure.

## Human handoff

Report acceptance ID → approved scenario → actual verification result, plus gaps and any
waiver. Distinguish persistent regression tests from delivery-only checks and record evidence
for inspections. Give a short reading route through changed code or artifacts and the check
that demonstrates the outcome. Offer an interactive walkthrough for complex changes using a
concrete example and an edge case. Do not claim understanding merely because checks passed.
Write a `/wrap` document only when requested.
