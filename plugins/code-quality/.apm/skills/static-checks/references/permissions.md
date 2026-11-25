# Static Check Permissions

This reference turns the catalogue into harness configuration: it shows how to
pre-approve the read-only commands and gate the write commands, so agents stop
raising approval prompts for checks without gaining unattended write access.

Audience: the consumer configuring a project, or an assistant asked to set up
permissions. This is configuration guidance, not runtime agent instruction. The
agent's behaviour comes from `SKILL.md` and the harness's own enforcement.

## Principles

- Pre-approve the read-only column. Leave write variants prompting.
- Keep every pattern tool-scoped. `npx *` and `uvx *` allow arbitrary package
  execution from the registry; a tool-scoped prefix does not.
- Include the mode segment in read-only patterns where the write variant is
  distinguishable (`npx -y prettier --check *`), so an allowed rule cannot
  cover a write.
- Where the write variant differs from the read-only command only by a flag
  that a read-only prefix would also match (`eslint <scope> --fix`,
  `ruff check <scope> --fix`, `markdownlint-cli <scope> --fix`), write an
  explicit prompt rule after the allowed rule when rules are ordered, or leave
  the tool prompting when they are not.
- Where the flag sits at a fixed position before the scope
  (`biome lint --write <scope>`, `zizmor --fix <scope>`), a later ask rule
  anchored at that prefix separates the write cleanly.
- A recipe is only meaningful relative to the default. These examples assume a
  catch-all prompt for shell commands. Where an agent's default is a broad
  allow, every write variant needs its own explicit prompt or deny rule.
- Patterns stay valid as scopes change because the catalogue's invocations are
  prefix-stable: the tool, mode and flag segment is fixed and only the scope
  argument varies.
- A pattern cannot express the catalogue's `<scope>` placeholder: the pattern
  engines match literal text and wildcards only. The agent resolves the
  placeholder; the `*` in a pattern covers every resolution.

## OpenCode

Verified on OpenCode v2.4.1 with `opencode debug config`. Shell permissions
are `{action, resource, effect}` entries in an ordered list; the last matching
rule wins. The resource is a pattern over the full command string. Configure
them in `~/.config/opencode/opencode.jsonc` (global) or in a project config
file.

```jsonc
{
  "permissions": [
    { "action": "shell", "resource": "*", "effect": "ask" },

    // Read-only column: pre-approved.
    {
      "action": "shell",
      "resource": "npx -y prettier --check *",
      "effect": "allow",
    },
    { "action": "shell", "resource": "npx -y eslint *", "effect": "allow" },
    {
      "action": "shell",
      "resource": "npx -y @biomejs/biome format --check *",
      "effect": "allow",
    },
    {
      "action": "shell",
      "resource": "npx -y @biomejs/biome lint *",
      "effect": "allow",
    },
    {
      "action": "shell",
      "resource": "uvx ruff format --check *",
      "effect": "allow",
    },
    { "action": "shell", "resource": "uvx ruff check *", "effect": "allow" },
    { "action": "shell", "resource": "uvx black --check *", "effect": "allow" },
    {
      "action": "shell",
      "resource": "dotnet format *--verify-no-changes*",
      "effect": "allow",
    },
    { "action": "shell", "resource": "gofmt -l *", "effect": "allow" },
    { "action": "shell", "resource": "go vet *", "effect": "allow" },
    {
      "action": "shell",
      "resource": "terraform fmt -check *",
      "effect": "allow",
    },
    {
      "action": "shell",
      "resource": "terraform validate*",
      "effect": "allow",
    },
    {
      "action": "shell",
      "resource": "uvx --from checkov checkov *",
      "effect": "allow",
    },
    { "action": "shell", "resource": "npx -y cspell *", "effect": "allow" },
    {
      "action": "shell",
      "resource": "npx -y markdownlint-cli *",
      "effect": "allow",
    },
    { "action": "shell", "resource": "uvx zizmor *", "effect": "allow" },
    {
      "action": "shell",
      "resource": "apm audit --file *",
      "effect": "allow",
    },
    {
      "action": "shell",
      "resource": "apm marketplace check*",
      "effect": "allow",
    },
    {
      "action": "shell",
      "resource": "apm pack --check-versions --check-clean --dry-run",
      "effect": "allow",
    },

    // Trailing-flag write variants: the read-only prefix above would also
    // match these, so each needs a later prompt rule.
    { "action": "shell", "resource": "npx -y eslint *--fix*", "effect": "ask" },
    {
      "action": "shell",
      "resource": "uvx ruff check *--fix*",
      "effect": "ask",
    },
    {
      "action": "shell",
      "resource": "npx -y markdownlint-cli *--fix*",
      "effect": "ask",
    },

    // Fixed-position write flags: the ask rule anchors at the flag.
    {
      "action": "shell",
      "resource": "npx -y @biomejs/biome lint --write *",
      "effect": "ask",
    },
    { "action": "shell", "resource": "uvx zizmor --fix *", "effect": "ask" },
  ],
}
```

