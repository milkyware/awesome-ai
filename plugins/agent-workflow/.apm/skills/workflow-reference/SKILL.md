---
name: workflow-reference
description: Long-form reference for the agent-workflow risk tiers, change identity scheme and artefact contracts. Use when an agent or a human needs the full tier definitions, the identity command set, or the contract field lists rather than the condensed summary inline in an agent. Descriptive: the agent definitions remain normative for enforcement.
---

# Workflow Reference

An agent definition carries the condensed form of every rule it enforces. Load a
reference only when that summary is not enough for the question at hand.

| Need                                                             | Reference                 |
| ---------------------------------------------------------------- | ------------------------- |
| Tier definitions, the gates each tier implies, changing the tier | `references/tiers.md`     |
| Change identity, line endings, verdict binding                   | `references/identity.md`  |
| Task brief, plan, worker result, verdict, decision record        | `references/contracts.md` |
| The literal shell strings an agent may run                       | `references/commands.md`  |

## Rules

- The agent definitions are normative. This reference explains and expands them; it
  never overrides a gate, budget or approval rule stated in an agent.
- Load one reference, not all four. Reading the whole set to answer a single
  question defeats the purpose of loading on demand.
- Nothing here is technology-specific. Build, test and format commands belong in the
  repository's own contributor or agent instructions, and the task brief names the
  exact string to run. A shell command is copied from the vocabulary or from the
  brief, never composed at the prompt.
- Workflow state lives in `.agent-workflow/` and is local, not a deliverable.
