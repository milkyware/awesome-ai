# Copilot Instructions for awesome-ai

## Repository Overview

**awesome-ai** is a curated collection of reusable, enterprise-grade prompts, templates, and documentation frameworks for AI-assisted delivery and architecture design. This repository serves as a knowledge base for generating high-level designs (HLDs), architecture decision records (ADRs), and guidance for infrastructure-as-code transformations.

## Project Structure

- **`/prompts`** - Reusable prompt templates in Markdown format that guide AI agents through structured processes
  - Agent-executed prompts (front-matter defines `agent: 'agent'`)
  - Each prompt includes detailed writing rules, step-by-step workflows, and structured output requirements
  - Prompts are designed for UK English, technical precision, and architectural rigour
- **`/docs`** - Document templates and style guides
  - `hld.template.md` - Template for High-Level Design documents with all required sections
  - Follows enterprise architectural conventions and terminology
- **`README.md` - Project index and entry point
- **`LICENCE`** - Repository licensing

## Key Conventions & Patterns

### Prompt Design Standards

1. **Writing Style Rules** - All prompts enforce strict technical writing:
   - Concise, neutral language without marketing tone or storytelling
   - Information-dense paragraphs (3–5 sentences max)
   - Single architectural concern per paragraph
   - UK English spelling and terminology
   - No speculation or fabricated information

2. **Prompt Structure** - Prompts follow a standard pattern:
   - Front-matter metadata (agent specification, description)
   - Clear role definition for the AI agent
   - Structured step-by-step workflow sections
   - Explicit rules for writing, output format, and validation
   - Final output requirements and validation gates

3. **HLD Document Standards** - Referenced in `docs/hld.template.md`:
   - Seven main sections: Overview, Context, Architecture Design, Module Design, Data Design, Security Design, Appendix
   - Audience: architects, engineers, governance teams, security reviewers
   - Data flows described at behavioural level (not implementation detail)
   - Security sections cover identity, authorisation, data protection, network security, logging/audit, and external permissions
   - Microsoft Graph and Azure terminology used consistently
   - Tables for structured data (stakeholders, requirements, etc.)

### Documentation Conventions

- All documents use UK English (colour, organisation, authorisation, etc.)
- Architectural content focuses on "what" and "why", not implementation detail
- Glossaries exclude widely understood terms (API, CI/CD, Entra ID) but include solution-specific and architecture-specific terminology
- Terminology must be consistent across all sections of a document

### Terminology

- Entra ID: Microsoft identity platform
- ADR: Architecture Decision Record
- HLD: High-Level Design
- Front-door: Azure Front Door (ingress)
- VNet: Azure Virtual Network
- RBAC: Role-Based Access Control

## Build, Test, and Lint

This is a documentation and template repository with **no build, test, or lint processes**. Content is reviewed through:

- Manual review for consistency with writing style rules
- Validation of prompt workflows against their documented steps
- Template compliance against the HLD structure

When modifying prompts or templates:
- Ensure writing style rules are applied consistently
- Verify prompt workflows are complete and gated properly
- Test prompt logic by mentally executing its step-by-step sections
- Validate that template sections align with their documented purposes

## Working with This Repository

### Adding a New Prompt

1. Create a new file in `/prompts` with naming pattern: `<descriptor>.prompt.md`
2. Include front-matter with metadata (agent type, description)
3. Apply all writing style rules defined in `generate-hld.prompt.md` as the standard
4. Structure the prompt with clear, gated steps
5. Define explicit output rules and validation requirements
6. Test the workflow logic by tracing through each step

### Creating a New Plugin

A plugin packages one or more skills (wrapped prompts) for Copilot CLI distribution.

1. **Create plugin directory:** `/plugins/<plugin-name>/`
2. **Add plugin manifest:** `plugin.json` with metadata:
   - `name`: Identifier (kebab-case)
   - `displayName`: User-friendly name
   - `description`: What the plugin does
   - `version`: Semantic version
   - `commands`: Array of exposed commands
   - `skills`: Array of skill names to include
3. **Create skills directory:** `/plugins/<plugin-name>/skills/`
4. **Create skill subdirectories:** One per skill (e.g., `skills/generate-adr/`)
5. **Add SKILL.md to each skill:** Markdown file with YAML frontmatter (name, description)
6. **Create plugin README:** Document installation, usage, and examples
7. **Test skill invocation:** Verify skills load and execute correctly in Copilot CLI

**Plugin Structure Example:**
```
plugins/my-plugin/
├── plugin.json
├── README.md
└── skills/
    ├── my-skill-1/
    │   └── SKILL.md
    └── my-skill-2/
        └── SKILL.md
```

### Modifying Templates

1. Update the template file in `/docs`
2. Ensure section purposes remain clear
3. Update any cross-references in README or in prompts that reference the template
4. Verify examples and placeholders follow the UK English and terminology conventions

### Commit Practices

- Use clear, descriptive commit messages
- Reference the prompt, template, or plugin being modified
- If a prompt change affects workflows, describe the impact in the commit message
- Include author trailers in commits

## No External Build System

This repository has no npm, Python, build, or CI/CD tooling. All changes are:
- Direct file edits to Markdown documents
- Manual validation of prompt workflows and plugin structure
- Git version control only

Changes take effect immediately upon commit.
