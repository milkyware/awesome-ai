# Static Check Catalogue

Canonical invocations for the formatters, linters and static validators this
skill runs. Each row fixes the runner, tool, mode and flags; only the `<scope>`
placeholder varies. Use the `Detect by` column to identify the tool, then copy
the `Read-only` or `Write` invocation verbatim, substituting `<scope>` by the
rules in [Scope resolution](#scope-resolution).

## Column contract

- `Read-only` is the proof and reporting command. Its result counts as
  evidence.
- `Write` is the correction command. It is never evidence; the read-only
  re-run after it is.
- `Fix class` is `safe` when the write command is idempotent and
  semantics-preserving, or `classified` when the tool has fix classes, applies
  only safe fixes by default, or can change behaviour.
- `Scope` is the granularity `<scope>` must take. It records the narrowest
  target the tool accepts, so a task narrower than the scope runs at the
  owning unit rather than failing.
- `Notes` records the failure signal: whether the read-only command exits
  non-zero, exits zero and lists paths, or prints a findings report.

## Runner rule

- `npx -y` runs npm packages. `-y` suppresses the first-fetch prompt, which an
  agent cannot answer.
- `uvx` runs PyPI packages. It never prompts and resolves the latest version in
  an ephemeral environment.
- When the executable name differs from the package name, name the package
  explicitly: `uvx --from <package> <executable>` (for example
  `uvx --from checkov checkov -d <scope>`). The `--from` package is unpinned
  like every other canonical command, and the offline retry becomes
  `uvx --offline --from <package> <executable>`.
- npm has the same shape: `npx -y -p <package> <executable>` when the binary
  name differs from the package name.
- Toolchain-shipped tools run as direct binaries: `dotnet format`, `gofmt`,
  `go vet`, `terraform`, `apm`.
- When a Python tool is a project dependency (`uv.lock`, `pyproject.toml`),
  prefer `uv run <tool>` so the version matches the project configuration.
- Never pin a version in a canonical command. `npx` resolves the project's
  local install first; project guidance pins where a pin matters.
- If a runner cannot fetch or update the tool, retry once with `--offline`. An
  empty cache means the tool is unavailable: report `blocked`.
- Other runners (`pnpm dlx`, `bunx`, `poetry run`) are project overrides, not
  canon.

Project guidance overrides every row.

## Scope resolution

Resolve `<scope>` to the narrowest target that covers the task, in this order
of precedence:

1. The paths the task brief names.
2. The paths in the working-tree change set the task owns, when it names none.
3. The whole-tree form, when the task is repository-wide or no narrower target
   exists.

Match that target to the detected tool's `Scope` granularity:

| Scope       | Substitution                                                                   |
| ----------- | ------------------------------------------------------------------------------ |
| `file`      | One file path.                                                                 |
| `paths`     | The paths directly: files, directories or quoted globs, as separate arguments. |
| `directory` | The common ancestor directory of the scoped paths.                             |
| `project`   | The `.csproj` or `.sln` that owns the scoped paths.                            |
| `packages`  | A Go package pattern: `./...` at the root, otherwise `./<directory>/...`.      |
| `module`    | No argument; the module directory becomes the working directory.               |
| `root`      | Run from the repository root; never narrow these commands.                     |

Whole-tree forms are `.` for `paths` and `directory`, `./...` for `packages`,
the module directory for `module`, and the repository root for `root`.

Substituting `<scope>` is not composition: everything around it is copied
verbatim, and quoting a glob or a path with spaces stays inside the single
command string.

## Catalogue

| Tool                    | Detect by                                                       | Read-only                                                 | Write                                          | Fix class  | Scope     | Notes                                                                                                                                                                                                                                                                                                                   |
| ----------------------- | --------------------------------------------------------------- | --------------------------------------------------------- | ---------------------------------------------- | ---------- | --------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| APM audit               | `.apm/` primitives or root `apm.yml`                            | `apm audit --file <scope>`                                | —                                              | classified | file      | Scans one file for hidden Unicode, drift and policy violations. Read-only unless `--strip` is passed; `--strip` is a correction and must be named in the brief. Exits non-zero when findings exist.                                                                                                                     |
| APM marketplace (check) | root `apm.yml` with a `marketplace:` block                      | `apm marketplace check --offline`                         | —                                              | classified | root      | Validates the marketplace block against cached refs: schema, entry resolution and version/ref agreement, without network access. Drop `--offline` to reach the remote, which needs network access and authentication.                                                                                                   |
| APM pack gates          | root `apm.yml` with a `marketplace:` block                      | `apm pack --check-versions --check-clean --dry-run`       | —                                              | classified | root      | In-situ validation without a registered marketplace: parses every plugin manifest, checks tag-pattern alignment and regenerates marketplace outputs to a temporary representation to diff against the committed file. Exit 1 is a build or schema error, 3 version misalignment, 4 marketplace drift. Always read-only. |
| Biome (format)          | `biome.json`, `biome.jsonc`                                     | `npx -y @biomejs/biome format --check <scope>`            | `npx -y @biomejs/biome format --write <scope>` | safe       | paths     | Format mode only. Lint subcommands are listed separately.                                                                                                                                                                                                                                                               |
| Biome (lint)            | `biome.json`, `biome.jsonc`                                     | `npx -y @biomejs/biome lint <scope>`                      | `npx -y @biomejs/biome lint --write <scope>`   | classified | paths     | `--write` applies safe fixes only. `--unsafe` is opt-in and must be named in the brief.                                                                                                                                                                                                                                 |
| Black                   | `pyproject.toml` `[tool.black]` or a `black` dependency         | `uvx black --check <scope>`                               | `uvx black <scope>`                            | safe       | paths     | Prefer `uv run black` when Black is a project dependency. `--diff` shows changes without writing.                                                                                                                                                                                                                       |
| Checkov                 | `*.tf` files or a `terraform/` directory                        | `uvx --from checkov checkov -d <scope> --compact --quiet` | —                                              | classified | directory | Security and compliance scanner; `-d` takes one directory, so a scoped run uses the owning directory. `--quiet` suppresses passed checks and `--compact` suppresses code blocks in the findings report. Exits non-zero when checks fail. Report only; no automatic fixes.                                               |
| cspell                  | `cspell.config.yaml`, `cspell.json`, or a `cspell` dependency   | `npx -y cspell <scope>`                                   | —                                              | classified | paths     | Auto-discovers standard config names; use `--config` for a non-standard path. Exits non-zero and lists unknown words per file.                                                                                                                                                                                          |
| dotnet format           | `*.csproj`, `*.sln`                                             | `dotnet format <scope> --verify-no-changes --no-restore`  | `dotnet format <scope> --no-restore`           | safe       | project   | Scope is the owning project or solution, not individual sources. Default whitespace and style only. The `analyzers` subcommand applies code fixes that can change behaviour; it is opt-in and must be named in the brief.                                                                                               |
| ESLint                  | `eslint.config.*` (flat) or `.eslintrc*` (legacy)               | `npx -y eslint <scope>`                                   | `npx -y eslint <scope> --fix`                  | classified | paths     | Findings carry severities. `--fix` applies safe fixes only; `--fix-type` narrows them. Non-fixable findings are code changes.                                                                                                                                                                                           |
| gofmt                   | `go.mod`, `*.go` sources                                        | `gofmt -l <scope>`                                        | `gofmt -w <scope>`                             | safe       | paths     | Directory arguments walk recursively. `-l` exits zero and lists nonconforming files. Proof requires reading the list, not the exit code.                                                                                                                                                                                |
| go vet                  | `go.mod`                                                        | `go vet <scope>`                                          | —                                              | classified | packages  | Scope is a package pattern such as `./internal/...`. Exits non-zero on findings. Report only; no automatic fixes.                                                                                                                                                                                                       |
| markdownlint            | `.markdownlint*` config or a `markdownlint-cli` dependency      | `npx -y markdownlint-cli <scope>`                         | `npx -y markdownlint-cli <scope> --fix`        | classified | paths     | Exits non-zero and lists violations per file. `--fix` fixes basic issues only; the remainder are manual.                                                                                                                                                                                                                |
| Prettier                | `.prettierrc*`, `prettier.config.*`, or a `prettier` dependency | `npx -y prettier --check <scope>`                         | `npx -y prettier --write <scope>`              | safe       | paths     | `--check` exits non-zero and lists nonconforming paths. `npx` resolves the local install first. A file with no parser is an error, so scope to the files the project formats.                                                                                                                                           |
| Ruff (check)            | `pyproject.toml` `[tool.ruff]`, `ruff.toml`, `.ruff.toml`       | `uvx ruff check <scope>`                                  | `uvx ruff check <scope> --fix`                 | classified | paths     | `--fix` applies safe fixes; `--unsafe-fixes` is opt-in and must be named in the brief.                                                                                                                                                                                                                                  |
| Ruff (format)           | `pyproject.toml` `[tool.ruff]`, `ruff.toml`, `.ruff.toml`       | `uvx ruff format --check <scope>`                         | `uvx ruff format <scope>`                      | safe       | paths     | Prefer `uv run ruff` when Ruff is a project dependency. `--check` exits non-zero.                                                                                                                                                                                                                                       |
| Terraform fmt           | `*.tf` files                                                    | `terraform fmt -check -recursive <scope>`                 | `terraform fmt -recursive <scope>`             | safe       | directory | `-check` exits non-zero and lists nonconforming files. `-recursive` applies to the scope directory and below.                                                                                                                                                                                                           |
| Terraform validate      | `*.tf` files                                                    | `terraform validate`                                      | —                                              | classified | module    | Takes no path argument and requires `terraform init` in the module directory first. Exits non-zero on an invalid configuration. Report only; no automatic fixes.                                                                                                                                                        |
| zizmor                  | `.github/workflows/` directory or an `action.yml`               | `uvx zizmor <scope>`                                      | `uvx zizmor --fix <scope>`                     | classified | paths     | GitHub Actions security audit. Exits non-zero when findings exist; `--no-exit-codes` disables that. `--fix` applies safe fixes only; the `unsafe-only` and `all` modes must be named in the brief.                                                                                                                      |

## Command conventions

- A command is one whole string: no `|`, `&&`, `;`, `$()`, redirect, or
  substitution. Substituting `<scope>` is not composition.
- Read-only variants are the default posture and are safe to pre-approve.
  Write variants are corrections and need deliberate gating.
- The tool and mode segment is stable; only the scope argument varies. This
  keeps saved approvals and permission prefixes matching later invocations.
- Detection falls back to dependency presence when no configuration file
  exists. No detected tool means there is no formatting or lint step, not an
  invented command.

## Extending the catalogue

Add a row only for a tool the project actually uses. Record the failure signal
in `Notes`: whether the read-only command exits non-zero, exits zero and lists
paths, or prints a findings report. Record its `Scope` granularity as well; a
row whose scope cannot be narrowed cannot run against a task-sized target. A
catalogue entry with an unrecorded failure signal cannot prove anything.
