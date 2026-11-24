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
| `O<number>`   | Objective identifier                                          | `O001`   |
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

Workflow records live in `.agent-workflow/` at the repository root, one directory per
objective: `.agent-workflow/O<number>-<slug>/`, where the number is zero-padded to three
digits and is one greater than the highest already present. This is local state, not a
deliverable; keep the directory ignored and do not commit its contents.

Each objective records its state in the design header as `Status:`, taking one of
`active`, `complete`, or `abandoned`. The root cannot be listed with `glob`, because
`glob` skips gitignored paths; read the root as a directory with `read`, then read each
objective's `design.md`. Loose files at the root are legacy state and are not offered
for resume.

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
or summary. The identity is four literal strings, and none of them takes a base or a
path scope:

```text
git rev-parse HEAD
git diff HEAD --stat
git diff HEAD --name-only
git ls-files -o --exclude-standard
```

The first records the base revision. Hash a single untracked file with
`git hash-object <path>` when its content matters.

Identity is the stored text of those outputs, compared as text rather than
hashed. This matters where `core.autocrlf` is enabled: an LF-only rewrite reports
a path as modified in `git status` while `git diff` is empty, so status is a hint
and the diff output is the evidence.

Execution is sequential on one shared tree, so `HEAD` does not move while a task is in
flight and the identity stays reproducible until integration. The base is recorded but
never used as a diff argument, and the diff has no path scope, so a write outside the
task's scope shows up in the identity rather than being filtered out of it. Recompute
before integration; if the text differs from the verdict, return the task for review
rather than applying a stale verdict. For a read-only delegation, compare
`git diff HEAD --name-only` before and after: detection reveals a write by an agent
whose harness does not enforce read-only behaviour, but detection is not prevention.

Verification commands should be check-only. A command that changes the tree is
work, not proof: format first, then prove the result in check mode. At T1 and
above the brief names the formatting command and the check that proves it, and a
task is not verified until that check has run and passed; `none` is valid at T0
only. Formatting is proved per task rather than deferred to the integration
suite, because drift that accumulates across tasks turns one reviewable change
into a tree-wide rewrite with no task scope. A formatter that reports files
outside the task's write scope is a scope problem to escalate, not a licence to
reformat the tree. Agents run the literal string the brief names, one command per
shell call, without pipes or command chaining. The harness checks each subcommand
separately, so a compound command is a chain of prompts and one subcommand outside
the approved set asks for the whole call; a saved approval is a prefix pattern, so
it covers later variants of the same command rather than every command. Run
focused checks per task and the complete repository check suite once on the
integrated slice. Record environment details that affect reproducibility (such as
line endings, formatter version, and test commands) in the repository's
contributor or agent instructions rather than in local workflow state.

## Integration and concurrency

Workers leave changes in the working tree; they do not commit or rewrite
history. The orchestrator integrates one accepted task at a time in dependency
order, records one commit per task, and runs the full check suite after the
integration queue drains. The suite is a backstop, not the first proof of
formatting. A formatter-only failure on the integrated tree is a T0 fix-forward
task scoped to the paths the formatter reports, evidenced by the re-run check; it
does not reopen an accepted verdict and it is not an environment failure. A
version, line-ending, or path-case disagreement is an environment failure:
escalate with the output and do not reformat the tree to make the check pass.

The commit stages the reviewed paths and reads its message from
`.agent-workflow/<objective-root>/commit-message.txt`, which is written with `write` and
never staged, so no message string reaches the shell. The header follows the commit
convention the plan records, defaulting to Conventional Commits with `Objective`, `Task`,
and `Requirements` footers. Any action that could discard work or rewrite history must be
escalated and approved before acting.

The current workflow executes implementation sequentially in a shared working
tree. It can dispatch a designed group of slices together and reports each
slice separately, but it does not manage worktrees or run concurrent
implementers. This prevents one task's verification from accidentally including
another task's in-progress changes.

Read-only work may overlap. At the integration gate, the independent review can
be dispatched asynchronously while the full check suite runs in the foreground,
provided the harness supports asynchronous subagents; otherwise the two run in
sequence. Shell commands are never backgrounded, because a detached command has
no recorded evidence and no stable permission scope.

## Approval boundaries

The user approves the design at T1 and above, every slice before dispatch,
material changes to scope or approach, recovery actions that could discard work,
and the final integrated outcome. Formal integration review and approval gates
apply at T2 and above; the architect reports the completed result to the user at
every tier. Routine reversible work inside an approved slice does not require
separate task approval. Irreversible actions are approved one at a time,
immediately before acting. The orchestrator routes decisions through the
architect because the architect holds the user-facing session.
