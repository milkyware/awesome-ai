# Agent Workflow Plugin

**Human-supervised orchestration of specialist AI coding agents through an explicit, repeatable workflow with bounded tasks and verified results.**

## Overview

The **@agent-workflow** plugin provides a primary orchestrator that coordinates
specialist agents to deliver a development objective. It exists for work that
benefits from research, a bounded plan, delegated implementation, and independent
review rather than a single pass.

The workflow is deliberately opinionated. Tasks are bounded, results are
structured, and completion requires evidence rather than assertion. Ceremony
scales with risk: a documentation fix does not get the same gates as a change to
a public contract. The human approves the plan before implementation and the
integrated outcome afterwards.

## Agents

| Agent            | Mode (OpenCode) | Responsibility                                                                                                                                          |
| ---------------- | --------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **orchestrator** | `primary`       | Owns the workflow. Classifies risk, plans, delegates, verifies evidence, commits, and reports. Does not implement or review, except bounded T0 changes. |
| **researcher**   | `subagent`      | Read-only investigation in discovery or targeted mode. Returns findings with evidence, confidence, and explicit gaps.                                   |
| **implementer**  | `subagent`      | Executes one bounded task inside a stated write scope, and returns a structured result with the verification it actually ran.                           |
| **reviewer**     | `subagent`      | Independently assesses a plan, a task, or an integrated change, and returns a severity-graded verdict bound to a diff identity.                         |

The orchestrator holds the contracts and the task lifecycle, so the specialists
stay small and single-purpose. There is deliberately no separate planner agent:
planning is the orchestrator's core responsibility. There is also no architect
agent in this version; the plan review pass and the escalation package keep the
seam open for one later.

Specialists run as subagents in OpenCode. Only the orchestrator is selectable as a
primary agent, so the workflow has one entry point and one agent that can approve,
transition state, or commit.

## Install

The plugin is published from the awesome-ai marketplace as an APM package. Register the marketplace once, then install the plugin for your harness.

```bash
apm marketplace add milkyware/awesome-ai
```

Use one target per project; APM reconciles the active target and removes deployments for targets that are no longer selected. This plugin declares `copilot` and `opencode` targets.

```bash
# GitHub Copilot CLI
apm install agent-workflow@awesome-ai --target copilot

# OpenCode
apm install agent-workflow@awesome-ai --target opencode
```

For a reproducible install, pin the plugin to its release tag:

```bash
apm install agent-workflow@awesome-ai#agent-workflow-v0.0.1 --target copilot
```