Distinct write forms (`npx -y prettier --write`, `uvx black`, `gofmt -w`,
`dotnet format`) need no explicit rule: no allowed pattern covers them, so
they inherit the catch-all prompt. If a mid-string `*` pattern is not honoured
by the installed version, drop the broad read-only rule and let the prompt
cover every variant; with a variable scope there is no exact canonical command
to fall back to.

`--from` forms are matched at their full prefix, as in
`uvx --from checkov checkov *`. The package segment is part of the tool
identity, so never allow `uvx --from *`, which would permit any package to
supply any executable.

Terraform's write form is distinguished by the absence of `-check`, so
`terraform fmt -check *` cannot cover it. A broad `terraform fmt *` allow does
cover it, so keep the mode segment and avoid the broad form. `terraform
validate` takes no argument, so `terraform validate*` covers the bare command.

markdownlint's read-only form carries no distinguishing flag, so its allow
needs the trailing-flag ask rule above, because `--fix` trails the scope.
zizmor's fix flag sits at a fixed position before the scope, so its ask rule
anchors there. cspell is the exception where a broad tool prefix is safe,
because it has no fix mode.

The APM rows need no prompt rules: `apm audit --file`,
`apm marketplace check` and `apm pack --check-versions --check-clean --dry-run`
have no write mode. `apm pack` without the gates does write, so the allow is
the exact gate command, never an `apm pack *` prefix. `apm marketplace
validate` is deliberately absent: it validates a registered consumer
marketplace by name, not the working tree.

For a permanent veto on agent writes, add a policy. Policies are a separate
deny layer that outranks permissions, and a permission allow cannot rescue
them:

```jsonc
{
  "policies": [
    {
      "action": "tool.use",
      "resource": "shell:*prettier --write*",
      "effect": "deny",
    },
  ],
}
```

## Claude Code

Documented prefix syntax is `Bash(<command prefix>:*)` in
`~/.claude/settings.json` or a project `.claude/settings.json`. Verify the
effective precedence of `allow`, `ask`, and `deny` in the installed version
before relying on the interplay.

```json
{
  "permissions": {
    "allow": [
      "Bash(npx -y prettier --check:*)",
      "Bash(uvx ruff format --check:*)",
      "Bash(gofmt -l:*)",
      "Bash(terraform fmt -check:*)",
      "Bash(apm pack --check-versions --check-clean --dry-run)",
      "Bash(apm marketplace check:*)",
      "Bash(apm audit --file:*)"
    ]
  }
}
```

Prefix matching anchors only the start of the command, so it separates a write
form only when the write differs at a fixed position before the scope:
prettier's `--check` versus `--write` is the clean case. Tools whose fix flag
trails the scope (ESLint `--fix`, Ruff check `--fix`, markdownlint `--fix`) or
whose read-only flag trails it (`dotnet format --verify-no-changes`) cannot be
pre-approved safely once the scope varies. Leave them prompting; do not widen
any of them to a bare `Bash(npx -y eslint:*)` or `Bash(dotnet format:*)`
prefix.

## GitHub Copilot CLI

Not yet verified. The CLI exposes tool permission flags, but the exact shell
pattern syntax and its precedence against prompts must be confirmed against
the installed version's help output and configuration documentation before any
pattern here is used. Until confirmed, rely on the OpenCode recipe and on
runtime approval for Copilot.

## Maintaining the recipe

When the catalogue gains a row, add one read-only rule. Add a prompt rule only
when the read-only prefix would also match the write form. Match the rule shape
to the row's scope: a `root` row takes an exact rule, while a scoped row takes
a trailing `*`, because the agent resolves the scope at runtime. Keep consumer
configuration limited to tools the project actually uses; an unused rule is
only permanent permission debt.
