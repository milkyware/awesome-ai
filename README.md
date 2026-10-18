# Awesome AI

- [Awesome AI](#awesome-ai)
  - [Contents](#contents)
  - [Install](#install)
    - [Recommended: Install With `skills.sh`](#recommended-install-with-skillssh)
    - [Install as an APM Package](#install-as-an-apm-package)
    - [Install as a GitHub Copilot Plugin](#install-as-a-github-copilot-plugin)
    - [Install in Claude Code](#install-in-claude-code)
  - [Available Plugins](#available-plugins)
    - [architecture-docs](#architecture-docs)
    - [DevOps](#devops)
    - [Agent Workflow](#agent-workflow)
  - [Quick Start](#quick-start)
    - [Using skills.sh](#using-skillssh)
    - [Using the GitHub Copilot plugin](#using-the-github-copilot-plugin)
    - [Using the Agent Workflow](#using-the-agent-workflow)
  - [Contributing](#contributing)
  - [License](#license)

[![skills.sh](https://img.shields.io/badge/skills.sh-grey?logo=data:image/svg%2Bxml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxNiAxNiI+PHBhdGggZmlsbD0iI2ZmZmZmZiIgZmlsbC1ydWxlPSJldmVub2RkIiBjbGlwLXJ1bGU9ImV2ZW5vZGQiIGQ9Ik04IDFMMTYgMTVIMEw4IDFaIi8%2BPC9zdmc%2B&style=flat)](https://skills.sh/milkyware/awesome-ai)

A curated collection of enterprise-grade skills and agents for AI-assisted software delivery, architecture design, and DevOps automation. Packages are authored with Microsoft Agent Package Manager (APM) and distributed across multiple AI harnesses.

## Contents

This repository uses **APM as the source of truth** for authoring and packaging, and generates harness-specific distribution artifacts from it:

- **`apm.yml`** – Root marketplace manifest (source of truth for distribution)
- **`.claude-plugin/marketplace.json`** – Generated marketplace consumed by GitHub Copilot CLI, Claude Code, APM, and skills.sh
- **`plugins/*/apm.yml`** – Per-plugin APM manifests (source of truth per package)
- **`plugins/*/.apm/`** – APM primitives (skills and agents) authored with APM conventions
- **`plugins/*/plugin.json`** – Authored Copilot-compatible plugin manifest (skills declared explicitly for Copilot CLI)

## Install

### Recommended: Install With `skills.sh`

Install the repository with `skills.sh` for a cross-platform workflow that works across supported coding agents, including GitHub Copilot.

```bash
npx skills add milkyware/awesome-ai
```

This exposes the available architecture, documentation, and DevOps skills from the repository without relying on a harness-specific plugin workflow.

### Install as an APM Package

Register the marketplace and install the packages you need with APM:

```bash
apm marketplace add milkyware/awesome-ai
apm install architecture-docs@awesome-ai
apm install devops@awesome-ai
apm install agent-workflow@awesome-ai
```

### Install as a GitHub Copilot Plugin

First add this repository to the plugin marketplace, then install a plugin.

```bash
copilot /plugin marketplace add https://github.com/milkyware/awesome-ai
copilot /plugin install architecture-docs
copilot /plugin install devops
copilot /plugin install agent-workflow
```

### Install in Claude Code

```bash
apm marketplace add milkyware/awesome-ai
apm install architecture-docs@awesome-ai
apm install devops@awesome-ai
apm install agent-workflow@awesome-ai
```

## Available Plugins

### architecture-docs

**Generate professional Architecture Decision Records (ADRs), High-Level Design (HLD) documents, and `ARCHITECTURE.md` guides.**

The repository currently provides these architecture-focused skills:

- **`generate-adr`** – Structured, gated workflow for creating Architecture Decision Records
- **`generate-hld`** – Comprehensive guidance for generating High-Level Design documents
- **`generate-architecture-md`** – Guidance for creating an `ARCHITECTURE.md` document for rapid codebase understanding

These skills are built on enterprise-grade workflows with strict writing standards: UK English, technical precision, and no fabrication.

[Plugin documentation](./plugins/architecture-docs/README.md)

### DevOps

**Convert Azure DevOps pipeline templates to GitHub Actions and onboard repositories with release-please.**

The `devops` plugin provides these CI/CD skills:

- **`convert-az-pipeline`** – Converts an Azure Pipelines template into a reusable GitHub Actions composite action or `workflow_call` workflow, mapping tasks, expressions, and variables
- **`onboard-release-please`** – Onboards a repository with release-please for single-package or mono-repo layouts, generating the manifest, configuration, and workflows

[Plugin documentation](./plugins/devops/README.md)

### Agent Workflow

**Human-supervised orchestration of specialist AI coding agents through an explicit, repeatable workflow with bounded tasks and verified results.**

The `agent-workflow` plugin provides an orchestrator and three specialists:

- **`orchestrator`** – Owns the workflow: plans, delegates, verifies evidence, and reports
- **`researcher`** – Read-only investigation with evidence and explicit gaps
- **`implementer`** – Executes one bounded task and reports verification it actually ran
- **`reviewer`** – Independent assessment with a severity-graded verdict

Unlike the skill-based plugins, `agent-workflow` ships agents. It exists for work that needs research, an approved plan, delegated implementation, and independent review rather than a single pass.

[Plugin documentation](./plugins/agent-workflow/README.md)

## Quick Start

### Using skills.sh

After installation, open your preferred supported coding agent and invoke one of the installed skills. For example:

- `/generate-adr` - Create an Architecture Decision Record for introducing Azure Front Door
- `/generate-hld` - Produce a High-Level Design for a document processing platform on Azure
- `/generate-architecture-md` - Create an ARCHITECTURE.md document for this repository
- `/convert-az-pipeline` - Convert an Azure Pipelines template into reusable GitHub Actions
- `/onboard-release-please` - Onboard a repository with release-please

### Using the GitHub Copilot plugin

After installation, start Copilot and invoke a plugin command directly.

Generate an ADR:

```bash
copilot
/architecture-docs:generate-adr
```

Generate an HLD:

```bash
copilot
/architecture-docs:generate-hld
```

Generate an `ARCHITECTURE.md` document:

```bash
copilot
/architecture-docs:generate-architecture-md
```

Convert an Azure Pipeline:

```bash
copilot
/devops:convert-az-pipeline
```

Onboard a repository with release-please:

```bash
copilot
/devops:onboard-release-please
```

### Using the Agent Workflow

After installation, start the orchestrator and state your objective. It researches,
plans, and waits for your approval before implementing:

```bash
copilot
@orchestrator Plan and deliver <your objective>
```

The orchestrator delegates to `researcher`, `implementer`, and `reviewer` as the
work requires, and reports what was verified rather than what was merely claimed.

## Contributing

To contribute improvements, report issues, or suggest new skills or agents:

1. Open an [issue](https://github.com/milkyware/awesome-ai/issues) with details
2. For new content, describe the use case and include examples
3. Ensure all skills follow the [Writing Style Rules](./plugins/architecture-docs/README.md#writing-standards)
4. Submit a pull request with a clear description

## License

This repository is licensed under the MIT License. See [LICENCE](./LICENCE) for details.
