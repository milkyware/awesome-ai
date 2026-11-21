# Agent Workflow Plugin

**Human-supervised design and delivery: an architect works with you to define the design and approved slices; supporting sub-agents execute bounded tasks and verify the results.**

## Overview

The `agent-workflow` plugin separates design from execution. The architect owns
the design and user-facing decisions. Once you approve a slice, the orchestrator
plans and coordinates its implementation, then returns evidence and a report so
the design can be reconsidered.

The workflow is domain-neutral: it provides roles and process, not
technology-specific knowledge. Work is divided into bounded tasks, and
completion requires recorded verification rather than assertion. The amount of
review and ceremony scales with risk.

## Agents

The plugin provides an **architect** with four supporting sub-agents. Select the
architect as the entry point; the specialists support its design and delivery
workflow.

| Agent                         | Responsibility                                                                                     |
| ----------------------------- | -------------------------------------------------------------------------------------------------- |
| [Architect](#architect)       | Owns the design, user decisions, and approved slices.                                              |
| [Orchestrator](#orchestrator) | Plans and executes an approved slice through bounded tasks, verification, review, and integration. |
| [Researcher](#researcher)     | Investigates the repository or documentation and returns findings with evidence and gaps.          |
| [Implementer](#implementer)   | Performs one bounded task and reports the changes and checks actually run.                         |
| [Reviewer](#reviewer)         | Independently assesses a design, plan, task, or integrated change and returns a verdict.           |

### Architect

The architect is your entry point and the owner of the design. It establishes
requirements and constraints, checks available capabilities, records the
design, obtains your approvals, and decides whether to continue or revise after
each slice. It does not implement or independently review changes. See the
[architect definition](./.apm/agents/architect.agent.md).

### Orchestrator

The orchestrator owns execution of an approved slice. It creates task briefs,
coordinates the supporting specialists, checks evidence, integrates accepted
work, and reports back to the architect. It does not own the design or approve
work on your behalf. See the
[orchestrator definition](./.apm/agents/orchestrator.agent.md).

### Researcher

The researcher answers discovery or targeted questions with evidence, confidence
and explicit gaps. Its role is investigation, not design or implementation. See
the [researcher definition](./.apm/agents/researcher.agent.md).

### Implementer

The implementer performs one task from an explicit brief, works within its
stated scope, and reports actual verification results. It does not expand the
task or integrate the change. See the
[implementer definition](./.apm/agents/implementer.agent.md).

### Reviewer

The reviewer independently checks the requested artefact against its criteria
and records evidence, severity, and a recommendation. Review is bound to the
change or plan assessed, not merely to a conversation or summary. See the
[reviewer definition](./.apm/agents/reviewer.agent.md).

## Skills

| Skill                                                           | Purpose                                                                                               |
| --------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------- |
| [Workflow reference](./.apm/skills/workflow-reference/SKILL.md) | Long-form risk tiers, change identity scheme, and artefact contracts, loaded on demand by the agents. |

The agent definitions carry the condensed form of every rule they enforce. The
skill expands those rules for a reader who needs the full tier table, the identity
command set, or the contract field lists; it is descriptive, and the agent
definitions remain normative for enforcement.

## Install

The plugin is published in the awesome-ai marketplace as an APM package. Add the
marketplace once:

```bash
apm marketplace add milkyware/awesome-ai
```

This plugin declares the `copilot` and `opencode` targets. Use one target per
project; APM manages the deployment for the selected target.

```bash
# GitHub Copilot CLI
apm install agent-workflow@awesome-ai --target copilot

# OpenCode
apm install agent-workflow@awesome-ai --target opencode
```

For reproducible installs, pin the plugin to its release tag, commit `apm.yml`
and `apm.lock.yaml`, and use `apm install --frozen` in CI:

```bash
apm install agent-workflow@awesome-ai#agent-workflow-v0.1.5 --target copilot
```

Replace the tag with the release you intend to use. See
[reproducible installs](../../README.md#reproducible-installs).

## Getting started

Start a conversation with the architect and describe the outcome you want. For
example:

> Design a small feature that lets users export their saved searches. First
> identify the constraints and relevant capabilities, then propose a design
> and the first implementation slice. Do not start implementation until I
> approve the slice.

The workflow is:

1. The architect clarifies the objective and records the design at a level
   appropriate to the risk.
2. You review and approve each slice before implementation begins.
3. The orchestrator turns the approved slice into bounded tasks and coordinates
   research, implementation, and independent review as required.
4. The orchestrator verifies the returned evidence, integrates accepted work,
   and reports the outcome.
5. The architect checks whether the design still holds and proposes the next
   slice or a revision.

Start with the architect rather than the orchestrator: the architect owns the
user-facing design and approval decisions. The orchestrator reports to the
architect and cannot approve work on your behalf.

The way agents are selected and delegated depends on the active harness. If it
cannot invoke a specialist, the workflow should make the handoff explicit and
ask for a manual run; no agent should imply that work was delegated when it was
not.

## Workflow reference

Workflow state is durable and stored in `.agent-workflow/` at the repository
root. It contains the design, execution plan, task briefs, results, and review
verdicts. This is local state: keep it ignored and do not commit its contents.

The [workflow reference](./docs/workflow.md) explains identifier formats,
risk tiers, approvals, artefact ownership, task completion, verification, and
integration. See [troubleshooting](./docs/troubleshooting.md) for common
workflow issues.

## Harness support

APM installs the package's shared agent definitions and skills into locations
supported by the selected target. This does not make every harness's agent
selection, delegation, or permission enforcement identical. Check the
documentation for your harness and verify the behaviour you rely on; an
instruction or detected boundary violation is not the same as runtime
enforcement. Where a harness does not surface skills to a subagent, the agent's
own rules still apply: the skill only expands them.

## Companion packages

The workflow is intentionally technology-neutral. Install technology-specific
packages alongside this plugin when the project needs them; neither package
needs to depend on the other. The architect records capabilities it observes
and does not assume that an uninstalled package is available.

## Contributing

See the repository [contribution guidance](../../CONTRIBUTING.md). For an
`agent-workflow` issue, include the agent involved, the objective, and the
workflow step that misbehaved.

## License

This plugin is licensed under the MIT License. See the
[awesome-ai repository licence](../../LICENCE) for details.

## Related resources

- [Workflow reference](./docs/workflow.md)
- [Troubleshooting](./docs/troubleshooting.md)
- [awesome-ai repository](https://github.com/milkyware/awesome-ai)
- [Agent Package Manager](https://microsoft.github.io/apm/)
- [GitHub Copilot CLI custom agents](https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/create-custom-agents-for-cli)
- [OpenCode agents](https://opencode.ai/docs/agents)
