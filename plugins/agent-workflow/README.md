# Agent Workflow Plugin

**Human-supervised orchestration of specialist AI coding agents through an explicit, repeatable workflow with bounded tasks and verified results.**

## Overview

The **@agent-workflow** plugin provides a primary orchestrator that coordinates
specialist agents to deliver a development objective. It exists for work that
benefits from research, a bounded plan, delegated implementation, and independent
review rather than a single pass.

The workflow is deliberately opinionated. Tasks are bounded, results are
structured, and completion requires evidence rather than assertion. The human
approves the plan before implementation and the integrated outcome afterwards.

## Agents

| Agent            | Responsibility                                                                                                                |
| ---------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| **orchestrator** | Owns the workflow. Understands the objective, plans, delegates, verifies evidence, and reports. Does not implement or review. |
| **researcher**   | Read-only investigation of the codebase, conventions, and documentation. Returns findings with evidence and explicit gaps.    |
| **implementer**  | Executes one bounded task and returns a structured result with the verification it actually ran.                              |
| **reviewer**     | Independently assesses the work, grades findings by severity, and returns `accept`, `revise`, or `escalate`.                  |

The orchestrator holds the contracts and the task lifecycle, so the specialists
stay small and single-purpose. There is deliberately no separate planner agent:
planning is the orchestrator's core responsibility.

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
2. It delegates research and uses the findings.
3. It produces an execution plan and **waits for your approval**.
4. It delegates each task to the implementer, one at a time.
5. It checks the verification evidence returned with each result.
6. It delegates independent review for any change to behaviour.
7. It integrates the work and reports, including anything outstanding.

Delegation depends on the harness:

- **Copilot CLI**: the orchestrator invokes a specialist with `@<agent-name>`.
- **OpenCode**: the orchestrator delegates to a subagent session.
- **Otherwise**: the orchestrator presents the task brief and asks you to run the
  specialist, then return the result. It states that the handoff was manual.

The orchestrator never implies a task ran when it did not.

## Harness Support

Verified against APM 0.30.0:

| Capability                                        | Status                                                              |
| ------------------------------------------------- | ------------------------------------------------------------------- |
| Agent deployment via `apm install` (Copilot)      | **Verified** — agents land in `.github/agents/*.agent.md`           |
| Agent deployment via `apm install` (OpenCode)     | **Verified** — agents land in `.opencode/agents/*.md`               |
| Agent frontmatter validation                      | **Verified** — `apm compile --validate` accepts all four            |
| Automatic delegation (OpenCode subagent sessions) | **Verified** — supported by the harness                             |
| Automatic delegation (Copilot CLI)                | **Expected** - via the `agents` allow-list; not verified end-to-end |

`apm install` projects these agents to harness-native paths. No `plugin.json` is
authored: APM is the only supported installation mechanism, so no explicit agent
declaration is required or invented.

### Delegation and the `tools` conflict

The orchestrator declares an `agents` allow-list (`researcher`, `implementer`,
`reviewer`) so the harness can surface them as subagents. It deliberately does not
declare `tools`.

VS Code documents that when `agents` is set, the `agent` tool should be present in
`tools`. Adding it is not free: VS Code expects `tools` as a YAML list, while
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

If automatic Copilot delegation proves to be the priority, the options are to
accept OpenCode rejection of the orchestrator, or to split per-target agent
variants, which APM does not support from a single source and would require a
build step.

## Workflow Contracts

Four Markdown artefacts carry the workflow, so it does not depend on remembering
conversation history:

- **Task brief** — objective, scope, acceptance criteria, dependencies, expected
  verification, and approvals required.
- **Execution plan** — tasks, ordering, concurrency candidates, boundaries,
  verification strategy, and decisions needing approval.
- **Worker result** — outcome, artefacts changed, verification performed with
  actual results, and escalations.
- **Review verdict** — severity-graded findings with evidence, and a
  recommendation.

Task states are `Proposed`, `Awaiting approval`, `Ready`, `In progress`,
`Needs revision`, `Complete`, and `Blocked`. A task reaches `Complete` only when
its acceptance criteria are met, verification evidence is present, and the review
verdict is `accept`.

## Approval Boundaries

The human approves the plan before implementation, material scope changes,
recovery actions that could discard work, risky integrations, and the final
outcome. Routine reversible actions inside the agreed scope proceed without
asking, and ceremony scales with risk.

## Verification

The workflow distinguishes four levels explicitly:

- **Claimed complete** — the implementer says so. Not sufficient.
- **Verified** — evidence of the stated checks passing.
- **Reviewed** — an independent verdict exists.
- **Approved** — you have accepted the integrated result.

## Scope

This version is sequential and human-supervised. It does not create or manage Git
worktrees, does not run a custom orchestration runtime, and does not maintain
durable state outside the conversation.

The task brief reserves an `execution context` field and the execution plan
records concurrency candidates, so parallel worktree-based execution can be added
later without changing the contracts.

## Troubleshooting

**Q: The orchestrator is asking me to run a specialist myself.**
A: The current harness does not support automatic delegation. The handoff is
manual by design; paste the specialist's result back to continue.

**Q: How much ceremony should a small change get?**
A: Very little. Tell the orchestrator the change is small and low-risk; it should
collapse research into understanding and keep the plan to a short list.

**Q: Do I have to approve every task?**
A: No. You approve the plan. Routine reversible work inside that scope proceeds
without further approval.

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
