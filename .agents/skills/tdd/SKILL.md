---
name: tdd
description: Implement a spec or agreed task using tests first, human approval of test expectations, then implementation and refactoring. Use when asked for TDD or when implementing a spec that requires this workflow.
---

# Implement with human-reviewed TDD

## Establish the contract

Read the requested spec, relevant code, and project verification commands in `AGENTS.md`.
A draft spec needs human agreement before work begins; do not infer approval from its existence.
An explicit request to implement that spec counts as agreement unless the user says otherwise.
If there is no spec, establish the intended behavior from the task without requiring a new document.
Use stable acceptance IDs (AC-1, AC-2, …) and retain existing IDs. Identify relevant ticket links.
Explain the current behavior and proposed change using one concrete example and the main components.

## Red — tests before implementation

Choose a cohesive, reviewable slice. Write behavior-focused tests mapped to acceptance criteria,
including meaningful failure paths. Prefer public behavior over assertions about implementation
structure. Use existing tests when they already express the required behavior.
Run the narrowest relevant checks and inspect the failures. A missing behavior must cause the
failure; unrelated environment, fixture, or compilation errors are not evidence of a valid red test.
Minimal test scaffolding or a declaration needed to run a test is allowed; do not implement the
behavior before approval. Explain any scaffolding. If a meaningful red result is blocked, report
why rather than claiming one. If a criterion already passes, report it as existing behavior.
For behavior that cannot be automated, specify a concrete manual scenario, expected result,
reviewer, and timing; agree on this exception at the checkpoint.

## Human checkpoint — stop before implementation

Present a small table: acceptance ID, plain-language scenario, expected outcome, test path and
name, and observed result. Include the important assertions and explain why the tests failed.
Ask the human to approve or correct the expectations. Wait for explicit approval before writing
implementation code. Permission to implement the task is not approval of tests not yet presented.
The user may explicitly waive this checkpoint; record that waiver instead of claiming review.
Approval already given for these expectations remains valid; do not ask for it again.
If the human corrects an expectation, revise and rerun the tests, then present the revised set.
Keep the approved scenarios, their test references, and approval or waiver in the session context;
include them in any handoff to another session so approval is not guessed.

## Green and refactor

Implement the approved behavior, then refactor with tests passing. Keep changes cohesive, use
names that explain intent, and comment on non-obvious constraints. Separate unrelated refactors.
Do not remove or weaken an approved expectation to get green. If an expectation needs to change,
explain why and return that change for human review. Equivalent test maintenance is allowed when
it preserves the approved behavior. Repeat red and review for new, unapproved slices.
Run the required verification commands before reporting completion; report blocked checks honestly.

## Human handoff

Report acceptance ID → approved scenario → actual test result, plus gaps and any waiver.
Give a short code-reading route: entry point, execution path, key invariant, and demonstrating test.
Offer an interactive walkthrough for complex changes, tracing a concrete example through the actual
code and inviting the human to reason through an edge case. Do not claim understanding merely
because tests passed. Write a `/wrap` document only when requested.
