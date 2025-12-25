# Awesome AI

A curated collection of enterprise-grade prompts, templates, and tools for AI-assisted software delivery and architecture design.

- [Awesome AI](#awesome-ai)
  - [Contents](#contents)
  - [Plugins](#plugins)
    - [architecture-docs](#architecture-docs)
  - [Quick Start](#quick-start)
    - [For Copilot CLI Users](#for-copilot-cli-users)
    - [For Repository Maintainers](#for-repository-maintainers)
  - [Repository Structure](#repository-structure)
  - [Contributing](#contributing)
  - [License](#license)

## Contents

This repository contains reusable resources for GitHub Copilot CLI and other AI agents:

- **`/prompts`** – Reusable prompts for generating architectural artefacts (ADRs, HLDs)
- **`/plugins`** – Packaged plugins that bundle prompts and skills for Copilot CLI
- **`/docs`** – Templates and style guides (HLD template, conventions)
- **`/.github/copilot-instructions.md`** – Repository conventions for Copilot assistance

## Plugins

### architecture-docs

**Generate professional Architecture Decision Records (ADRs) and High-Level Design (HLD) documents.**

The `architecture-docs` plugin provides two commands:

- **`generate-adr`** – Structured, gated workflow for creating Architecture Decision Records
- **`generate-hld`** – Comprehensive guidance for generating High-Level Design documents

Both are built on enterprise-grade prompts with strict writing standards (UK English, technical precision, no fabrication).

**Install:**

```bash
copilot /plugin marketplace add https://github.com/milkyware/awesome-ai
copilot /plugin install architecture-docs
```

[📖 Plugin Documentation](./plugins/architecture-docs/README.md)

## Quick Start

### For Copilot CLI Users

1. **Install the plugin:**
   ```bash
   copilot /plugin marketplace add https://github.com/milkyware/awesome-ai
   copilot /plugin install architecture-docs
   ```

2. **Generate an ADR:**
   ```bash
   copilot
   /architecture-docs:generate-adr
   ```

3. **Generate an HLD:**
   ```bash
   copilot
   /architecture-docs:generate-hld
   ```

### For Repository Maintainers

To use these resources in your own projects:

1. **Copy the prompts** from `/prompts` directory
2. **Reference the templates** in `/docs` for your own documentation
3. **Create custom skills** in `.github/skills/` (see [Copilot documentation](https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/create-skills))

## Repository Structure

```bash
awesome-ai/
├── plugins/
│   └── architecture-docs/          # @architecture-docs plugin
│       ├── plugin.json             # Plugin manifest
│       ├── README.md               # Plugin documentation
│       └── skills/
│           ├── generate-adr/       # ADR generation skill
│           └── generate-hld/       # HLD generation skill
├── prompts/
│   ├── generate-adr.prompt.md      # ADR generation prompt (raw)
│   ├── generate-hld.prompt.md      # HLD generation prompt (raw)
│   ├── generate-azure-landing-zone.prompt.md
│   └── ...
├── docs/
│   └── hld.template.md             # High-Level Design template
├── .github/
│   └── copilot-instructions.md     # Repository conventions for Copilot CLI
├── README.md                        # This file
├── LICENCE                          # MIT License
└── .gitignore
```

## Contributing

To contribute improvements, report issues, or suggest new prompts/skills:

1. Open an [issue](https://github.com/milkyware/awesome-ai/issues) with details
2. For new content, describe the use case and include examples
3. Ensure all prompts follow the [Writing Style Rules](./plugins/architecture-docs/README.md#writing-standards)
4. Submit a pull request with a clear description

## License

This repository is licensed under the MIT License. See [LICENCE](./LICENCE) for details.
