# Architecture Docs Plugin

**Generate Architecture Decision Records (ADRs), High-Level Design (HLD) documents, and `ARCHITECTURE.md` guides with structured, AI-guided workflows.**

## Skills

| Skill                      | Purpose                                                                               | Output                                                                                         |
| -------------------------- | ------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------- |
| `generate-adr`             | Create an ADR through a gated question sequence covering context, options, and impact | Markdown ADR with a suggested filename                                                         |
| `generate-hld`             | Create an HLD covering context, architecture, modules, data, and security             | Structured HLD document                                                                        |
| `generate-architecture-md` | Create an `ARCHITECTURE.md` guide for rapid codebase understanding                    | Architecture overview covering components, data stores, integrations, deployment, and security |

All skills enforce the repository [writing standards](../../README.md#writing-standards).

## Install

The plugin is published from the awesome-ai marketplace as an APM package. Register the marketplace once, then install the plugin for your harness.

```bash
apm marketplace add milkyware/awesome-ai
```

Use one target per project; APM reconciles the active target and removes deployments for targets that are no longer selected.

```bash
# GitHub Copilot CLI
apm install architecture-docs@awesome-ai --target copilot

# Claude Code
apm install architecture-docs@awesome-ai --target claude

# OpenCode
apm install architecture-docs@awesome-ai --target opencode
```

For a reproducible install, pin the plugin to its release tag:

```bash
apm install architecture-docs@awesome-ai#architecture-docs-v0.0.7 --target copilot
```

Replace the tag with the latest release for this plugin, then commit `apm.yml` and `apm.lock.yaml` and use `apm install --frozen` in CI. See [Reproducible installs](../../README.md#reproducible-installs).

## Usage

### Generate an Architecture Decision Record

Ask the agent to create an ADR. The skill guides you through:

1. **Metadata** – Status, date, decision-makers, consulted parties.
2. **Context** – Problem statement and constraints.
3. **Decision drivers** – Critical factors and non-negotiables.
4. **Considered options** – At least two or three options with pros and cons.
5. **Decision outcome** – Selected option and rationale.
6. **Consequences** – Positive outcomes and trade-offs.
7. **Title and filename** – Derived from your answers.

**Output:** A formatted ADR with a filename suggestion, such as `0001-adopt-event-driven-architecture.md`.

### Generate a High-Level Design

Ask the agent to create an HLD. The skill guides you through:

1. **Overview** – Solution name, audience, stakeholders, and document ownership.
2. **Context** – Problem statement, objectives, and requirements.
3. **Architecture design** – Components, decisions, data flows, and deployment.
4. **Module design** – Logical modules and their interactions.
5. **Data design** – Data domains, storage, retention, and classification.
6. **Security design** – Authentication, authorisation, encryption, and network security.
7. **Appendix and glossary** – Solution-specific terminology and supporting detail.

**Output:** A structured HLD document suitable for architects, engineers, governance teams, and security reviewers.

### Generate an ARCHITECTURE.md guide

Ask the agent to create an `ARCHITECTURE.md` for the repository. The skill guides you through the architecture overview, project structure, system diagram, core components, data stores, external integrations, deployment, security, development and testing, roadmap, project identification, and glossary. It reads tracked files to ground the project structure section.

**Output:** An `ARCHITECTURE.md` document that explains how the codebase fits together.

Invoke a skill from your agent's skill picker, or use `/skills <name>` in GitHub Copilot CLI.

## Troubleshooting

**Q: The skill is not appearing in `/skills`.**

A: Reload skills with `/skills reload` or restart the CLI.

## Contributing

Report issues and suggest improvements in the [awesome-ai repository](https://github.com/milkyware/awesome-ai/issues). Reference the plugin and skill, and include the context or output that triggered the issue.

## License

This plugin is licensed under the MIT License. See the [awesome-ai repository LICENCE](../../LICENCE) for details.

## Related resources

- [awesome-ai repository](https://github.com/milkyware/awesome-ai)
- [ADR format reference](https://adr.github.io/)
- [Architecture Decision Record examples](https://github.com/joelparkerhenderson/architecture_decision_record)
