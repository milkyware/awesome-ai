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
- Where the write variant differs from the read-only command only by a trailing
  flag that a read-only prefix would also match (`eslint . --fix`,
  `ruff check . --fix`), write an explicit prompt rule after the allowed rule
  when rules are ordered, or narrow the allowed rule to the exact canonical
  command when they are not.
- A recipe is only meaningful relative to the default. These examples assume a
  catch-all prompt for shell commands. Where an agent's default is a broad
  allow, every write variant needs its own explicit prompt or deny rule.
- Patterns stay valid as paths change because the catalogue's commands are
  prefix-stable: the tool and mode segment is fixed and only trailing paths
  vary.

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
      "resource": "dotnet format --verify-no-changes *",
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
      "resource": "terraform validate *",
      "effect": "allow",
    },
    {
      "action": "shell",
      "resource": "uvx --from checkov checkov *",
      "effect": "allow",
    },

    // Trailing-flag write variants: the read-only prefix above would also
    // match these, so each needs a later prompt rule.
    { "action": "shell", "resource": "npx -y eslint *--fix*", "effect": "ask" },
    {
      "action": "shell",
      "resource": "npx -y @biomejs/biome lint *--write*",
      "effect": "ask",
    },
    {
      "action": "shell",
      "resource": "uvx ruff check *--fix*",
      "effect": "ask",
    },
  ],
}
```

Distinct write forms (`npx -y prettier --write`, `uvx black .`, `gofmt -w`,
`dotnet format --no-restore`) need no explicit rule: no allowed pattern covers
them, so they inherit the catch-all prompt. If a mid-string `*` pattern is not
honoured by the installed version, replace the broad read-only rule with the
exact canonical command (`npx -y eslint .`) and let the prompt cover variants.

`--from` forms are matched at their full prefix, as in
`uvx --from checkov checkov *`. The package segment is part of the tool
identity, so never allow `uvx --from *`, which would permit any package to
supply any executable.

Terraform's write form is distinguished by the absence of `-check`, so
`terraform fmt -check *` cannot cover it. A broad `terraform fmt *` allow does
cover it, so keep the mode segment and avoid the broad form.

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
      "Bash(npx -y eslint .)",
      "Bash(uvx ruff check:*)",
      "Bash(dotnet format --verify-no-changes:*)"
    ]
  }
}
```

Prefix matching cannot separate a trailing `--fix` from path arguments. Allow
ESLint only in its exact canonical form and let scoped variants and fixes
prompt; do not widen it to `Bash(npx -y eslint:*)`.

## GitHub Copilot CLI

Not yet verified. The CLI exposes tool permission flags, but the exact shell
pattern syntax and its precedence against prompts must be confirmed against
the installed version's help output and configuration documentation before any
pattern here is used. Until confirmed, rely on the OpenCode recipe and on
runtime approval for Copilot.

## Maintaining the recipe

When the catalogue gains a row, add one read-only rule. Add a prompt rule only
when the read-only prefix would also match the write form. Keep consumer
configuration limited to tools the project actually uses; an unused rule is
only permanent permission debt.
