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
target with `glob` and `read` — `.github/skills/`, `.github/agents/`,
`.github/instructions/`, `.agents/skills/`, `.claude/skills/`, `.claude/agents/`,
`.opencode/skills/`, `.opencode/agents/`, `.cursor/`, `.windsurf/`, `.kiro/`,
`.grok/`, `.codex/`, `.gemini/` — and reads the instruction files that frequently
document the skills and agents a project expects to be used: `AGENTS.md` at the
root and in nested directories, `.github/copilot-instructions.md`,
`.github/instructions/*.md`, `CLAUDE.md`, `GEMINI.md`, and the repository
`README.md`. It reads `apm.yml` and `apm.lock.yaml` for declared dependencies.

Third-party packages are inspected through what they ship, not by executing them:
the `.xml` documentation beside the `.dll`, the `.nuspec`, and the consumer's
`project.assets.json`. Reflection is reserved for packages with no documentation,
run through a committed inspection script rather than an interactive probe.

The result is recorded in `design.md` as a capability map, with each capability
tied to the requirement it serves and its source. A requirement with no available
capability is either handled directly by the orchestrator or escalated. It is
never met by a capability that was not observed, and a capability that exists but
serves no requirement is recorded and left unused.

## Harness Support

Verified against APM 0.30.0, OpenCode 2.2.6, and the current harness
documentation:

| Capability                                        | Status                                                                                 |
| ------------------------------------------------- | -------------------------------------------------------------------------------------- |
| Agent deployment via `apm install` (Copilot)      | **Verified** — agents land in `.github/agents/*.agent.md`                              |
| Agent deployment via `apm install` (OpenCode)     | **Verified** — agents land in `.opencode/agents/*.md`                                  |
| Agent frontmatter validation                      | **Verified** — `apm compile --validate` accepts all five                               |
| Automatic delegation (OpenCode subagent sessions) | **Verified** — supported by the harness                                                |
| Nested delegation (orchestrator → specialist)     | **Expected** — `subagent` allow-list; not verified end-to-end                          |
| Automatic delegation (Copilot CLI)                | **Expected** — via the `agents` allow-list; not verified end-to-end                    |
| Primary/subagent separation (OpenCode `mode`)     | **Verified** — `opencode debug agents` resolves primary/subagent                       |
| Edit-tool enforcement (OpenCode `permissions`)    | **Verified** — `edit: deny` resolves; shell writes are outside it                      |
| Architect shell grant (OpenCode)                  | **Verified** — broad shell with write asks; `opencode debug agents` resolves the order |
| Scoped writes (OpenCode, scalar deny + allow)     | **Verified** — probe agent wrote in scope, out of scope rejected                       |
| Policy hard denies (OpenCode `policies`)          | **Verified** — `git push` and `git -C . push` both blocked                             |
| Nested delegation by specialists (OpenCode)       | **Verified** — `subagent: deny` resolves for each specialist                           |
| Read-only enforcement (Copilot)                   | **Not enforced** — instructions plus detection only                                    |
| Architect refuses delegated use                   | **Enforced in OpenCode** by `mode: primary`; instruction in Copilot                    |
| Orchestrator refuses non-architect delegation     | **Instruction only** — `question: deny` removes the user channel                       |

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
`permissions`. The last matching rule wins, so a catch-all sits first and every
exception after it.

| Agent        | Edit                                            | Question | Subagents                               | Shell                                   |
| ------------ | ----------------------------------------------- | -------- | --------------------------------------- | --------------------------------------- |
| architect    | `.agent-workflow/*` and `.gitignore`; else deny | allow    | researcher, reviewer, orchestrator only | broad shell, writes ask (recommended)   |
| orchestrator | allow                                           | deny     | researcher, implementer, reviewer only  | global rules; Git grants recommended    |
| implementer  | allow                                           | deny     | none                                    | global rules; blanket grant recommended |
| researcher   | deny                                            | deny     | none                                    | global rules, native-tool method        |
| reviewer     | deny                                            | deny     | none                                    | global rules, native-tool method        |

