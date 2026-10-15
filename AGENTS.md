# Copilot Instructions for awesome-ai

## Repository Overview

**awesome-ai** is a curated collection of reusable, enterprise-grade skills for AI-assisted delivery, architecture design, and DevOps automation. This repository serves as a knowledge base for generating high-level designs (HLDs), architecture decision records (ADRs), and for migrating and automating delivery pipelines.

**APM is the source of truth.** All distributable packages are authored with Microsoft Agent Package Manager (APM) primitives (`.apm/` directories and `apm.yml` manifests). GitHub Copilot marketplace artifacts (`.claude-plugin/marketplace.json`) and the Copilot plugin manifests (`plugin.json`) are committed, generated outputs produced by `apm pack`.

## Project Structure

- **`apm.yml`** - Root APM marketplace manifest listing all published packages (source of truth for distribution)
- **`.claude-plugin/marketplace.json`** - Generated marketplace artifact consumed by GitHub Copilot CLI, Claude Code, APM, and skills.sh; regenerate with `apm pack` from the repository root
- **`/plugins`** - APM packages, one directory per plugin
  - `<plugin>/apm.yml` - Per-plugin APM manifest (name, version, description, targets)
  - `<plugin>/.apm/` - APM primitives (e.g. `.apm/skills/<name>/SKILL.md` for skills)
  - `<plugin>/.apm/skills/<name>/references/` - Supporting material a skill loads on demand (mapping tables, templates, schemas)
  - `<plugin>/plugin.json` - Authored Copilot-compatible manifest. Must declare the `skills` array explicitly; APM strips `skills` from generated manifests because Claude Code auto-discovers convention directories, but Copilot CLI defaults to `skills/` when the field is omitted
  - `<plugin>/version.txt` - Version used by the `simple` release-please strategy
  - `<plugin>/CHANGELOG.md` - Release-please-managed changelog
- **`README.md`** - Project index and entry point
- **`LICENCE`** - Repository licensing

## Key Conventions & Patterns

### APM Packaging Standards

1. **Skills live under `.apm/skills/`.** This is the only directory structure that works symmetrically through both `apm pack` (export) and `apm install` (discovery). Root `skills/` or `prompts/` convention directories get silently skipped by `apm install` for some primitives.
2. **Run `apm pack` from the repository root** to regenerate `.claude-plugin/marketplace.json`. Validate with `apm pack --check-versions --check-clean` (tag-pattern uniqueness + clean marketplace) and `apm marketplace check`.
3. **`plugin.json` is hand-authored and committed.** Do not rely on `apm pack` to synthesise it: APM strips the `skills` array from generated manifests, and Copilot CLI needs explicit `skills` paths pointing at `.apm/skills/<name>`.
4. **Versioning strategy is `tag_pattern`** with `tagPattern: "{name}-v{version}"`, matching the release-please tag convention (e.g. `devops-v0.0.1`).
5. **Marketplace output is defaulted** to `.claude-plugin/marketplace.json`; Copilot CLI reads this location as well as `.github/plugin/marketplace.json`.
6. **Root `apm.yml` versions are maintained by hand.** `apm pack` copies each `marketplace.packages[].version` into the generated marketplace, while `--check-versions` validates tag alignment against the plugin's own `apm.yml`. The two values can therefore drift without failing any gate. release-please bumps only the plugin manifests, so update the root entry when a plugin is released.

### Skill Design Standards

1. **Writing Style Rules** - All skills enforce strict technical writing:
   - Concise, neutral language without marketing tone or storytelling
   - Information-dense paragraphs (3–5 sentences max)
   - Single architectural concern per paragraph
   - UK English spelling and terminology
   - No speculation or fabricated information

2. **Skill Structure** - Skills follow a standard pattern:
   - YAML frontmatter with `name` and a tight, declarative `description` (the description drives auto-discovery, so keep it specific and free of overlap with other skills)
   - Clear role definition for the AI agent
   - Structured, gated step-by-step workflow sections
   - Explicit rules for writing, output format, and validation
   - Bulky or machine-readable detail moved into `references/` files and loaded on demand

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

This is a content repository with **no code build or test processes**. Content is validated by linting and by APM packaging checks:

- `format-prettier.yml` - Prettier formatting across Markdown, JSON, and YAML
- `spell-check.yml` - `cspell` spell checking with the sticky PR comment
- `super-linter.yml` - Super-Linter (includes `codespell`); full-codebase runs on non-PR triggers, changed-files scoped on pull requests
- `validate-pr-title.yml` - Conventional Commit PR title validation
- `apm-check.yml` - runs on every pull request and on `workflow_dispatch`: `apm marketplace check`, `apm pack --check-versions --dry-run`, and `apm pack --check-clean --dry-run`
- `release-plugin.yml` (invoked from `release-please.yml`) - on release, gates with `apm marketplace check` + `apm pack --check-versions --check-clean`

### Post-Implementation Validation

After modifying any `apm.yml`, `plugin.json`, plugin structure, or regenerating the marketplace, run these gates before finishing:

1. `apm doctor` - environment sanity check (git, network, auth, marketplace config); diagnose a broken local environment before running the content gates
2. `apm marketplace check` - marketplace entries resolve
3. `apm pack --check-versions --check-clean` - tag-pattern alignment (exit 3 if misaligned) and clean marketplace (exit 4 if drift)

