# Agent Workflow Plugin

**Human-supervised design and delivery: an architect owns the spec and iterates it with the user, then issues approved slices to an orchestrator that delegates bounded tasks and verifies the results.**

## Overview

The **@agent-workflow** plugin separates design from execution. An **architect**
establishes the specification with you, writes it to a durable artefact, and
issues approved slices of work. An **orchestrator** executes each slice through
bounded tasks, delegated implementation, and independent review, then reports
back so the design can be reconsidered.

The separation exists because the two activities have different shapes. Design
is convergent and iterative: it needs a user channel and a long-lived view of
the whole objective. Execution is a state machine: it needs bounded tasks,
evidence, and a verdict. Running both in one context forces the design to
compete for attention with triage, research findings, and integration state.

The workflow is deliberately opinionated. Tasks are bounded, results are
structured, and completion requires evidence rather than assertion. Ceremony
scales with risk: a documentation fix does not get the same gates as a change to
a public contract. You approve the design and each slice before implementation,
and the integrated outcome afterwards.

## Agents

| Agent            | Mode (OpenCode) | Responsibility                                                                                                                                                                  |
| ---------------- | --------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **architect**    | `primary`       | Owns the design. Establishes the spec with you, checks capability, writes the design artefact, and issues approved slices. Does not implement or review.                        |
| **orchestrator** | `subagent`      | Owns one approved slice. Plans the tasks inside it, delegates implementation, verifies evidence, obtains review, integrates, and reports. Accepts work from the architect only. |
| **researcher**   | `subagent`      | Read-only investigation. Discovery for the architect, targeted questions for the orchestrator. Returns findings with evidence, confidence, and explicit gaps.                   |
| **implementer**  | `subagent`      | Executes one bounded task inside a stated write scope, and returns a structured result with the verification it actually ran.                                                   |
| **reviewer**     | `subagent`      | Independently assesses a design, a plan, a task, or an integrated change, and returns a severity-graded verdict bound to an identity.                                           |

Only the architect is selectable as a primary agent, so the workflow has one
entry point and one agent that can approve. The orchestrator holds the task
lifecycle and all delegation below the slice.

The researcher stays a separate agent rather than folding into the architect.
The architect's value is that it holds _distilled_ design context across slices;
if it also did its own searching it would carry raw file contents, dead ends and
grep noise, which is the context pollution the separation is meant to prevent.
The architect receives findings, not searches.

## Install

The plugin is published from the awesome-ai marketplace as an APM package.
Register the marketplace once, then install the plugin for your harness.

```bash
apm marketplace add milkyware/awesome-ai
```

Use one target per project; APM reconciles the active target and removes
deployments for targets that are no longer selected. This plugin declares
`copilot` and `opencode` targets.

```bash
# GitHub Copilot CLI
apm install agent-workflow@awesome-ai --target copilot

# OpenCode
apm install agent-workflow@awesome-ai --target opencode
```

For a reproducible install, pin the plugin to its release tag:

```bash
apm install agent-workflow@awesome-ai#agent-workflow-v0.1.0 --target copilot
```

