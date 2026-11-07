# GitHub issue description template

Structure for a GitHub issue that can be understood and delivered without the original
conversation. Use the standard structure for stories, tasks and engineering bugs, then
apply the adaptation for the selected type.

Prefer `should` for requirements. Keep acceptance criteria independently verifiable
and separate from implementation notes. Do not invent file paths, endpoint names,
log messages, retries or other specifics. Retain links and engineering details
supplied by the user.

## Standard structure

```markdown
## Background / Context

{Why the work is needed, affected systems and useful references}

## Problem

{Current behaviour, its effects, and impact}

## Proposed Change

- {Desired change or intended outcome}

## Acceptance Criteria

- [ ] {Observable, testable outcome}

## Technical Notes

{Known implementation constraints, integrations, file paths, APIs, logging, edge cases and dependencies; omit unsupported placeholders}

## Out of Scope

{Explicit exclusions, if known}
```

## Type adaptations

Adapt rather than force sections that do not apply:

- **Bug:** replace Problem with expected versus actual behaviour, add numbered
  reproduction steps and the environment details supplied by the user, and state the
  impact. Acceptance criteria cover the corrected behaviour and regression risk.
  Attach screenshots or logs the user provided; do not describe evidence that was not
  supplied.
- **Story:** keep the standard structure. Background describes the user need, Proposed
  Change describes observable behaviour rather than implementation, and each
  acceptance criterion is a checkable statement.
- **Feature:** describe the capability and the set of stories it implies. Acceptance
  criteria state the outcome for the capability; add a task list of the expected
  stories when the split is already known.
- **Task:** keep the standard structure. Technical Notes may carry the deliverable when
  the work has no user-facing behaviour.
- **Spike:** replace Proposed Change with the question under investigation, the
  time-box if supplied, and the expected outputs. Acceptance criteria become exit
  criteria: the decision to make and the evidence required. Do not propose a solution
  in advance.
- **Epic:** focus on objective, outcomes, boundaries and the sub-issues it will
  contain. Use a task list of sub-issues, and do not require implementation-level
  acceptance criteria or a size label.
- **Sub-issue:** describe the bounded deliverable and its parent context. Do not repeat
  the parent's scope.

## Title conventions

- State the change or the defect, not the activity: `Reject duplicate SKUs in the import validator`, not `Work on the import validator`.
- Do not repeat the type or priority in the title; the labels carry those values.
- No trailing period. No emoji. Keep titles specific enough to be understood in a list
  without surrounding context.

## Worked example

```markdown
## Background / Context

The bulk import accepts a CSV containing duplicate SKUs. Only the last row survives,
so earlier rows are silently discarded and the operator sees a success response.

## Expected Behaviour

The import rejects the file and reports each duplicated SKU.

## Actual Behaviour

The import succeeds, keeps the last occurrence of each SKU, and reports all rows as
imported.

## Steps to Reproduce

1. Import a CSV containing two rows with the same SKU.
2. Check the imported records.

## Impact

Operators cannot tell that data was dropped, so stock levels diverge from the source
file.

## Acceptance Criteria

- [ ] An import containing duplicate SKUs fails with a validation error naming each duplicated SKU
- [ ] An import containing unique SKUs still succeeds
- [ ] No partial write is committed when validation fails
```