Replace the tag with the latest release for this plugin, then commit `apm.yml` and `apm.lock.yaml` and use `apm install --frozen` in CI. See [Reproducible installs](../../README.md#reproducible-installs).

## Usage

Start with the orchestrator and state your objective. A typical run:

1. The orchestrator establishes the objective, constraints, and definition of done.
2. It classifies the work into a risk tier and names the gates that apply.
3. It delegates discovery research and uses the findings.
4. It produces an execution plan and, at T2 and above, has the reviewer assess it.
5. It **waits for your approval** before implementation.
6. It delegates each task to the implementer, one at a time, inside a write scope.
7. It checks the verification evidence returned with each result.
8. It delegates independent review, bound to the diff identity.
9. It obtains integration approval where required and commits the reviewed work,
   one commit per task.
10. It reports, including a readiness statement and anything outstanding.

Delegation depends on the harness:

- **Copilot CLI**: the orchestrator invokes a specialist with `@<agent-name>`.
- **OpenCode**: the orchestrator delegates to a subagent session.
- **Otherwise**: the orchestrator presents the task brief and asks you to run the
  specialist, then return the result. It states that the handoff was manual.

The orchestrator never implies a task ran when it did not.

### Run mode

Run the orchestrator as the interactive primary agent.

- **OpenCode**: it declares `mode: primary`, so it appears in the primary agent
  picker and is not offered as a subagent target. Do not invoke it as a subagent.
- **Copilot**: select it from the agent picker and start the conversation there.
  Do not call it from another agent.
- If the orchestrator's instructions arrive as a delegated prompt, it must stop.
  Approval, escalation, and final acceptance need a channel to you, and a
  delegated session does not have one.

## Harness Support

Verified against APM 0.30.0 and the current harness documentation:

| Capability                                         | Status                                                               |
| -------------------------------------------------- | -------------------------------------------------------------------- |
| Agent deployment via `apm install` (Copilot)       | **Verified** — agents land in `.github/agents/*.agent.md`            |
| Agent deployment via `apm install` (OpenCode)      | **Verified** — agents land in `.opencode/agents/*.md`                |
| Agent frontmatter validation                       | **Verified** — `apm compile --validate` accepts all four             |
| Automatic delegation (OpenCode subagent sessions)  | **Verified** — supported by the harness                              |
| Automatic delegation (Copilot CLI)                 | **Expected** — via the `agents` allow-list; not verified end-to-end  |
| Primary/subagent separation (OpenCode `mode`)      | **Verified** — `opencode debug agents` resolves primary/subagent     |
| Read-only enforcement (OpenCode `permission`)      | **Verified** — `edit: deny` resolves; prompt behaviour not exercised |
| Nested delegation by specialists (OpenCode `task`) | **Verified** — `task: deny` resolves to `subagent deny`              |
| Read-only enforcement (Copilot)                    | **Not enforced** — instructions plus detection only                  |
| Orchestrator refuses delegated use                 | **Enforced in OpenCode** by `mode: primary`; instruction in Copilot  |

`apm install` projects these agents to harness-native paths. No `plugin.json` is
authored: APM is the only supported installation mechanism, so no explicit agent
declaration is required or invented.

APM deploys agent frontmatter verbatim for both targets. It does not translate
between harness conventions, so the following fields are **OpenCode-only** and
should be treated as inert in Copilot until verified: `mode`, `permission`, and
the `agents` allow-list. Copilot has no equivalent for read-only subagents, so
enforcement there is instruction plus detection.

### Read-only enforcement

There is no single frontmatter that both harnesses enforce, so read-only is
layered:

| Layer | Mechanism                                                                                                                   | Applies to |
| ----- | --------------------------------------------------------------------------------------------------------------------------- | ---------- |
| L1    | Instruction boundary, plus the requirement to report any write attempted                                                    | Both       |
| L2    | OpenCode `permission`: `edit: deny`, `task: deny`, `question: deny`, with `bash` limited to read-only Git commands or `ask` | OpenCode   |
| L3    | Tree fingerprint before dispatch and after return; a difference rejects the result                                          | Both       |
| L4    | Documented limitation                                                                                                       | Copilot    |

The fingerprint is `git status --porcelain=v1`, the diff identity, and a hash of
each untracked file. Layer 3 does not prevent a write; it makes one visible and
attributable. That is the achievable guarantee for a harness without a read-only
subagent mode.

### The `tools` conflict

The orchestrator declares an `agents` allow-list (`researcher`, `implementer`,
`reviewer`) so the harness can surface them as subagents. It deliberately does not
declare `tools`.

Visual Studio Code documents that when `agents` is set, the `agent` tool should be present in
`tools`. Adding it is not free: Visual Studio Code expects `tools` as a YAML list, while
OpenCode requires a mapping of tool name to boolean and **rejects the agent at
load time** otherwise. APM deploys agents verbatim and does not translate between
the two shapes, so a single source file cannot carry `tools` for both targets.
This was confirmed with `apm install --target copilot,opencode`, which reports:

```text
[!] [agent-workflow] OpenCode agent 'agent-workflow/orchestrator.agent.md'
has tools as list; OpenCode requires a mapping of tool-name to boolean.
OpenCode will reject this agent at load time.
```

Omitting `tools` leaves the tool set unrestricted, so the `agent` tool should be
available, but that has not been verified. Until it is, treat automatic Copilot
delegation as expected rather than proven, and use the handoff buttons or explicit
`@agent` invocation, both of which are verified.

`permission` is used instead of `tools` for read-only enforcement because it is an
OpenCode-only key with no conflicting shape in Copilot. If Copilot rejects an
unknown frontmatter key on install, the fallback is to drop `permission` and rely
on instruction plus detection.

### Agent naming

The frontmatter `name` must equal the file stem: `orchestrator.agent.md` declares
`name: orchestrator`. Copilot reads `name` and defaults it to the filename;
OpenCode derives the agent name from the filename alone. Keeping the two identical
means a rename cannot silently split the identity across harnesses, and every
`@<agent-name>` reference resolves in both.

### Model selection

The plugin does not pin `model`. Model identifiers are harness- and
provider-specific, and APM passes the field through verbatim, so a pinned value
would work in one harness and fail in another.

Choose per role in your harness configuration: the strongest available model for
planning and review, a mid-tier model for orchestration, and a cheaper model for
bounded research and implementation where quality holds.

## Risk Tiers and Gates

The tier sets the gates. Classify before planning; when two tiers are plausible,
take the higher one.

| Tier | Typical work                                                                                        | Plan approval | Plan review  | Task review  | Integration review | Integration approval |
| ---- | --------------------------------------------------------------------------------------------------- | ------------- | ------------ | ------------ | ------------------ | -------------------- |
| T0   | Documentation, comments, formatting, test-only changes with no behaviour impact                     | Not required  | Not required | Not required | Not required       | Not required         |
| T1   | Behaviour change inside one module, covered by existing tests                                       | Required      | Optional     | Required     | Not required       | Not required         |
| T2   | Public contract, data shape, CI or release configuration, security, dependencies, several modules   | Required      | Required     | Required     | Required           | Required             |
| T3   | History rewrite, deletion, migration, dependency upgrade with lockfile churn, anything irreversible | Required      | Required     | Required     | Required           | Per action           |

At T0 the orchestrator may make the change itself when dispatching would cost more
than the change, and records it as `direct`. A behaviour change never qualifies.

## Workflow Contracts

Five Markdown artefacts carry the workflow, so it does not depend on remembering
conversation history. Each has one owner; consumers state the evidence they
require rather than restating the shape.

- **Task brief** (orchestrator) — risk tier, objective, inputs, write scope,
  acceptance criteria, dependencies, expected verification, approvals required.
- **Execution plan** (orchestrator) — scope, tasks, ordering, concurrency
  candidates, interfaces, risk register, decisions, verification strategy.
- **Worker result** (implementer) — outcome, artefacts changed, verification
  performed with actual results, criteria status, limitations, escalations.
- **Review verdict** (reviewer) — target, diff identity, severity-graded findings
  with evidence, criteria status, test assessment, recommendation.
- **Decision record** (orchestrator) — question, options, decision, rationale,
  reversibility, decided by, status.

`D1` in the decision record is always the approval of the plan and its scope. Add a
record when the approach deviates from the plan, when a finding is deferred, when
a risk tier changes, and when integration resolves a conflict. For an
architectural decision that outlives the task, use an ADR rather than a second
format here.

Task states are `Proposed`, `Awaiting approval`, `Ready`, `In progress`,
`In review`, `Needs revision`, `Blocked`, `Failed`, and `Complete`. At T1 and
above, a task reaches `Complete` only when its acceptance criteria are met,
verification evidence is present, the review verdict is `accept`, and an
integration commit records the reviewed diff identity. At T0, criteria met and
evidence present are sufficient.

`Blocked` is recoverable without re-planning. `Failed` is terminal for the
attempt: the task returns to `Ready` only through a revised plan, and at T2 and
above that needs fresh approval.

## Verification

The workflow distinguishes four levels explicitly:

- **Claimed complete** — the implementer says so. Not sufficient.
- **Verified** — evidence of the stated checks passing.
- **Reviewed** — an independent verdict exists, bound to a diff identity.
- **Approved** — you have accepted the integrated result.

Review is bound to an artefact, not to a conversation. The verdict records
`git diff HEAD | git hash-object --stdin` and a diff stat; integration recomputes
the identity and refuses the verdict if it no longer matches. A verdict cannot be
earned on one tree and applied to another.

## Integration

Workers leave changes in the working tree. They do not commit, push, branch,
stash, reset, or rewrite history.

The orchestrator integrates: it confirms the tree fingerprint, obtains integration
approval at T2 and above, commits one task at a time with the task ID in the
message, records the SHA and reviewed diff identity, and runs the verification on
the integrated tree. A failed check is fixed forward or reverted; anything beyond
reverting its own commit that has not been pushed needs approval.

## Approval Boundaries

The human approves the plan before implementation, material scope changes,
recovery actions that could discard work, integrations at T2 and above, and the
final outcome. Irreversible actions are approved one at a time, immediately before
acting, never as part of a broader plan approval.

Routine reversible actions inside the agreed scope proceed without asking. The
orchestrator never claims that a human has approved something when they have not.

## Scope and Roadmap

This version executes implementation sequentially and keeps the workflow
human-supervised. It does not create or manage Git worktrees, run a custom
orchestration runtime, or maintain durable state outside the conversation.

Shipped in this version:

- Risk tiers and a gate matrix, so ceremony is decided by rules rather than mood.
- Two targeted research tasks may run concurrently, with disjoint questions and
  path scopes. This is the safe half of parallel execution: read-only, no shared
  write scope, no worktree.
- Plan review by the reviewer at T2 and above.
- Decision records and a risk register.
- Diff-identity binding and tree fingerprints.
- Integration and commit rules owned by the orchestrator.

Deliberately deferred:

- An architect agent for design decisions and a second opinion at T3. The
  escalation package and plan review pass are the seam it would attach to.
- Parallel implementation with Git worktrees, branch ownership, and conflict
  handling.
- Dependencies on `delivery/implementation-plan` and `code-quality/code-review`.
  The overlap is intentional for now so the plugin installs and behaves on its
  own; these become package dependencies once the contracts settle.
- Dynamic task orchestration, retries beyond two rounds, and telemetry.

## Troubleshooting

**Q: The orchestrator is asking me to run a specialist myself.**
A: The current harness does not support automatic delegation. The handoff is
manual by design; paste the specialist's result back to continue.

**Q: The orchestrator says it cannot proceed because it is a subagent.**
A: It was invoked from another agent's session. Start a new conversation with the
orchestrator selected as the primary agent; approval gates need a channel to you.

**Q: How much ceremony should a small change get?**
A: T0 or T1. A documentation fix needs no plan approval or independent review; a
contained behaviour change needs a short plan and a review. The tier decides, and
the orchestrator states it.

**Q: Do I have to approve every task?**
A: No. You approve the plan. Routine reversible work inside that scope proceeds
without further approval. Integration approval applies at T2 and above.

**Q: The reviewer is asking me to approve a test command.**
A: OpenCode read-only permission allows file edits to be denied while leaving
shell commands to you. Approve test, lint, and build commands; deny anything that
writes to the tree.

**Q: Only the orchestrator appears in the agent picker.**
A: That is intended. The specialists declare `mode: subagent` so they are
delegated rather than selected. In Copilot, where `mode` has no effect, do not
select them directly for workflow work.

**Q: A read-only agent changed a file.**
A: Treat it as a boundary violation. The orchestrator's tree fingerprint will
differ, the result is rejected, and the reviewed state is restored before
continuing.

## Contributing

To report issues or suggest improvements to the @agent-workflow plugin:

1. Open an issue in the [awesome-ai repository](https://github.com/milkyware/awesome-ai)
2. Reference the plugin name and the agent.
3. Include the objective and the workflow step that misbehaved.

## License

This plugin is licensed under the MIT License. See the [awesome-ai repository LICENCE](../../LICENCE) for details.

## Related Resources

- [awesome-ai Repository](https://github.com/milkyware/awesome-ai)
- [Agent Package Manager](https://microsoft.github.io/apm/)
