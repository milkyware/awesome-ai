# Awesome AI

[![skills.sh](https://img.shields.io/badge/skills.sh-grey?logo=data:image/svg%2Bxml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxNiAxNiI+PHBhdGggZmlsbD0iI2ZmZmZmZiIgZmlsbC1ydWxlPSJldmVub2RkIiBjbGlwLXJ1bGU9ImV2ZW5vZGQiIGQ9Ik04IDFMMTYgMTVIMEw4IDFaIi8%2BPC9zdmc%2B&style=flat)](https://skills.sh/milkyware/awesome-ai)

A curated collection of reusable skills for AI-assisted software delivery and architecture design. Skills are authored with Microsoft Agent Package Manager (APM) and distributed to GitHub Copilot CLI, Claude Code, OpenCode, and skills.sh.

## Plugins

| Plugin                                                       | Description                                                                                           | Skills / agents                                                  |
| ------------------------------------------------------------ | ----------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------- |
| [`agent-workflow`](./plugins/agent-workflow/README.md)       | Human-supervised orchestration of specialist AI coding agents through bounded, verified tasks         | `orchestrator`, `researcher`, `implementer`, `reviewer` (agents) |
| [`architecture-docs`](./plugins/architecture-docs/README.md) | Architecture Decision Records (ADRs), High-Level Design (HLD) documents, and `ARCHITECTURE.md` guides | `generate-adr`, `generate-hld`, `generate-architecture-md`       |
| [`code-quality`](./plugins/code-quality/README.md)           | Review branch changes for correctness, scope, and merge readiness                                     | `code-review`                                                    |
| [`delivery`](./plugins/delivery/README.md)                   | Implementation-ready plans and delivery-ready Jira tickets                                            | `implementation-plan`, `create-jira-ticket`                      |
| [`devops`](./plugins/devops/README.md)                       | Azure Pipelines to GitHub Actions conversion and release-please onboarding                            | `convert-az-pipeline`, `onboard-release-please`                  |

`agent-workflow` ships agents rather than skills. Each plugin README documents installation for its supported harnesses, what it provides, and usage guidance.

## Install

### skills.sh

Install every skill in the repository with skills.sh:

```bash
npx skills add milkyware/awesome-ai
```

### APM

Register the marketplace once, then install the plugins you need with an explicit target:

```bash
apm marketplace add milkyware/awesome-ai
apm install architecture-docs@awesome-ai --target <target>
apm install code-quality@awesome-ai --target <target>
apm install delivery@awesome-ai --target <target>
apm install devops@awesome-ai --target <target>
apm install agent-workflow@awesome-ai --target <target>
```

`<target>` is `copilot`, `claude`, or `opencode`. Use the same target for every install in a project; APM reconciles the active target and removes deployments for targets that are no longer selected. The `agent-workflow` plugin declares `copilot` and `opencode` targets.

### Reproducible installs

Pin each package to its release tag, then commit `apm.yml` and `apm.lock.yaml` and use `apm install --frozen` in CI:

```bash
apm marketplace add milkyware/awesome-ai
apm install architecture-docs@awesome-ai#architecture-docs-v0.0.7 --target copilot
apm install --frozen --target copilot
```

Replace the tag and target with the release you need. APM records the resolved commit in `apm.lock.yaml`; `--frozen` refuses to install when the lockfile is missing or out of sync.

Pin each package by its own release tag. A repository-level ref freezes the catalog file but does not pin local package sources, so package tags remain necessary.

## Repository layout

- `apm.yml` – Marketplace manifest
- `.claude-plugin/marketplace.json` – Generated marketplace catalog
- `plugins/<name>/apm.yml` – Plugin manifest and version
- `plugins/<name>/.apm/skills/` – Skill definitions
- `plugins/<name>/.apm/agents/` – Agent definitions
- `plugins/<name>/README.md` – Plugin installation and usage
- `.github/workflows/` – Release, marketplace generation, and validation automation

Do not edit `.claude-plugin/marketplace.json` by hand. Run `apm pack` from the repository root to regenerate it.

## Writing standards

All skills enforce the following writing standards:

- Concise, neutral language without marketing tone or storytelling.
- Information-dense paragraphs with one architectural concern each.
- UK English spelling and terminology.
- Fact-based statements with no speculation or fabricated information.
- Consistent terminology within and across documents.

## Contributing

1. Open an [issue](https://github.com/milkyware/awesome-ai/issues) with details.
2. For new content, describe the use case and include examples.
3. Ensure all skills follow the [writing standards](#writing-standards).
4. Submit a pull request with a clear description.

## License

This repository is licensed under the MIT License. See [LICENCE](./LICENCE) for details.
