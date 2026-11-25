# Static Check Catalogue

Canonical commands for the formatters and linters this skill runs. Use the
`Detect by` column to identify the tool, then copy the `Read-only` or `Write`
command whole.

## Column contract

- `Read-only` is the proof and reporting command. Its result counts as
  evidence.
- `Write` is the correction command. It is never evidence; the read-only
  re-run after it is.
- `Fix class` is `safe` when the write command is idempotent and
  semantics-preserving, or `classified` when the tool has fix classes, applies
  only safe fixes by default, or can change behaviour.

## Runner rule

- `npx -y` runs npm packages. `-y` suppresses the first-fetch prompt, which an
  agent cannot answer.
- `uvx` runs PyPI packages. It never prompts and resolves the latest version in
  an ephemeral environment.
- When the executable name differs from the package name, name the package
  explicitly: `uvx --from <package> <executable>` (for example
  `uvx --from checkov checkov -d .`). The `--from` package is unpinned like
  every other canonical command, and the offline retry becomes
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

## Catalogue

| Tool                       | Detect by                                                       | Read-only                                        | Write                                    | Fix class  | Notes                                                                                                                                                                                              |
| -------------------------- | --------------------------------------------------------------- | ------------------------------------------------ | ---------------------------------------- | ---------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Prettier                   | `.prettierrc*`, `prettier.config.*`, or a `prettier` dependency | `npx -y prettier --check .`                      | `npx -y prettier --write .`              | safe       | `--check` exits non-zero and lists nonconforming paths. `npx` resolves the local install first.                                                                                                    |
| Biome (format)             | `biome.json`, `biome.jsonc`                                     | `npx -y @biomejs/biome format --check .`         | `npx -y @biomejs/biome format --write .` | safe       | Format mode only. Lint subcommands are listed separately.                                                                                                                                          |
| Biome (lint)               | `biome.json`, `biome.jsonc`                                     | `npx -y @biomejs/biome lint .`                   | `npx -y @biomejs/biome lint --write .`   | classified | `--write` applies safe fixes only. `--unsafe` is opt-in and must be named in the brief.                                                                                                            |
| ESLint                     | `eslint.config.*` (flat) or `.eslintrc*` (legacy)               | `npx -y eslint .`                                | `npx -y eslint . --fix`                  | classified | Findings carry severities. `--fix` applies safe fixes only; `--fix-type` narrows them. Non-fixable findings are code changes.                                                                      |
| Ruff (format)              | `pyproject.toml` `[tool.ruff]`, `ruff.toml`, `.ruff.toml`       | `uvx ruff format --check .`                      | `uvx ruff format .`                      | safe       | Prefer `uv run ruff` when Ruff is a project dependency. `--check` exits non-zero.                                                                                                                  |
| Ruff (check)               | `pyproject.toml` `[tool.ruff]`, `ruff.toml`, `.ruff.toml`       | `uvx ruff check .`                               | `uvx ruff check . --fix`                 | classified | `--fix` applies safe fixes; `--unsafe-fixes` is opt-in and must be named in the brief.                                                                                                             |
| Black                      | `pyproject.toml` `[tool.black]` or a `black` dependency         | `uvx black --check .`                            | `uvx black .`                            | safe       | Prefer `uv run black` when Black is a project dependency. `--diff` shows changes without writing.                                                                                                  |
| Checkov                    | `*.tf` files or a `terraform/` directory                        | `uvx --from checkov checkov -d .`                | —                                        | classified | Security and compliance scanner. Exits non-zero when checks fail. Report only; no automatic fixes.                                                                                                 |
| dotnet format              | `*.csproj`, `*.sln`                                             | `dotnet format --verify-no-changes --no-restore` | `dotnet format --no-restore`             | safe       | Default whitespace and style only. The `analyzers` subcommand applies code fixes that can change behaviour; it is opt-in and must be named in the brief.                                           |
| gofmt                      | `go.mod`, `*.go` sources                                        | `gofmt -l .`                                     | `gofmt -w .`                             | safe       | `-l` exits zero and lists nonconforming files. Proof requires reading the list, not the exit code.                                                                                                 |
| go vet                     | `go.mod`                                                        | `go vet ./...`                                   | —                                        | classified | Report only; no automatic fixes.                                                                                                                                                                   |
| Terraform fmt              | `*.tf` files                                                    | `terraform fmt -check -recursive`                | `terraform fmt -recursive`               | safe       | `-check` exits non-zero and lists nonconforming files. Dropping `-check` is the write form.                                                                                                        |
| Terraform validate         | `*.tf` files                                                    | `terraform validate`                             | —                                        | classified | Requires `terraform init` first. Exits non-zero on an invalid configuration. Report only; no automatic fixes.                                                                                      |
| cspell                     | `cspell.config.yaml`, `cspell.json`, or a `cspell` dependency   | `npx -y cspell .`                                | —                                        | classified | Auto-discovers standard config names; use `--config` for a non-standard path. Exits non-zero and lists unknown words per file.                                                                     |
| markdownlint               | `.markdownlint*` config or a `markdownlint-cli` dependency      | `npx -y markdownlint-cli .`                      | `npx -y markdownlint-cli . --fix`        | classified | Exits non-zero and lists violations per file. `--fix` fixes basic issues only; the remainder are manual.                                                                                           |
| zizmor                     | `.github/workflows/` directory or an `action.yml`               | `uvx zizmor .`                                   | `uvx zizmor --fix .`                     | classified | GitHub Actions security audit. Exits non-zero when findings exist; `--no-exit-codes` disables that. `--fix` applies safe fixes only; the `unsafe-only` and `all` modes must be named in the brief. |
| APM marketplace (check)    | root `apm.yml`                                                  | `apm marketplace check`                          | —                                        | classified | Validates that every marketplace entry resolves. Requires network access and authentication. Exits non-zero on failure.                                                                            |
| APM marketplace (validate) | root `apm.yml`                                                  | `apm marketplace validate`                       | —                                        | classified | Validates marketplace structure and plugin schema. Exits non-zero on failure.                                                                                                                      |

## Command conventions

- A command is one whole string: no `|`, `&&`, `;`, `$()`, redirect, or
  substitution.
- Read-only variants are the default posture and are safe to pre-approve.
  Write variants are corrections and need deliberate gating.
- The tool and mode segment is stable; only trailing paths vary. This keeps
  saved approvals and permission prefixes matching later invocations.
- Detection falls back to dependency presence when no configuration file
  exists. No detected tool means there is no formatting or lint step, not an
  invented command.

## Extending the catalogue

Add a row only for a tool the project actually uses. Record the failure signal
in `Notes`: whether the read-only command exits non-zero, exits zero and lists
paths, or prints a findings report. A catalogue entry with an unrecorded
failure signal cannot prove anything.
