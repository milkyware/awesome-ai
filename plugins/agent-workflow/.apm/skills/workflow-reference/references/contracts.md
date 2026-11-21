# Artefact contracts

Each artefact has one owner. A producer defines the shape; a consumer states the
evidence it requires. No agent restates another agent's contract in full.

## Durable state

Workflow records live in `.agent-workflow/` at the repository root. The directory is
local state: keep it ignored and never commit its contents.

| Artefact           | Owner        | Purpose                                                                 |
| ------------------ | ------------ | ----------------------------------------------------------------------- |
| `design.md`        | Architect    | Objective, requirements, capability map, design, decisions, and slices  |
| `plan.md`          | Orchestrator | Tasks, ordering, dependencies, risk register, verification strategy     |
| `tasks/<ID>.md`    | Orchestrator | Authoritative brief used by the implementer and checked by the reviewer |
| `results/<ID>.md`  | Orchestrator | Implementer outcome and verification evidence                           |
| `verdicts/<ID>.md` | Orchestrator | Independent review findings and recommendation                          |

The brief is written before dispatch and is the review target. Changing it while work
is in flight is a decision, not a silent edit.

## Task brief

ID; requirement IDs; risk tier and the gates it implies; objective stated as the
outcome rather than the activity; context and inputs the implementer cannot infer;
scope and out-of-scope; write scope as files, directories, or globs; acceptance
criteria as checkable statements; relevant files or components; dependencies;
expected verification as single literal check-only commands; the formatting command
and the check that proves it, mandatory at T1 and above; approvals required; and
execution context — mode, isolation, path scope as a boundary, the dispatch base
commit as the text of `git rev-parse HEAD`, and the identity taken before dispatch
and after return.

A brief with a missing field or a placeholder is not ready to dispatch, because the
implementer is instructed to refuse it. A brief that names a writing command under
expected verification is defective: it asks the implementer to change the tree it is
being asked to prove. At T0 the mandatory fields are the ID, requirement IDs,
objective, write scope, acceptance criteria, and expected verification. Formatting is
optional at T0 and mandatory at T1 and above; a `none` where the repository has a
formatter is a missing field, not a decision.

## Execution plan

Slice identity and requirement IDs; objective, scope, non-goals; risk tier and the
gates it triggers, with the reason; tasks with requirements, risk, dependencies,
write scope, and acceptance criteria; tracks when the dispatch carries several slices,
one per slice with disjoint paths; ordering and dependencies; concurrency candidates
with evidence that scopes are disjoint; interfaces and boundaries; risk register;
verification and review strategy; decision records; out of scope.

## Worker result

Usable only when it supplies the outcome, the files changed including untracked ones,
the commands run with their actual results, the status of each acceptance criterion,
the formatting check and its result where the tier requires one, limitations and
risks, and any escalation. If a category is missing the result is incomplete: name
the missing category and set `Needs revision`. A `none` where the repository has a
formatter is missing evidence. The orchestrator does not reconstruct missing
evidence.

## Review verdict

Usable only when it supplies the review target, the identity reviewed, findings with
severity and evidence, the status of each acceptance criterion, what was run and what
it proves, and a recommendation of `accept`, `revise`, or `escalate`. A verdict
without an identity cannot be bound to an artefact.

## Decision record

`D<n>`; question; options; decision; rationale including the constraint that decided
it; reversibility (`easy`, `costly`, `irreversible`); decided by (`user`, `architect`,
`orchestrator`, never inferred); status (`proposed`, `approved`, `superseded`).

Record one when the approach deviates from the plan, a finding is deferred, the risk
tier changes, or integration resolves a conflict. A design decision that outlives the
task belongs to the architect.

## Task lifecycle

States: `Proposed`, `Awaiting approval`, `Ready`, `In progress`, `In review`,
`Needs revision`, `Blocked`, `Failed`, `Complete`. Only the orchestrator transitions
state; an agent claiming completion does not change it.

`Complete` requires all three of criteria met, verification evidence present, and an
integration commit recording the reviewed identity. At T1 and above it also requires
an `accept` verdict. `Blocked` is recoverable when its blocker is resolved; `Failed`
is terminal for that attempt and needs a revised plan.

## Completion states

Keep these distinct in every status update:

- **Claimed complete**: the implementer reports it. Not sufficient.
- **Verified**: the stated checks ran and their results are recorded.
- **Reviewed**: an independent verdict exists against the reviewed identity.
- **Approved**: the user has accepted the integrated outcome.
