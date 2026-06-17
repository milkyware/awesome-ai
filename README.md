# Awesome AI

- [Awesome AI](#awesome-ai)
  - [Contents](#contents)
  - [Install](#install)
    - [Recommended: Install With `skills.sh`](#recommended-install-with-skillssh)
    - [Install as a GitHub Copilot Plugin](#install-as-a-github-copilot-plugin)
  - [Available Skills](#available-skills)
    - [architecture-docs](#architecture-docs)
  - [Quick Start](#quick-start)
    - [Using skills.sh](#using-skillssh)
    - [Using the GitHub Copilot plugin](#using-the-github-copilot-plugin)
  - [Contributing](#contributing)
  - [License](#license)

[![skills.sh](https://img.shields.io/badge/skills.sh-grey?logo=data:image/svg%2Bxml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxNiAxNiI+PHBhdGggZmlsbD0iI2ZmZmZmZiIgZmlsbC1ydWxlPSJldmVub2RkIiBjbGlwLXJ1bGU9ImV2ZW5vZGQiIGQ9Ik04IDFMMTYgMTVIMEw4IDFaIi8%2BPC9zdmc%2B&style=flat)](https://skills.sh/milkyware/awesome-ai)

A curated collection of enterprise-grade skills, prompts, templates, and documentation tools for AI-assisted software delivery and architecture design.

## Contents

This repository contains reusable resources for GitHub Copilot and other AI agents:

- **Cross-platform skills** installable via `skills.sh`
- **GitHub Copilot plugin packaging** for teams that prefer the Copilot plugin model
- **`/prompts`** – Reusable prompts for generating architectural artefacts
- **`/docs`** – Templates and style guides
- **`/plugins`** – Plugin packaging for Copilot CLI distribution

## Install

### Recommended: Install With `skills.sh`

Install the repository with `skills.sh` for a cross-platform workflow that works across supported coding agents, including GitHub Copilot.

```bash
npx skills add milkyware/awesome-ai
```

This exposes the available architecture and documentation skills from the repository without relying on a Copilot-specific plugin workflow.

### Install as a GitHub Copilot Plugin

If you specifically want the GitHub Copilot plugin packaging model, first add this repository to the plugin marketplace, then install the `architecture-docs` plugin.

```bash
copilot /plugin marketplace add https://github.com/milkyware/awesome-ai
copilot /plugin install architecture-docs
```

## Available Skills

### architecture-docs

**Generate professional Architecture Decision Records (ADRs), High-Level Design (HLD) documents, and `ARCHITECTURE.md` guides.**

The repository currently provides these architecture-focused skills:

- **`generate-adr`** – Structured, gated workflow for creating Architecture Decision Records
- **`generate-hld`** – Comprehensive guidance for generating High-Level Design documents
- **`generate-architecture-md`** – Guidance for creating an `ARCHITECTURE.md` document for rapid codebase understanding

These skills are built on enterprise-grade prompts with strict writing standards: UK English, technical precision, and no fabrication.

[Plugin documentation](./plugins/architecture-docs/README.md)

## Quick Start

### Using skills.sh

After installation, open your preferred supported coding agent and invoke one of the installed skills. For example:

- `/generate-adr` - Create an Architecture Decision Record for introducing Azure Front Door
- `/generate-hld` - Produce a High-Level Design for a document processing platform on Azure
- `/generate-architecture-md` - Create an ARCHITECTURE.md document for this repository

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

## Contributing

To contribute improvements, report issues, or suggest new prompts/skills:

1. Open an [issue](https://github.com/milkyware/awesome-ai/issues) with details
2. For new content, describe the use case and include examples
3. Ensure all prompts follow the [Writing Style Rules](./plugins/architecture-docs/README.md#writing-standards)
4. Submit a pull request with a clear description

## License

This repository is licensed under the MIT License. See [LICENCE](./LICENCE) for details.
