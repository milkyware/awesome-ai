# Workflow reference

This reference describes the shared workflow independently of the agent harness.
The harness determines how agents are selected, delegated, and constrained; see
the [harness support notes](../README.md#harness-support) before relying on a
runtime-specific behaviour.

## Identifiers

| Format        | Meaning                                                       | Example  |
| ------------- | ------------------------------------------------------------- | -------- |
| `S<number>`   | Slice identifier                                              | `S1`     |
| `T<number>`   | Task identifier                                               | `T1`     |
| `FR-<number>` | Functional requirement                                        | `FR-001` |
| `SC-<number>` | Success criterion                                             | `SC-001` |
| `D<number>`   | Decision record                                               | `D1`     |
| `R<number>`   | Risk register entry                                           | `R1`     |
| `T0`–`T3`     | Risk tier, not a task identifier                              | `T2`     |
| `C<number>`   | Definition pending confirmation from the source documentation | —        |

Task IDs and risk tiers currently share the `T<number>` notation. Always label
the field as **Task ID** or **Risk tier** so the meaning is clear, especially
when a value such as `T1` could refer to either.

## Risk tiers and gates

The architect classifies the objective; the orchestrator applies the relevant
gates to the work. When two tiers are plausible, use the higher tier and record
why.

| Tier | Typical work                                                                                           | Plan                                     | Design review | Task review  | Integration review and approval                      |
| ---- | ------------------------------------------------------------------------------------------------------ | ---------------------------------------- | ------------- | ------------ | ---------------------------------------------------- |
| T0   | Documentation, comments, formatting, or test-only changes with no behaviour impact                     | Short brief; no full plan or plan review | Not required  | Not required | Not required                                         |
| T1   | Behaviour change within one module, covered by existing tests                                          | Full plan; no plan review                | Optional      | Required     | Not required                                         |
| T2   | Public contract, data shape, CI or release configuration, security, dependencies, or several modules   | Full plan and review                     | Required      | Required     | Required                                             |
| T3   | History rewrite, deletion, migration, lockfile-changing dependency upgrade, or other irreversible work | Full plan and review                     | Required      | Required     | Required; irreversible actions approved individually |

Slice approval is required at every tier before the orchestrator starts the
slice. At T1 and above, the user also approves the design before implementation.
T0 uses a short objective and brief rather than a full design and plan. An
irreversible action requires separate, explicit approval immediately before it,
even when it appears in an approved slice.

## Workflow sequence

1. The architect establishes the objective, constraints, requirements, and
   definition of done. It checks the capabilities actually available in the
   repository and records a design at the level appropriate to the risk.
2. The architect requests independent design review at T2 and above, presents
   the design and first slice to the user, and waits for slice approval.
3. The orchestrator plans the approved slice as bounded tasks, each with a
   requirement, write scope, acceptance criteria, and expected verification.
4. The implementer performs each source change within its task scope and reports
   the checks it actually ran.
5. The orchestrator verifies the evidence, obtains independent review at T1 and
   above, and integrates accepted work.
6. The orchestrator returns a slice report. The architect decides whether the
   design still holds, needs revision, or is ready for another approved slice.

The architect owns design and user-facing approvals. The orchestrator owns the
execution lifecycle for an approved slice. The researcher investigates and
returns evidence; the implementer changes the repository; the reviewer
independently assesses the design, plan, task, or integrated result as requested.

## Durable workflow state

Workflow records live in `.agent-workflow/` at the repository root. This is
local state, not a deliverable; keep the directory ignored and do not commit its
contents.

| Artefact           | Owner        | Purpose                                                                 |
| ------------------ | ------------ | ----------------------------------------------------------------------- |
| `design.md`        | Architect    | Objective, requirements, capability map, design, decisions, and slices  |
| `plan.md`          | Orchestrator | Tasks, ordering, dependencies, risk register, and verification strategy |
| `tasks/<ID>.md`    | Orchestrator | Authoritative brief used by the implementer and reviewer                |
| `results/<ID>.md`  | Orchestrator | Implementer outcome and verification evidence                           |
| `verdicts/<ID>.md` | Orchestrator | Independent review findings and recommendation                          |

Each artefact has one owner. A task brief is written before dispatch and is the
review target; changing it while work is in flight is a decision, not a silent
edit. Record decisions when the approach changes, a finding is deferred, the
risk tier changes, or integration resolves a conflict. Use an ADR for an
architectural decision that outlives the objective.

A task brief records its task and requirement IDs, risk tier, objective, inputs,
write scope, acceptance criteria, dependencies, expected check-only verification,
and any required approvals. A T0 short brief still names the task and
requirements, objective, write scope, acceptance criteria, and expected
verification; other fields may be omitted when they do not apply.

## Task lifecycle

Task states are `Proposed`, `Awaiting approval`, `Ready`, `In progress`, `In
review`, `Needs revision`, `Blocked`, `Failed`, and `Complete`. The orchestrator
owns state transitions. `Blocked` can resume when its blocker is resolved;
`Failed` ends that attempt and rework requires a revised plan.

## Task completion and verification

Keep these states distinct:

- **Claimed complete**: the implementer reports completion. This is not
  sufficient evidence.
- **Verified**: the stated checks have run and their results are recorded.
- **Reviewed**: an independent verdict is recorded against the reviewed change.
- **Approved**: the user has accepted the integrated outcome.

A task is complete when its acceptance criteria are met, verification evidence
is present, and the integration record identifies the reviewed change. At T1
and above it also requires an `accept` review verdict. A task with missing
evidence is not complete.

The review is bound to the task brief and change identity, not to a conversation
or summary. Record the task's base revision and path scope; compute its diff
identity against that base and include hashes for untracked files in scope.
Recompute the identity before integration. If it differs from the verdict,
return the task for review again rather than applying a stale verdict. A tree
fingerprint can reveal writes by agents whose harness does not enforce
read-only behaviour, but detection is not prevention.

Verification commands should be check-only. A command that changes the tree is
work, not proof; formatters should be run in check mode after any formatting
change. Run focused checks per task and the complete repository check suite once
on the integrated slice. Record environment details that affect reproducibility
(such as line endings, formatter version, and test commands) in the repository's
contributor or agent instructions rather than in local workflow state.

## Integration and concurrency

Workers leave changes in the working tree; they do not commit or rewrite
history. The orchestrator integrates one accepted task at a time in dependency
order, records one commit per task, and runs the full check suite after the
integration queue drains. Any action that could discard work or rewrite history
must be escalated and approved before acting.

The current workflow executes implementation sequentially in a shared working
tree. It can dispatch a designed group of slices together and reports each
slice separately, but it does not manage worktrees or run concurrent
implementers. This prevents one task's verification from accidentally including
another task's in-progress changes.

## Approval boundaries

The user approves the design at T1 and above, every slice before dispatch,
material changes to scope or approach, recovery actions that could discard work,
and the final integrated outcome. Formal integration review and approval gates
apply at T2 and above; the architect reports the completed result to the user at
every tier. Routine reversible work inside an approved slice does not require
separate task approval. Irreversible actions are approved one at a time,
immediately before acting. The orchestrator routes decisions through the
architect because the architect holds the user-facing session.
