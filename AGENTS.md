# Copilot Instructions for awesome-ai

## Repository Overview

**awesome-ai** is a curated collection of reusable, enterprise-grade prompts, templates, and documentation frameworks for AI-assisted delivery and architecture design. This repository serves as a knowledge base for generating high-level designs (HLDs), architecture decision records (ADRs), and guidance for infrastructure-as-code transformations.

**APM is the source of truth.** All distributable packages are authored with Microsoft Agent Package Manager (APM) primitives (`.apm/` directories and `apm.yml` manifests). GitHub Copilot marketplace artifacts (`.claude-plugin/marketplace.json`) and the Copilot plugin manifests (`plugin.json`) are committed, generated outputs produced by `apm pack`.

## Project Structure

- **`apm.yml`** - Root APM marketplace manifest listing all published packages (source of truth for distribution)
- **`.claude-plugin/marketplace.json`** - Generated marketplace artifact consumed by GitHub Copilot CLI, Claude Code, APM, and skills.sh; regenerate with `apm pack` from the repository root
- **`/plugins`** - APM packages, one directory per plugin
  - `<plugin>/apm.yml` - Per-plugin APM manifest (name, version, description, targets)
  - `<plugin>/.apm/` - APM primitives (e.g. `.apm/skills/<name>/SKILL.md` for skills)
  - `<plugin>/plugin.json` - Authored Copilot-compatible manifest. Must declare the `skills` array explicitly; APM strips `skills` from generated manifests because Claude Code auto-discovers convention directories, but Copilot CLI defaults to `skills/` when the field is omitted
  - `<plugin>/CHANGELOG.md` - Release-please-managed changelog
- **`/prompts`** - Reusable prompt templates in Markdown format that guide AI agents through structured processes (repo-level content, not distributed primitives)
- **`/docs`** - Document templates and style guides
  - `plugins/architecture-docs/.apm/skills/generate-hld/references/hld.template.md` - Template for High-Level Design documents with all required sections
- **`README.md`** - Project index and entry point
- **`LICENCE`** - Repository licensing

## Key Conventions & Patterns

### APM Packaging Standards

1. **Skills live under `.apm/skills/`.** This is the only directory structure that works symmetrically through both `apm pack` (export) and `apm install` (discovery). Root `skills/` or `prompts/` convention directories get silently skipped by `apm install` for some primitives.
2. **Run `apm pack` from the repository root** to regenerate `.claude-plugin/marketplace.json`. Validate with `apm pack --check-versions --check-clean` (tag-pattern uniqueness + clean marketplace) and `apm marketplace check`.
3. **`plugin.json` is hand-authored and committed.** Do not rely on `apm pack` to synthesise it: APM strips the `skills` array from generated manifests, and Copilot CLI needs explicit `skills` paths pointing at `.apm/skills/<name>`.
4. **Versioning strategy is `tag_pattern`** with `tagPattern: "{name}-v{version}"`, matching the release-please tag convention (e.g. `architecture-docs-v0.0.4`).
5. **Marketplace output is defaulted** to `.claude-plugin/marketplace.json`; Copilot CLI reads this location as well as `.github/plugin/marketplace.json`.

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

3. **HLD Document Standards** - Referenced in `plugins/architecture-docs/.apm/skills/generate-hld/references/hld.template.md`:
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

This is a documentation and template repository with **no code build, test, or lint processes**. Packaging is validated through APM:

- `apm pack --check-versions --check-clean` - validates tag-pattern versioning and a clean marketplace
- `apm marketplace check` - validates marketplace dependency resolution
- These run in CI: `.github/workflows/apm-check.yml` on PRs touching `.claude-plugin/marketplace.json`, and `.github/workflows/release-plugin.yml` (invoked from `.github/workflows/release-please.yml`) when release-please creates releases

### Post-Implementation Validation

After modifying any `apm.yml`, `plugin.json`, plugin structure, or regenerating the marketplace, run these gates before finishing:

1. `apm doctor` - environment sanity check (git, network, auth, marketplace config); diagnose a broken local environment before running the content gates
2. `apm marketplace check` - marketplace entries resolve
3. `apm pack --check-versions --check-clean` - tag-pattern alignment (exit 3 if misaligned) and clean marketplace (exit 4 if drift)

Never hand-edit `.claude-plugin/marketplace.json`. It is regenerated by `apm pack` from the repository root, committed by `.github/workflows/generate-marketplace.yml`, and validated by `.github/workflows/apm-check.yml`. If `.github/workflows/apm-check.yml` is a required status check, note that it only runs when the file is part of the PR diff, so unrelated PRs will not report it.

Content is reviewed through:

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

A plugin packages one or more skills (wrapped prompts) for distribution via the APM marketplace and Copilot CLI.

1. **Create plugin directory:** `/plugins/<plugin-name>/`
2. **Add APM manifest:** `<plugin>/apm.yml` with `name`, `version`, `description`, and `targets` (e.g. `copilot`)
3. **Add the plugin to the marketplace:** register it in the root `apm.yml` `marketplace.packages` list with a `./plugins/<plugin-name>` source
4. **Create skills directory:** `/plugins/<plugin-name>/.apm/skills/`
5. **Create skill subdirectories:** One per skill (e.g., `.apm/skills/generate-adr/`)
6. **Add SKILL.md to each skill:** Markdown file with YAML frontmatter (name, description)
7. **Author the Copilot manifest:** `<plugin>/plugin.json` with `name`, `description`, `version`, and an explicit `skills` array pointing at `.apm/skills/<name>` (required for Copilot CLI; do not rely on `apm pack` synthesis)
8. **Regenerate the marketplace:** run `apm pack` from the repository root, then commit `.claude-plugin/marketplace.json`
9. **Create plugin README:** document installation, usage, and examples
10. **Test skill invocation:** run `apm pack --check-versions --check-clean`; verify skills load in the target harness

**Plugin Structure Example:**
```
plugins/my-plugin/
├── apm.yml
├── plugin.json
├── README.md
└── .apm/
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

This repository has no npm, Python, build, or language toolchain. APM (`apm` CLI) is the packaging tool, invoked locally and in GitHub Actions:

- `apm pack` regenerates `.claude-plugin/marketplace.json` from root `apm.yml` + plugin manifests
- `.github/workflows/generate-marketplace.yml` regenerates and commits the marketplace on release PRs
- `.github/workflows/apm-check.yml` validates marketplace entries, version alignment, and marketplace cleanliness on PRs touching `.claude-plugin/marketplace.json`
- `.github/workflows/release-please.yml` runs release-please; when it creates releases, the `publish` job resolves released component paths from the `paths_released` output into `{path, version, tag}` objects and runs a matrix of `.github/workflows/release-plugin.yml`
- `.github/workflows/release-plugin.yml` is a callable workflow (`workflow_call`, inputs `plugin-path` + `tag`) that gates (`apm marketplace check` + `apm pack --check-versions --check-clean`), packs an `apm pack --archive` zip per plugin, and attaches it to the component's `{name}-v{version}` release
- Release versioning is managed by release-please, which bumps `apm.yml` and `plugin.json` versions and tags `{name}-v{version}`

All content changes are direct Markdown edits. Changes take effect upon commit.