Replace the tag with the latest release for this plugin, then commit `apm.yml`
and `apm.lock.yaml` and use `apm install --frozen` in CI. See
[Reproducible installs](../../README.md#reproducible-installs).

## Usage

Start with the architect and state your objective. A typical run:

1. The architect establishes the objective, constraints, and definition of done.
2. It classifies the work into a risk tier and names the gates that apply.
3. It delegates discovery research and uses the findings.
4. It checks capability: what the harness and repository actually provide.
5. It writes the design artefact with identified functional requirements.
6. At T2 and above, the reviewer assesses the design before you see it.
7. It presents the design and the first slice and **waits for your approval**.
8. It dispatches the approved slice to the orchestrator.
9. The orchestrator plans the slice, delegates each task to the implementer, and
   checks the verification evidence returned with each result.
10. It delegates independent review, bound to the diff identity.
11. It integrates the reviewed work, one commit per task.
12. It returns a slice report, including any design questions the work raised.
13. The architect decides whether the design holds or needs revising, and either
    issues the next slice or returns to you.

Delegation depends on the harness:

- **Copilot CLI**: the dispatching agent invokes a specialist with `@<agent-name>`.
- **OpenCode**: the dispatching agent delegates to a subagent session.
- **Otherwise**: it presents the brief and asks you to run the specialist, then
  return the result. It states that the handoff was manual.

No agent implies a task ran when it did not.

### Run mode

Run the **architect** as the interactive primary agent.

- **OpenCode**: it declares `mode: primary`, so it appears in the primary agent
  picker. The four specialists declare `mode: subagent` and are not selectable.
- **Copilot**: select the architect from the agent picker and start the
  conversation there. In Copilot, where `mode` has no effect, do not select the
  specialists directly for workflow work.

Do not start the orchestrator directly. It is a subagent with no channel to you,
so it cannot obtain the approvals it needs. If it finds itself selected as a
primary agent or delegated by anything other than the architect, it stops and
says why.

## The workflow directory

The workflow state is durable, not conversational, so a context reset, a session
change, or a model change does not lose the design. It lives in
`.agent-workflow/` at the repository root.

| Artefact           | Owner        | Purpose                                                                       |
| ------------------ | ------------ | ----------------------------------------------------------------------------- |
| `design.md`        | architect    | Objective, functional requirements, capability map, design, decisions, slices |
| `plan.md`          | orchestrator | Tasks derived from a slice, ordered and traced to requirement IDs             |
| `tasks/<ID>.md`    | orchestrator | One task brief — the artefact the implementer works from                      |
| `results/<ID>.md`  | orchestrator | Worker results                                                                |
| `verdicts/<ID>.md` | orchestrator | Review verdicts                                                               |

The load-bearing property is that **the reviewer reviews the diff against
`tasks/<ID>.md`, not against the conversation.** The implementer reads the same
bytes the reviewer checks against, so a brief cannot drift between what was
requested and what was verified. A change to a brief mid-task is a decision, not
a silent edit.

The architect establishes the directory and ensures it is ignored. If
`.gitignore` lacks the entry it is appended; if the file does not exist it is
created with that single entry. Where a tracked-file change is undesirable,
`.git/info/exclude` is used instead. The contents are never committed. The
architect and orchestrator both report what they did to `.gitignore`, because
editing a tracked file is a visible act.

## Capability check

Capabilities are declared and verified by observation. They are not discovered by
inference, and you are not asked what is installed.

The architect enumerates the harness-native primitive locations for the active
target — `.github/skills/`, `.github/agents/`, `.github/instructions/`,
`.agents/skills/`, `.claude/skills/`, `.claude/agents/`, `.opencode/skills/`,
`.opencode/agents/`, `.cursor/`, `.windsurf/`, `.kiro/`, `.grok/`, `.codex/`,
`.gemini/` — and reads the instruction files that frequently document the skills
and agents a project expects to be used: `AGENTS.md` at the root and in nested
directories, `.github/copilot-instructions.md`, `.github/instructions/*.md`,
`CLAUDE.md`, `GEMINI.md`, and the repository `README.md`. It reads `apm.yml` and
`apm.lock.yaml` for declared dependencies.

The result is recorded in `design.md` as a capability map, with each capability
tied to the requirement it serves and its source. A requirement with no available
capability is either handled directly by the orchestrator or escalated. It is
never met by a capability that was not observed, and a capability that exists but
serves no requirement is recorded and left unused.

## Harness Support

Verified against APM 0.30.0 and the current harness documentation:

| Capability                                        | Status                                                               |
| ------------------------------------------------- | -------------------------------------------------------------------- |
| Agent deployment via `apm install` (Copilot)      | **Verified** — agents land in `.github/agents/*.agent.md`            |
| Agent deployment via `apm install` (OpenCode)     | **Verified** — agents land in `.opencode/agents/*.md`                |
| Agent frontmatter validation                      | **Verified** — `apm compile --validate` accepts all five             |
| Automatic delegation (OpenCode subagent sessions) | **Verified** — supported by the harness                              |
| Nested delegation (orchestrator → specialist)     | **Expected** — `subagent` allow-list; not verified end-to-end        |
| Automatic delegation (Copilot CLI)                | **Expected** — via the `agents` allow-list; not verified end-to-end  |
| Primary/subagent separation (OpenCode `mode`)     | **Verified** — `opencode debug agents` resolves primary/subagent     |
| Read-only enforcement (OpenCode `permissions`)    | **Verified** — `edit: deny` resolves; prompt behaviour not exercised |
| Nested delegation by specialists (OpenCode)       | **Verified** — `subagent: deny` resolves for each specialist         |
| Read-only enforcement (Copilot)                   | **Not enforced** — instructions plus detection only                  |
| Architect refuses delegated use                   | **Enforced in OpenCode** by `mode: primary`; instruction in Copilot  |
| Orchestrator refuses non-architect delegation     | **Instruction only** — `question: deny` removes the user channel     |

`apm install` projects these agents to harness-native paths. No `plugin.json` is
authored: APM is the only supported installation mechanism, so no explicit agent
declaration is required or invented.

APM deploys agent frontmatter verbatim for both targets. It does not translate
between harness conventions, so the following fields are **OpenCode-only** and
should be treated as inert in Copilot until verified: `mode`, `permissions`, and
the `agents` allow-list. Copilot has no equivalent for read-only subagents, so
enforcement there is instruction plus detection.

### Agent permissions

Each agent declares only what its role can or cannot do, using OpenCode V2
`permissions`. The last matching rule wins.

| Agent        | Edit  | Question | Subagents                               |
| ------------ | ----- | -------- | --------------------------------------- |
| architect    | allow | allow    | researcher, reviewer, orchestrator only |
| orchestrator | allow | deny     | researcher, implementer, reviewer only  |
| implementer  | allow | deny     | none                                    |
| researcher   | deny  | deny     | none                                    |
| reviewer     | deny  | deny     | none                                    |

No agent declares shell `allow` or `ask` rules. Approval policy belongs to the
person running the harness, not to a portable agent definition: agent rules are
appended after global rules and the last match wins, so a blanket `shell *: ask`
in frontmatter would silently override every shell allow the user configured.
The boundaries that matter — read-only, no delegation, no user channel — are
`deny` rules, which only ever tighten.

### Required shell policy (OpenCode)

The agents rely on the harness for shell approval. Install these hard denies once
in your user or project configuration, as policies rather than permissions, so
that an agent or a project file cannot lift them:

```jsonc
{
  "policies": [
    { "action": "tool.use", "resource": "shell:git push *", "effect": "deny" },
    {
      "action": "tool.use",
      "resource": "shell:git reset --hard *",
      "effect": "deny",
    },
    {
      "action": "tool.use",
      "resource": "shell:git clean -f*",
      "effect": "deny",
    },
    { "action": "tool.use", "resource": "shell:rm -rf *", "effect": "deny" },
    {
      "action": "tool.use",
      "resource": "shell:Remove-Item -Recurse *",
      "effect": "deny",
    },
    {
      "action": "tool.use",
      "resource": "shell:terraform apply *",
      "effect": "deny",
    },
    {
      "action": "tool.use",
      "resource": "shell:terraform destroy *",
      "effect": "deny",
    },
  ],
}
```

Without these, the agents inherit the harness defaults: permissive on a stock
OpenCode install, and instruction plus fingerprint only on Copilot.

### Read-only enforcement

There is no single frontmatter that both harnesses enforce, so read-only is
layered:

| Layer | Mechanism                                                                                                                       | Applies to |
| ----- | ------------------------------------------------------------------------------------------------------------------------------- | ---------- |
| L1    | Instruction boundary, plus the requirement to report any write attempted                                                        | Both       |
| L2    | OpenCode `permissions`: `edit: deny`, `subagent: deny`, `question: deny`; no shell rules, so shell approval stays with the user | OpenCode   |
| L3    | Tree fingerprint before dispatch and after return; a difference rejects the result                                              | Both       |
| L4    | Documented limitation                                                                                                           | Copilot    |

The fingerprint is `git status --porcelain=v1`, the diff identity, and a hash of
each untracked file. Layer 3 does not prevent a write; it makes one visible and
attributable. That is the achievable guarantee for a harness without a read-only
subagent mode.

### Why write scopes are not enforced by permission

The architect, orchestrator and implementer all need to write, and their write
scopes are different. OpenCode documents a path-scoped form for this —
`edit: { "*": "deny", "path/**": "allow" }` — but it does not work reliably: a
top-level wildcard is not overridden by a named-key object rule, and pattern
matching is simple wildcard against the Git worktree root rather than the launch
directory. Since a per-agent write scope cannot be expressed mechanically, these
three agents use a blanket `edit: "*" → allow` rule and rely on the instruction
boundary in their own definition plus the L3 tree fingerprint.

Read-only agents are unaffected: total denial (`edit: deny`) is reliable. This is
a real limitation, not a design preference. If the underlying harness bug is
fixed, the whitelist form becomes available and the L1-only guarantee for the
three writing agents can be strengthened.

### The `tools` conflict

The orchestrator and the architect declare an `agents` allow-list so the harness
can surface their subagents. Neither declares `tools`.

Visual Studio Code documents that when `agents` is set, the `agent` tool should be
present in `tools`. Adding it is not free: Visual Studio Code expects `tools` as a
YAML list, while OpenCode requires a mapping of tool name to boolean and
**rejects the agent at load time** otherwise. APM deploys agents verbatim and
does not translate between the two shapes, so a single source file cannot carry
`tools` for both targets. This was confirmed with `apm install --target
copilot,opencode`, which reports:

```text
[!] [agent-workflow] OpenCode agent 'agent-workflow/orchestrator.agent.md'
has tools as list; OpenCode requires a mapping of tool-name to boolean.
OpenCode will reject this agent at load time.
```

Omitting `tools` leaves the tool set unrestricted, so the `agent` tool should be
available, but that has not been verified. Until it is, treat automatic Copilot
delegation as expected rather than proven, and use the handoff buttons or explicit
`@agent` invocation, both of which are verified.

`permissions` is used instead of `tools` for read-only enforcement because it is an
OpenCode-only key with no conflicting shape in Copilot. If Copilot rejects an
unknown frontmatter key on install, the fallback is to drop `permissions` and rely
on instruction plus detection.

### Agent naming

The frontmatter `name` must equal the file stem: `architect.agent.md` declares
`name: architect`. Copilot reads `name` and defaults it to the filename; OpenCode
derives the agent name from the filename alone. Keeping the two identical means a
rename cannot silently split the identity across harnesses, and every
`@<agent-name>` reference resolves in both.

### Model selection

The plugin does not pin `model`. Model identifiers are harness- and
provider-specific, and APM passes the field through verbatim, so a pinned value
would work in one harness and fail in another.

Choose per role in your harness configuration: the strongest available model for
the architect and the reviewer, a mid-tier model for orchestration, and a cheaper
model for bounded research and implementation where quality holds. The architect
benefits most, because design quality compounds across every slice it dispatches.

## Risk Tiers and Gates

The tier sets the gates. The architect classifies; the orchestrator applies them
at task level. When two tiers are plausible, take the higher one.

| Tier | Typical work                                                                                        | Plan approval | Design review | Task review  | Integration review | Integration approval |
| ---- | --------------------------------------------------------------------------------------------------- | ------------- | ------------- | ------------ | ------------------ | -------------------- |
| T0   | Documentation, comments, formatting, test-only changes with no behaviour impact                     | Not required  | Not required  | Not required | Not required       | Not required         |
| T1   | Behaviour change inside one module, covered by existing tests                                       | Required      | Optional      | Required     | Not required       | Not required         |
| T2   | Public contract, data shape, CI or release configuration, security, dependencies, several modules   | Required      | Required      | Required     | Required           | Required             |
| T3   | History rewrite, deletion, migration, dependency upgrade with lockfile churn, anything irreversible | Required      | Required      | Required     | Required           | Per action           |

At T0 the orchestrator may make the change itself when dispatching would cost more
than the change, and records it as `direct`. A behaviour change never qualifies.

## Workflow Contracts

Six artefacts carry the workflow, and five of them are files. Each has one owner;
consumers state the evidence they require rather than restating the shape.

- **Design** (architect) — objective, functional requirements as `FR-###`,
  success criteria, capability map, approach, decisions, slices, non-goals.
- **Task brief** (orchestrator, at `tasks/<ID>.md`) — requirement IDs, risk
  tier, objective, inputs, write scope, acceptance criteria, dependencies,
  expected verification, approvals required.
- **Execution plan** (orchestrator, at `plan.md`) — slice identity, scope,
  tasks, ordering, concurrency candidates, interfaces, risk register, decisions,
  verification strategy.
- **Worker result** (implementer) — outcome, artefacts changed, verification
  performed with actual results, criteria status, limitations, escalations.
- **Review verdict** (reviewer) — target, identity reviewed, severity-graded
  findings with evidence, criteria status, test assessment, recommendation.
- **Decision record** (architect for design; orchestrator for execution) —
  question, options, decision, rationale, reversibility, decided by, status.

The design's recorded approval is always the first decision: it is the approval of
the design and its first slice. Add a record when the approach deviates from the
plan, when a finding is deferred, when a risk tier changes, and when integration
resolves a conflict. For an architectural decision that outlives the task, use an
ADR rather than a second format here.

Task states are `Proposed`, `Awaiting approval`, `Ready`, `In progress`,
`In review`, `Needs revision`, `Blocked`, `Failed`, and `Complete`. At T1 and
above, a task reaches `Complete` only when its acceptance criteria are met,
verification evidence is present, the review verdict is `accept`, and an
integration commit records the reviewed diff identity. At T0, criteria met and
evidence present are sufficient.

Slice approval replaces per-task approval, so a task inside an approved slice does
not need its own approval unless it is irreversible. `Blocked` is recoverable
without re-planning. `Failed` is terminal for the attempt: the task returns to
`Ready` only through a revised plan, and at T2 and above that escalates to the
architect.

## Verification

The workflow distinguishes four levels explicitly:

- **Claimed complete** — the implementer says so. Not sufficient.
- **Verified** — evidence of the stated checks passing.
- **Reviewed** — an independent verdict exists, bound to an identity.
- **Approved** — you have accepted the integrated result.

Review is bound to an artefact, not to a conversation. The verdict records
`git diff HEAD | git hash-object --stdin` and a diff stat; integration recomputes
the identity and refuses the verdict if it no longer matches. A verdict cannot be
earned on one tree and applied to another.

## Integration

Workers leave changes in the working tree. They do not commit, push, branch,
stash, reset, or rewrite history.

The orchestrator integrates: it confirms the tree fingerprint, obtains integration
approval through the architect at T2 and above, commits one task at a time with
the task ID in the message, records the SHA and reviewed diff identity, and runs
the verification on the integrated tree. A failed check is fixed forward or
reverted; anything beyond reverting its own commit that has not been pushed needs
approval.

## Approval Boundaries

You approve the design and each slice before implementation, material scope
changes, recovery actions that could discard work, integrations at T2 and above,
and the final outcome. Irreversible actions are approved one at a time,
immediately before acting, never as part of a broader approval.

Routine reversible actions inside an approved slice proceed without asking. No
agent ever claims that you, or the architect, have approved something when you
have not.

Because the orchestrator cannot reach you, its approvals route through the
architect: it escalates, the architect re-presents the escalation, and you answer.
Net effect is that you are asked about slices rather than tasks.

## Scope and Roadmap

This version executes implementation sequentially and keeps the workflow
human-supervised. It does not create or manage Git worktrees, run a custom
orchestration runtime, or maintain durable state outside `.agent-workflow/`.

Shipped in this version:

- An architect agent that owns the design, checks capability, and issues slices.
- A slice-based feedback loop: the orchestrator reports, the architect decides
  whether the design holds.
- A durable workflow directory, so state survives a context reset.
- A dependency-free capability check over harness locations and instruction files.
- Functional requirements as identifiers, traced from design to slice to task.
- Risk tiers and a gate matrix, so ceremony is decided by rules rather than mood.
- Two targeted research tasks may run concurrently, with disjoint questions and
  path scopes. This is the safe half of parallel execution: read-only, no shared
  write scope, no worktree.
- Design review and plan review by the reviewer at T2 and above.
- Decision records and a risk register.
- Diff-identity binding and tree fingerprints.
- Integration and commit rules owned by the orchestrator.

Deliberately deferred:

- Parallel implementation with Git worktrees, branch ownership, and conflict
  handling.
- Dependencies on `delivery/implementation-plan` and `code-quality/code-review`.
  The overlap is intentional for now so the plugin installs and behaves on its
  own. These become package dependencies once the six artefacts have survived two
  real runs without a shape change; that is the definition of settled.
- Dynamic task orchestration, retries beyond two rounds, and telemetry.

## Troubleshooting

**Q: The architect is asking me to run a specialist myself.**
A: The current harness does not support automatic delegation. The handoff is
manual by design; paste the specialist's result back to continue.

**Q: I started the orchestrator directly and it stopped.**
A: It declared itself unable to continue. The orchestrator is a subagent with no
channel to you, so it cannot obtain plan, slice, or integration approval. Start a
new conversation with the architect selected as the primary agent.

**Q: The architect says it cannot proceed because it is a subagent.**
A: It was invoked from another agent's session. Approval gates need your own
session; start a new conversation with the architect selected.

**Q: The `.agent-workflow` directory got committed.**
A: That is a defect. The contents are local state, not a deliverable. Remove them
from the index, confirm `.agent-workflow/` is in `.gitignore` or
`.git/info/exclude`, and note that this is exactly what the directory check exists
to prevent.

**Q: How much ceremony should a small change get?**
A: T0 or T1. A documentation fix needs no design approval or independent review; a
contained behaviour change needs a short design and a review. The tier decides, and
the architect states it.

**Q: Do I have to approve every task?**
A: No. You approve the design and each slice. Routine reversible work inside a
slice proceeds without further approval. Integration approval applies at T2 and
above.

**Q: The reviewer is asking me to approve a test command.**
A: The reviewer is read-only for files, but shell approval belongs to you. Approve
test, lint, and build commands; deny anything that writes to the tree.

**Q: Only the architect appears in the agent picker.**
A: That is intended. The specialists declare `mode: subagent` so they are
delegated rather than selected. In Copilot, where `mode` has no effect, do not
select them directly for workflow work.

**Q: A read-only agent changed a file.**
A: Treat it as a boundary violation. The tree fingerprint will differ, the result
is rejected, and the reviewed state is restored before continuing.

**Q: Why can the architect and orchestrator write anywhere?**
A: Because per-agent write scopes cannot be expressed reliably in OpenCode
frontmatter. Their scopes — `.agent-workflow/design.md` and
`.agent-workflow/**` plus Git operations respectively — are enforced by their own
instructions and checked by the tree fingerprint. See "Why write scopes are not
enforced by permission".

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