`global rules` means the agent declares no shell rule and inherits whatever the
harness configured. Shell approval policy belongs to the person running the
harness: agent rules are appended after global rules and the last match wins, so a
blanket `shell *: ask` here would silently override every shell allow the user
configured, and a blanket `shell *: allow` would give every agent an unprompted
shell regardless of the user's policy. Roles that need one are configured in the
harness instead — see [Per-agent shell grants](#per-agent-shell-grants).

The architect is the one role where a harness grant is recommended rather than
optional. Its discovery work is open-ended, and a prefix allowlist cannot cover an
idiom the agent invents. That grant is a trust-and-audit posture, not a read-only
guarantee; see [Trust and audit](#trust-and-audit-the-architects-shell).

It is also the only role with a declared write scope. It records design artefacts
and must not turn design work into implementation, so it denies `edit` and
re-grants one directory. The rules are scalar — a catch-all deny followed by a
prefix allow — which is the form OpenCode honours. The plan directory is
re-granted for the same reason: the agent's own deny is evaluated after the global
permissions, so leaving it out would revoke a path the harness already allows.

### Required shell policy (OpenCode)

The agents rely on the harness for shell approval. Install these hard denies once
in your user or project configuration, as policies rather than permissions, so
that an agent or a project file cannot lift them. Policies are evaluated after
permissions, agent rules and saved approvals, and they never prompt.

```jsonc
{
  "policies": [
    // Remote side effects.
    { "action": "tool.use", "resource": "shell:*git push *", "effect": "deny" },
    {
      "action": "tool.use",
      "resource": "shell:*git * push *",
      "effect": "deny",
    },
    {
      "action": "tool.use",
      "resource": "shell:*git send-pack *",
      "effect": "deny",
    },
    {
      "action": "tool.use",
      "resource": "shell:*gh pr merge *",
      "effect": "deny",
    },
    {
      "action": "tool.use",
      "resource": "shell:*gh * delete *",
      "effect": "deny",
    },
    // Irreversible local loss.
    {
      "action": "tool.use",
      "resource": "shell:*git reset --hard*",
      "effect": "deny",
    },
    {
      "action": "tool.use",
      "resource": "shell:*git clean -f*",
      "effect": "deny",
    },
    { "action": "tool.use", "resource": "shell:*rm -rf *", "effect": "deny" },
    { "action": "tool.use", "resource": "shell:*rm -fr *", "effect": "deny" },
    {
      "action": "tool.use",
      "resource": "shell:*Remove-Item*-Recurse*",
      "effect": "deny",
    },
    // Infrastructure teardown.
    {
      "action": "tool.use",
      "resource": "shell:*terraform apply*",
      "effect": "deny",
    },
    {
      "action": "tool.use",
      "resource": "shell:*terraform destroy*",
      "effect": "deny",
    },
    {
      "action": "tool.use",
      "resource": "shell:*az * delete*",
      "effect": "deny",
    },
    // Secrets, through both tools.
    { "action": "tool.use", "resource": "edit:*.env*", "effect": "deny" },
    {
      "action": "tool.use",
      "resource": "edit:*.env.example",
      "effect": "allow",
    },
    { "action": "tool.use", "resource": "shell:*.env", "effect": "deny" },
    { "action": "tool.use", "resource": "shell:*.env.*", "effect": "deny" },
    {
      "action": "tool.use",
      "resource": "shell:*.env.example",
      "effect": "allow",
    },
    // MCP tools: the base policy allows them outright, so only a policy stops them.
    { "action": "tool.use", "resource": "*_delete_*:*", "effect": "deny" },
    { "action": "tool.use", "resource": "github_merge_*:*", "effect": "deny" },
  ],
}
```

Three matching rules decide whether a pattern works, and each has caught a real
hole:

- `*` matches zero or more characters **including spaces**, so `shell:git push *` covers both
  `git push` and `git push origin main`.
- A wildcard in the middle needs something to consume. `shell:git * push *`
  matches `git -C repo push` but **not** `git push`, because the literal
  `push` requires a character before it. Use both forms: an anchored pattern for
  the bare command, a mid-`*` pattern for wrapped invocations.
- Policy resources do not expand `~`. Permissions do, policies do not, so a
  `~/.config/...` statement silently matches nothing. Use a literal path or a
  suffix pattern, and check the server log after editing — a statement that fails
  validation is dropped with a warning while the rest still applies.

Prefixing a pattern with `*` catches wrapped commands (`sudo git push`,
`env FOO=1 git push`), which is why the local-loss patterns start that way. The
same prefix is unnecessary where the literal already contains the spaces.

Without these, the agents inherit the harness defaults: permissive on a stock
OpenCode install, and instruction plus fingerprint only on Copilot.

### Per-agent shell grants

The agent files declare no shell rules, so each role inherits the user's policy.
Three roles are more useful with an explicit grant, because their work is
dominated by commands that would otherwise prompt on every call: the architect
discovers, the implementer runs builds and tests, and the orchestrator
integrates. Configure them in the harness, not in the agent files, so that a
plugin upgrade cannot remove them and a shared plugin does not loosen anyone
else's shell policy.

```jsonc
{
  "agents": {
    "architect": {
      "permissions": [
        { "action": "shell", "resource": "*", "effect": "allow" },
        { "action": "shell", "resource": "git add *", "effect": "ask" },
        { "action": "shell", "resource": "git commit *", "effect": "ask" },
        { "action": "shell", "resource": "git switch *", "effect": "ask" },
        { "action": "shell", "resource": "git checkout *", "effect": "ask" },
        { "action": "shell", "resource": "git reset *", "effect": "ask" },
        { "action": "shell", "resource": "git restore *", "effect": "ask" },
        { "action": "shell", "resource": "git stash *", "effect": "ask" },
        { "action": "shell", "resource": "Set-Content *", "effect": "ask" },
        { "action": "shell", "resource": "Add-Content *", "effect": "ask" },
        { "action": "shell", "resource": "Out-File *", "effect": "ask" },
        { "action": "shell", "resource": "New-Item *", "effect": "ask" },
        { "action": "shell", "resource": "Remove-Item *", "effect": "ask" },
        { "action": "shell", "resource": "Move-Item *", "effect": "ask" },
        { "action": "shell", "resource": "Copy-Item *", "effect": "ask" },
        { "action": "shell", "resource": "Rename-Item *", "effect": "ask" },
        { "action": "shell", "resource": "Tee-Object *", "effect": "ask" },
      ],
    },
    "implementer": {
      "permissions": [
        { "action": "shell", "resource": "*", "effect": "allow" },
        { "action": "shell", "resource": "git commit *", "effect": "ask" },
        { "action": "shell", "resource": "git reset *", "effect": "ask" },
        { "action": "shell", "resource": "git clean *", "effect": "ask" },
        { "action": "shell", "resource": "git restore *", "effect": "ask" },
        { "action": "shell", "resource": "git checkout -- *", "effect": "ask" },
        { "action": "shell", "resource": "git rebase *", "effect": "ask" },
        { "action": "shell", "resource": "git branch -D *", "effect": "ask" },
        { "action": "shell", "resource": "git stash drop *", "effect": "ask" },
      ],
    },
    "orchestrator": {
      "permissions": [
        { "action": "shell", "resource": "git add *", "effect": "allow" },
        { "action": "shell", "resource": "git commit *", "effect": "allow" },
        { "action": "shell", "resource": "git switch *", "effect": "allow" },
        { "action": "shell", "resource": "git reset *", "effect": "ask" },
        { "action": "shell", "resource": "git clean *", "effect": "ask" },
        { "action": "shell", "resource": "git rebase *", "effect": "ask" },
      ],
    },
  },
}
```

Order matters: the blanket allow comes first and the narrower `ask` rules after
it, because the last matching rule wins. `git push` never prompts — it is denied
by the policy above. The architect's write asks are speed bumps, not a boundary:
`[IO.File]::WriteAllText` and redirection bypass them. The boundary is the policy
layer plus the audit in
[Trust and audit](#trust-and-audit-the-architects-shell).

### Read-only enforcement

There is no single frontmatter that both harnesses enforce, so the write boundary
is layered. The first four layers constrain writes; the fifth is an audit layer
for the architect, which needs broad shell for discovery.

| Layer | Mechanism                                                                                                          | Applies to |
| ----- | ------------------------------------------------------------------------------------------------------------------ | ---------- |
| L1    | Instruction boundary, plus the requirement to report any write attempted                                           | Both       |
| L2    | OpenCode `permissions`: `edit: deny`, `subagent: deny`, `question: deny`; this scopes the edit tool, not the shell | OpenCode   |
| L3    | OpenCode `policies`: hard denies that no agent rule or saved approval can lift                                     | OpenCode   |
| L4    | Tree fingerprint before dispatch and after return; a difference rejects the result                                 | Both       |
| L5    | Trust and audit for the architect: broad shell, write commands ask, fingerprint at slice approval                  | OpenCode   |
| L6    | Documented limitation                                                                                              | Copilot    |

The fingerprint is `git status --porcelain=v1`, the diff identity, and a hash of
each untracked file. It does not prevent a write; it makes one visible and
attributable. That is the achievable guarantee for a harness without a read-only
subagent mode.

### Trust and audit (the architect's shell)

`edit: deny` does not make an agent read-only. The shell is a write primitive, and
a prefix allowlist cannot cover commands an agent invents. The researcher and
reviewer stay on the user's allowlist, and their native-tool method keeps them
inside it. The implementer's grant is broad but bounded by asks on the Git verbs
that rewrite work. The architect needs the broadest grant because its discovery
work is open-ended, and every new PowerShell idiom becomes a new permission
resource.

The recommended grant therefore trusts the architect with shell and makes the
irreversible cases visible:

- The policy layer still denies remote side effects, history rewrites, and secret
  access, and no agent rule can lift those.
- Write-shaped commands (`Set-Content`, `Out-File`, `New-Item`, `Remove-Item`,
  and the Git write verbs) prompt.
- The architect records a tree fingerprint at design start, before dispatch, and
  at slice approval, so a shell write is attributable even when it was not
  prevented.

That is an audit boundary, not a prevention boundary. The asks can be bypassed
and the fingerprint is post-hoc. If you need prevention, keep the architect on the
narrow allowlist and accept that discovery will prompt; do not describe the result
as read-only under either configuration.

### Why only one write scope is enforced by permission

OpenCode documents a path-scoped form for `edit`:

```yaml
edit:
  "*": deny
  "src/**": allow
```

That object form does not work. A top-level wildcard in the object is not
overridden by a named-key rule, and patterns are matched as simple wildcards
against the Git worktree root rather than the launch directory. The scalar form
does work, and is verified against the current harness:

```yaml
permissions:
  - action: edit
    resource: "*"
    effect: deny
  - action: edit
    resource: ".agent-workflow/*"
    effect: allow
```

A probe agent carrying exactly those two rules wrote `.agent-workflow/ok.md` and
was denied `root.md` with `permission.rejected`. Because `*` spans path
separators, one prefix covers the whole subtree.

Only the architect uses this, because its boundary is a single directory. The
orchestrator and implementer write across the repository, where a multi-path scope
is still not expressible: they take `edit: "*" → allow` and rely on the
instruction boundary plus the tree fingerprint. Read-only agents are unaffected —
total denial is reliable. Note also that an `edit` rule governs the edit tool
only: a write performed through a shell command is not covered by it. The
fingerprint layer and the shell policy exist to catch that, and the architect's
configuration is discussed in
[Trust and audit](#trust-and-audit-the-architects-shell).

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

## Companion packages

The plugin is deliberately domain-neutral. Its agents hold process, not technology
knowledge, and a skill that names a framework or a package manager would date the
plugin and burden every install. Technology capabilities ship as separate packages
installed alongside it:

```bash
apm install agent-workflow@awesome-ai --target opencode
apm install <technology>@awesome-ai --target opencode
```

The capability check enumerates deployed skills and reads `apm.lock.yaml`, so a
companion appears in the capability map when it is installed and is absent
otherwise. Neither package depends on the other, which keeps the process plugin
installable on its own and the technology plugin usable by any agent.

A companion skill is a procedure, not a bundled tool. It should prefer the native
tools and the artefacts a technology ships; a script earns its place only where no
readable artefact exists. Skills are loaded on demand, so the description carries
the discovery burden: name the technology and the question it answers, and avoid
overlap with the process skills.

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
- A dependency-free capability check over harness locations and instruction
  files, run with the native tools.
- Native-tool-first discovery, with shell reserved for Git, builds, tests, and
  hashes.
- A trust-and-audit posture for the architect's shell, with write asks and tree
  fingerprints.
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
A: The reviewer is read-only for files, and it should inspect with `read` and
`grep` rather than shell. Shell approval still belongs to you: approve test, lint,
and build commands; deny anything that writes to the tree.

**Q: The architect prompts on every new PowerShell idiom. Why?**
A: OpenCode splits a compound command into one permission resource per
sub-command, method call, and script-block body. `$t.GetMethods()` and the body of
`ForEach-Object` are each a resource, and "always allow" saves the literal text,
so the next script with a different variable name prompts again. Use the native
tools for discovery and keep shell to Git, builds, tests, and hashes. If discovery
is genuinely open-ended, apply the architect grant in
[Per-agent shell grants](#per-agent-shell-grants).

**Q: Should I give the architect a blanket shell allow?**
A: That is the trust-and-audit posture in
[Trust and audit](#trust-and-audit-the-architects-shell). It removes the prompt
storm, keeps the hard policies, and makes writes ask. It does not make the
architect read-only: a shell write is possible, and the tree fingerprint is what
makes it visible. If you need prevention rather than audit, keep the narrow
allowlist.

**Q: The architect wants to load a .NET assembly to inspect an API.**
A: It should not. The `.xml` documentation beside the `.dll` documents the public
members, and the `.nuspec` and `project.assets.json` describe the package. Read
those with `read`. Reflection is a last resort for packages that ship no
documentation, and belongs in a committed script rather than an interactive probe.

**Q: Can I install a technology skill alongside this plugin?**
A: Yes. This plugin is deliberately domain-neutral; technology capabilities ship
as separate packages. The capability check enumerates deployed skills and reads
`apm.lock.yaml`, so a companion appears in the map when installed and is simply
absent when not. There is no hard dependency in either direction.

**Q: Only the architect appears in the agent picker.**
A: That is intended. The specialists declare `mode: subagent` so they are
delegated rather than selected. In Copilot, where `mode` has no effect, do not
select them directly for workflow work.

**Q: A read-only agent changed a file.**
A: Treat it as a boundary violation. The tree fingerprint will differ, the result
is rejected, and the reviewed state is restored before continuing.

**Q: Can any agent write anywhere?**
A: The orchestrator and implementer can, because their write scope spans the
repository and a multi-path scope cannot be expressed in OpenCode frontmatter.
The architect is scoped to `.agent-workflow/` by the edit permission — a scalar
`edit` deny followed by a prefix allow, which the harness enforces — plus the plan
directory when it runs in plan mode. Under the recommended grant the architect can
also write through shell; that is an audit boundary, not a permission scope, and
the tree fingerprint is what makes it visible. See
[Trust and audit](#trust-and-audit-the-architects-shell) and "Why only one write
scope is enforced by permission".

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
