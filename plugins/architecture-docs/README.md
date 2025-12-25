# Architecture-Docs Plugin

**Generate professional Architecture Decision Records (ADRs) and High-Level Design (HLD) documents with structured, AI-guided workflows.**

## Overview

The **@architecture-docs** plugin provides two specialized commands for architectural documentation:

- **generate-adr** – Creates Architecture Decision Records with guided questions, decision drivers, and formal consequences
- **generate-hld** – Generates High-Level Design documents with comprehensive architectural guidance covering all key domains

Both commands are built on battle-tested prompts used by enterprise teams. They enforce UK English, technical precision, and architectural rigour.

## Installation

The plugin is available from the awesome-ai repository. Install it using the Copilot CLI:

```bash
copilot /plugin marketplace add https://github.com/milkyware/awesome-ai/plugins/architecture-docs
copilot /plugin install architecture-docs
```

Or enable it directly by adding to your repository's `.github/copilot/settings.json`:

```json
{
  "enabledPlugins": {
    "architecture-docs": true
  }
}
```

## Usage

### Generate an Architecture Decision Record (ADR)

```bash
copilot
/architecture-docs:generate-adr
```

The skill will guide you through:

1. **Metadata** – Status, date, decision-makers, consulted parties
2. **Context** – Problem statement, constraints
3. **Decision Drivers** – Critical factors and non-negotiables
4. **Considered Options** – At least 2–3 options with pros/cons
5. **Decision Outcome** – Selected option and rationale
6. **Consequences** – Positive outcomes and trade-offs
7. **Title & Filename** – Auto-generated from your answers

**Output:** A properly formatted ADR with filename suggestion (e.g., `0000-adopt-async-processing.md`)

### Generate a High-Level Design (HLD)

```bash
copilot
/architecture-docs:generate-hld
```

The skill will guide you through:

1. **Overview** – Solution name, audience, stakeholders, document ownership
2. **Context** – Problem statement, objectives, requirements
3. **Architecture Design** – Components, decisions, data flows, deployment
4. **Module Design** – Logical modules and their interactions
5. **Data Design** – Data domains, storage, retention, classification
6. **Security Design** – Authentication, authorisation, encryption, network security
7. **Glossary** – Solution-specific terminology

**Output:** A comprehensive HLD document with structured architectural guidance

## Command Reference

### `/skills generate-adr`

| Aspect               | Details                                          |
| -------------------- | ------------------------------------------------ |
| **Skill Name**       | `generate-adr`                                   |
| **Purpose**          | Generate Architecture Decision Records           |
| **Output**           | Markdown ADR file with suggested filename        |
| **Language**         | UK English                                       |
| **Typical Duration** | 10–15 minutes (depending on decision complexity) |

### `/skills generate-hld`

| Aspect               | Details                                         |
| -------------------- | ----------------------------------------------- |
| **Skill Name**       | `generate-hld`                                  |
| **Purpose**          | Generate High-Level Design documents            |
| **Output**           | Comprehensive Markdown HLD document             |
| **Language**         | UK English                                      |
| **Typical Duration** | 30–45 minutes (full workflow with all sections) |

## Key Features

✅ **Guided Workflows** – Structured, gated question sequences ensure completeness  
✅ **UK English** – All content uses UK English spelling and terminology  
✅ **Architectural Rigour** – Enforces technical precision with no speculation  
✅ **Enterprise-Grade** – Based on proven prompts used by enterprise teams  
✅ **Markdown-Ready** – Output is immediately ready for version control  
✅ **No Fabrication** – Clear rules prevent hallucinated information  

## Writing Standards

Both skills enforce strict writing rules:

- **Concise language** – No marketing tone or storytelling
- **Technical precision** – Fact-based, specific statements only
- **Consistency** – Terminology aligned within documents
- **No assumptions** – Questions asked if gaps are detected
- **Industry terminology** – Correct Azure and identity concepts
- **Markdown compliance** – Output adheres to linting standards

## Examples

### Sample ADR Output

```
Suggested filename:
0001-adopt-event-driven-architecture.md

---
status: accepted
date: 2024-04-03
decision-makers:
  - '@alice-architect'
  - '@bob-engineer'
consulted:
  - '@charlie-devops'
informed:
  - '@team-platform'
---

# Adopt Event-Driven Architecture for Service Integration

## Context and Problem Statement
The monolithic service integration layer is becoming a bottleneck...
```

### Sample HLD Output

```
# High-Level Design: Asset Management Platform

## 1. Overview

### 1.1 Audience
- Platform architects
- Security reviewers
- Delivery leads

### 1.2 Stakeholders

| Name          | Concern                           |
| ------------- | --------------------------------- |
| Platform Lead | Delivery timeline and scalability |
| Security Lead | Data protection and compliance    |
| Operations    | Monitoring and support burden     |
```

## Troubleshooting

**Q: The skill isn't appearing in `/skills`**  
A: Reload skills with `/skills reload` or restart the CLI

**Q: Can I use these skills for non-architecture decisions?**  
A: These skills are specifically designed for architectural documentation. For other use cases, create a custom skill

**Q: Can I modify the guided questions?**  
A: Skills are immutable within the plugin. For custom workflows, create a personal skill in `~/.copilot/skills/`

## Contributing

To report issues or suggest improvements to the @architecture-docs plugin:

1. Open an issue in the [awesome-ai repository](https://github.com/milkyware/awesome-ai)
2. Reference the plugin name and the skill (generate-adr or generate-hld)
3. Include the context or output that triggered the issue

## License

This plugin is licensed under the MIT License. See the [awesome-ai repository LICENCE](../../LICENCE) for details.

## Related Resources

- [awesome-ai Repository](https://github.com/milkyware/awesome-ai)
- [ADR Format Reference](https://adr.github.io/)
- [Architecture Decision Record Examples](https://github.com/joelparkerhenderson/architecture_decision_record)
