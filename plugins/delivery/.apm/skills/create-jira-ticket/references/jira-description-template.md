# Jira ticket description template

Structure for a Jira issue description that can be understood and delivered without
the original conversation. Use the standard structure for Stories, Tasks and
engineering Bugs, then apply the adaptation for the selected issue type.

Prefer `should` for requirements. Keep acceptance criteria independently verifiable
and separate from implementation notes. Do not invent file paths, endpoint names,
logging requirements, retries or other specifics. Retain links and engineering
details supplied by the user.

## Standard structure

```markdown
## Background / Context

{Why the work is needed, affected systems and useful references}

## Problem

{Current behaviour, its effects, and impact}

## Proposed Change

- {Desired change or intended outcome}

## Acceptance Criteria

- {Observable, testable outcome}

## Technical Notes

{Known implementation constraints, integrations, file paths, APIs, logging, edge cases and dependencies; omit unsupported placeholders}

## Out of Scope

{Explicit exclusions, if known}
```

## Issue-type adaptations

Adapt rather than force sections that do not apply:

- **Bug:** include actual versus expected behaviour, reproduction steps and impact
  when known; make acceptance criteria cover the corrected behaviour and regression
  risk.
- **Spike:** define the question, time-box if specified, expected investigation
  outputs and decision/exit criteria; do not invent a solution.
- **Epic:** focus on objective, scope, outcomes, boundaries and dependent work; do
  not require implementation-level acceptance criteria.
- **Sub-task:** describe the bounded deliverable and its parent context.

Omit empty sections unless the missing content must be clarified for delivery.
