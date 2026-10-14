# Awesome AI

- [Awesome AI](#awesome-ai)
  - [Contents](#contents)
  - [Install](#install)
    - [Recommended: Install With `skills.sh`](#recommended-install-with-skillssh)
    - [Install as an APM Package](#install-as-an-apm-package)
    - [Install as a GitHub Copilot Plugin](#install-as-a-github-copilot-plugin)
    - [Install in Claude Code](#install-in-claude-code)
  - [Available Skills](#available-skills)
    - [architecture-docs](#architecture-docs)
    - [devops](#devops)
  - [Quick Start](#quick-start)
    - [Using skills.sh](#using-skillssh)
    - [Using the GitHub Copilot plugin](#using-the-github-copilot-plugin)
  - [Contributing](#contributing)
  - [License](#license)

[![skills.sh](https://img.shields.io/badge/skills.sh-grey?logo=data:image/svg%2Bxml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxNiAxNiI+PHBhdGggZmlsbD0iI2ZmZmZmZiIgZmlsbC1ydWxlPSJldmVub2RkIiBjbGlwLXJ1bGU9ImV2ZW5vZGQiIGQ9Ik04IDFMMTYgMTVIMEw4IDFaIi8%2BPC9zdmc%2B&style=flat)](https://skills.sh/milkyware/awesome-ai)

A curated collection of enterprise-grade skills, prompts, templates, and documentation tools for AI-assisted software delivery and architecture design. Packages are authored with Microsoft Agent Package Manager (APM) and distributed across multiple AI harnesses.

## Contents

This repository uses **APM as the source of truth** for authoring and packaging, and generates harness-specific distribution artifacts from it:

- **`apm.yml`** – Root marketplace manifest (source of truth for distribution)
- **`.claude-plugin/marketplace.json`** – Generated marketplace consumed by GitHub Copilot CLI, Claude Code, APM, and skills.sh
- **`plugins/*/apm.yml`** – Per-plugin APM manifests (source of truth per package)
- **`plugins/*/.apm/`** – APM primitives (skills) authored with APM conventions
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
```

### Install as a GitHub Copilot Plugin

First add this repository to the plugin marketplace, then install a plugin.

```bash
copilot /plugin marketplace add https://github.com/milkyware/awesome-ai
copilot /plugin install architecture-docs
copilot /plugin install devops
```

### Install in Claude Code

```bash
apm marketplace add milkyware/awesome-ai
apm install architecture-docs@awesome-ai
apm install devops@awesome-ai
```

## Available Skills

### architecture-docs

**Generate professional Architecture Decision Records (ADRs), High-Level Design (HLD) documents, and `ARCHITECTURE.md` guides.**

The repository currently provides these architecture-focused skills:

- **`generate-adr`** – Structured, gated workflow for creating Architecture Decision Records
- **`generate-hld`** – Comprehensive guidance for generating High-Level Design documents
- **`generate-architecture-md`** – Guidance for creating an `ARCHITECTURE.md` document for rapid codebase understanding

These skills are built on enterprise-grade workflows with strict writing standards: UK English, technical precision, and no fabrication.

[Plugin documentation](./plugins/architecture-docs/README.md)

### devops

**Convert Azure DevOps pipeline templates to GitHub Actions and onboard repositories with release-please.**

The `devops` plugin provides these CI/CD skills:

- **`convert-az-pipeline`** – Converts an Azure Pipelines template into a reusable GitHub Actions composite action or `workflow_call` workflow, mapping tasks, expressions, and variables
- **`onboard-release-please`** – Onboards a repository with release-please for single-package or mono-repo layouts, generating the manifest, configuration, and workflows

[Plugin documentation](./plugins/devops/README.md)

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

## Contributing

To contribute improvements, report issues, or suggest new skills:

1. Open an [issue](https://github.com/milkyware/awesome-ai/issues) with details
2. For new content, describe the use case and include examples
3. Ensure all skills follow the [Writing Style Rules](./plugins/architecture-docs/README.md#writing-standards)
4. Submit a pull request with a clear description

## License

This repository is licensed under the MIT License. See [LICENCE](./LICENCE) for details.
