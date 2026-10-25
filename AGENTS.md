# Copilot Instructions for awesome-ai

## Repository Overview

**awesome-ai** is a curated collection of reusable, enterprise-grade skills for AI-assisted delivery, architecture design, and DevOps automation. This repository serves as a knowledge base for generating high-level designs (HLDs), architecture decision records (ADRs), and for migrating and automating delivery pipelines.

**APM is the source of truth.** All distributable packages are authored with Microsoft Agent Package Manager (APM) primitives (`.apm/` directories and `apm.yml` manifests). The marketplace catalog (`.claude-plugin/marketplace.json`) is a committed, generated output produced by `apm pack`. Do not author `plugin.json`: APM installs skills directly, and `apm pack --archive` synthesises a Copilot-compatible manifest inside the release archive with skills relocated to `skills/`.

## Project Structure

- **`apm.yml`** - Root APM marketplace manifest listing all published packages (source of truth for distribution)
- **`.claude-plugin/marketplace.json`** - Generated marketplace catalog consumed by APM; regenerate with `apm pack` from the repository root
- **`/plugins`** - APM packages, one directory per plugin
  - `<plugin>/apm.yml` - Per-plugin APM manifest (name, version, description, targets)
  - `<plugin>/.apm/` - APM primitives (e.g. `.apm/skills/<name>/SKILL.md` for skills)
  - `<plugin>/.apm/skills/<name>/references/` - Supporting material a skill loads on demand (mapping tables, templates, schemas)
  - `<plugin>/version.txt` - Version used by the `simple` release-please strategy
  - `<plugin>/CHANGELOG.md` - Release-please-managed changelog
  - `<plugin>/README.md` - Plugin installation, usage, and troubleshooting
- **`README.md`** - Project index, plugin table, and installation entry point
- **`LICENCE`** - Repository licensing

## Key Conventions & Patterns

### APM Packaging Standards

1. **Skills live under `.apm/skills/`.** This is the only directory structure that works symmetrically through both `apm pack` (export) and `apm install` (discovery). Root `skills/` or `prompts/` convention directories get silently skipped by `apm install` for some primitives.
2. **Run `apm pack` from the repository root** to regenerate `.claude-plugin/marketplace.json`. Validate with `apm pack --check-versions --check-clean` (tag-pattern uniqueness + clean marketplace) and `apm marketplace check`.
3. **Do not author `plugin.json`.** APM is the installation mechanism for every harness (`apm install <plugin>@awesome-ai --target <target>`). Native Copilot CLI plugin installation is not supported because APM skills live under `.apm/skills/`, which the native loader does not discover. `apm pack --archive` synthesises a `plugin.json` inside the release ZIP with skills relocated to `skills/`.
4. **Versioning strategy is `tag_pattern`** with `tagPattern: "{name}-v{version}"`, matching the release-please tag convention (e.g. `devops-v0.0.1`).
5. **Marketplace output is defaulted** to `.claude-plugin/marketplace.json`; APM consumes this catalog. The file is generated, never hand-edited.
6. **Local marketplace entries omit `version`.** For local (`./`) sources, `apm pack` reads the display version from each package's own `apm.yml`, so the plugin manifest is the single source of truth and release-please keeps the marketplace in sync automatically. Declaring `version` on a local entry overrides that and reintroduces drift: `--check-versions` validates tag alignment against the plugin manifest, so no gate ever compares the two values. Only remote packages, which have no local manifest to read, declare `version` or `ref`.
7. **The root `version:` is an inert placeholder.** The root manifest is never published as a package (release-please tracks only `plugins/*`) and no gate reads it, so it stays at `1.0.0`. Do not bump it during a plugin release; it becomes live only if the repository itself is ever published as an installable package.
8. **Pin packages with literal release tags.** APM 0.30.0 resolves `#<plugin>-v<version>` to the tag commit and records it in `apm.lock.yaml`. The `#<version>` and semver range forms fail in APM 0.30.0 because the generated `marketplace.json` does not export `tag_pattern`. The `apm marketplace add` warning about a mutable ref is informational in 0.30.0; it still prints when a `#ref` is supplied. Use `apm install --frozen` in CI.

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

After modifying any `apm.yml`, plugin structure, or regenerating the marketplace, run these gates before finishing:

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
4. **Document the skill:** add it to the plugin `README.md` skills table. No manifest registration is required; APM discovers `.apm/skills/<name>/`.
5. **Regenerate the marketplace:** run `apm pack` from the repository root, then commit `.claude-plugin/marketplace.json`
6. **Validate:** run `apm audit --file <SKILL.md>` and `apm pack --check-versions --check-clean`; confirm the skill loads in the target harness

### Creating a New Plugin

A plugin packages one or more skills for distribution via the APM marketplace.

1. **Create plugin directory:** `/plugins/<plugin-name>/`
2. **Add APM manifest:** `<plugin>/apm.yml` with `name`, `version`, `description`, and `targets` (`copilot`, `claude`, `opencode`)
3. **Add the plugin to the marketplace:** register it in the root `apm.yml` `marketplace.packages` list with a `./plugins/<plugin-name>` source
4. **Create skills directory:** `/plugins/<plugin-name>/.apm/skills/`
5. **Create skill subdirectories:** One per skill (e.g., `.apm/skills/generate-adr/`)
6. **Add SKILL.md to each skill:** Markdown file with YAML frontmatter (name, description)
7. **Add release scaffolding:** `<plugin>/version.txt` and `<plugin>/CHANGELOG.md`, and register the plugin in `release-please-config.json` + `.release-please-manifest.json` with only the `apm.yml` extra-file
8. **Regenerate the marketplace:** run `apm pack` from the repository root, then commit `.claude-plugin/marketplace.json`
9. **Create plugin README:** include the skills table, per-harness APM install commands, usage, and troubleshooting
10. **Add the plugin to the root README:** add a row to the plugin table linking to the plugin README
11. **Test skill invocation:** run `apm pack --check-versions --check-clean`; verify skills load in each target harness

**Plugin Structure Example:**

```
plugins/my-plugin/
├── apm.yml
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
- `.github/workflows/generate-marketplace.yml` regenerates and commits the marketplace on pull requests touching source manifests (`apm.yml`, `plugins/**/apm.yml`, `.release-please-manifest.json`)
- `.github/workflows/apm-check.yml` validates marketplace entries, version alignment, and marketplace cleanliness on every pull request
- `.github/workflows/release-please.yml` runs release-please; when it creates releases, the `publish` job resolves released plugin paths from the `paths_released` output into `{path, version, tag}` objects and runs a matrix of `.github/workflows/release-plugin.yml`
- `.github/workflows/release-plugin.yml` is a callable workflow (`workflow_call`, inputs `plugin-path` + `tag`) that gates (`apm marketplace check` + `apm pack --check-versions --check-clean`), packs an `apm pack --archive` ZIP per plugin, and attaches it to the component's `{name}-v{version}` release
- Release versioning is managed by release-please, which bumps each plugin's `apm.yml` and `version.txt` and tags `{name}-v{version}`. Because local marketplace entries carry no `version`, the regenerated marketplace picks up each new version automatically (see APM Packaging Standards, items 6 and 7).

All content changes are direct Markdown edits. Changes take effect upon commit.