Never hand-edit `.claude-plugin/marketplace.json`. It is regenerated by `apm pack` from the repository root, committed by `.github/workflows/generate-marketplace.yml`, and validated by `.github/workflows/apm-check.yml`.

Content is reviewed through:

- Manual review for consistency with writing style rules
- Validation of skill workflows against their documented steps
- Template compliance against the HLD structure

When modifying skills or templates:

- Ensure writing style rules are applied consistently
- Verify skill workflows are complete and gated properly
- Test skill logic by mentally executing its step-by-step sections
- Validate that template sections align with their documented purposes

## Working with This Repository

### Adding a New Skill

1. **Create the skill directory:** `/plugins/<plugin-name>/.apm/skills/<skill-name>/`
2. **Add `SKILL.md`:** YAML frontmatter with `name` and a tight, declarative `description`, followed by the gated workflow
3. **Add references if needed:** put bulky tables, templates, or schemas in `references/` and point to them from `SKILL.md`
4. **Register the skill:** add its path to the `<plugin>/plugin.json` `skills` array (required for Copilot CLI)
5. **Regenerate the marketplace:** run `apm pack` from the repository root, then commit `.claude-plugin/marketplace.json`
6. **Validate:** run `apm audit --file <SKILL.md>` and `apm pack --check-versions --check-clean`; confirm the skill loads in the target harness

### Creating a New Plugin

A plugin packages one or more skills for distribution via the APM marketplace and Copilot CLI.

1. **Create plugin directory:** `/plugins/<plugin-name>/`
2. **Add APM manifest:** `<plugin>/apm.yml` with `name`, `version`, `description`, and `targets` (e.g. `copilot`)
3. **Add the plugin to the marketplace:** register it in the root `apm.yml` `marketplace.packages` list with a `./plugins/<plugin-name>` source
4. **Create skills directory:** `/plugins/<plugin-name>/.apm/skills/`
5. **Create skill subdirectories:** One per skill (e.g., `.apm/skills/generate-adr/`)
6. **Add SKILL.md to each skill:** Markdown file with YAML frontmatter (name, description)
7. **Author the Copilot manifest:** `<plugin>/plugin.json` with `name`, `description`, `version`, and an explicit `skills` array pointing at `.apm/skills/<name>` (required for Copilot CLI; do not rely on `apm pack` synthesis)
8. **Add release scaffolding:** `<plugin>/version.txt` and `<plugin>/CHANGELOG.md`, and register the plugin in `release-please-config.json` + `.release-please-manifest.json`
9. **Regenerate the marketplace:** run `apm pack` from the repository root, then commit `.claude-plugin/marketplace.json`
10. **Create plugin README:** document installation, usage, and examples
11. **Test skill invocation:** run `apm pack --check-versions --check-clean`; verify skills load in the target harness

**Plugin Structure Example:**

```
plugins/my-plugin/
├── apm.yml
├── plugin.json
├── version.txt
├── CHANGELOG.md
├── README.md
└── .apm/
    └── skills/
        ├── my-skill-1/
        │   └── SKILL.md
        └── my-skill-2/
            ├── SKILL.md
            └── references/
                └── my-reference.md
```

### Modifying Templates

1. Update the template file in the skill's `references/` directory (for example `plugins/architecture-docs/.apm/skills/generate-hld/references/hld.template.md`)
2. Ensure section purposes remain clear
3. Update any cross-references in the README or in skills that reference the template
4. Verify examples and placeholders follow the UK English and terminology conventions

### Commit Practices

- Use clear, descriptive commit messages
- Reference the skill, template, or plugin being modified
- If a skill change affects workflows, describe the impact in the commit message
- Include author trailers in commits

## No External Build System

This repository has no npm, Python, build, or language toolchain. APM (`apm` CLI) is the packaging tool, invoked locally and in GitHub Actions:

- `apm pack` regenerates `.claude-plugin/marketplace.json` from root `apm.yml` + plugin manifests
- `.github/workflows/generate-marketplace.yml` regenerates and commits the marketplace on pull requests touching source manifests (`apm.yml`, `plugins/**/apm.yml`, `plugins/**/plugin.json`, `.release-please-manifest.json`)
- `.github/workflows/apm-check.yml` validates marketplace entries, version alignment, and marketplace cleanliness on every pull request
- `.github/workflows/release-please.yml` runs release-please; when it creates releases, the `publish` job resolves released component paths from the `paths_released` output into `{path, version, tag}` objects and runs a matrix of `.github/workflows/release-plugin.yml`
- `.github/workflows/release-plugin.yml` is a callable workflow (`workflow_call`, inputs `plugin-path` + `tag`) that gates (`apm marketplace check` + `apm pack --check-versions --check-clean`), packs an `apm pack --archive` ZIP per plugin, and attaches it to the component's `{name}-v{version}` release
- Release versioning is managed by release-please, which bumps each plugin's `apm.yml` and `plugin.json` versions and tags `{name}-v{version}`; it does not bump the root `apm.yml` marketplace versions (see APM Packaging Standards, item 6)

All content changes are direct Markdown edits. Changes take effect upon commit.
