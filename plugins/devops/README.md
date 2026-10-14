# DevOps Plugin

**Convert Azure DevOps pipelines to GitHub Actions and onboard repositories with release-please, using structured, AI-guided workflows.**

## Overview

The **@devops** plugin provides two specialised skills for CI/CD migration and
release automation:

- **convert-az-pipeline** – Converts an Azure Pipelines template into a reusable
  GitHub Actions composite action or `workflow_call` workflow, mapping tasks,
  expressions, and variables along the way.
- **onboard-release-please** – Onboards a repository with release-please by
  generating the manifest and configuration, adding the required workflows, and
  guiding the repository-settings checklist.

The skills are built on enterprise-grade workflows. They enforce UK English,
technical precision, and no fabrication.

## Installation

The plugin is published from the awesome-ai repository as an APM package. Install
it with APM:

```bash
apm marketplace add milkyware/awesome-ai
apm install devops@awesome-ai
```

For GitHub Copilot CLI, add the repository marketplace, then install the plugin:

```bash
copilot /plugin marketplace add https://github.com/milkyware/awesome-ai
copilot /plugin install devops
```

For Claude Code:

```bash
apm marketplace add milkyware/awesome-ai
apm install devops@awesome-ai
```

Or enable it directly by adding to your repository's `.github/copilot/settings.json`:

```json
{
  "enabledPlugins": {
    "devops": true
  }
}
```

## Usage

### Convert an Azure Pipeline

Ask the agent to convert an Azure Pipelines template. The skill will:

1. Read the Azure Pipelines template you provide.
2. Recommend a composite action or a reusable workflow, and let you choose.
3. Convert parameters and steps, splitting scripts longer than 4 lines into
   separate files.
4. Generate the `action.yml` or workflow file plus the matching `README.md`
   documentation.

**Output:** A composite action or `workflow_call` workflow with documentation and
no remaining Azure Pipelines syntax.

### Onboard Release Please

Ask the agent to onboard a repository with release-please. The skill will:

1. Determine the current version from the latest tag.
2. Ask whether the repository is a single package or a mono-repo.
3. Ask whether versioning should start pre-1.0 (`0.0.1`) or at `1.0.0`.
4. Present a generic default configuration, and tailor it to your answers.
5. Write `.release-please-manifest.json` and `release-please-config.json`.
6. Add the release-please and PR-title validation workflows.
7. Prompt the repository-settings checklist.

**Output:** A validated release-please configuration and the supporting workflows.

## Command Reference

### `/skills convert-az-pipeline`

| Aspect         | Details                                                  |
| -------------- | -------------------------------------------------------- |
| **Skill Name** | `convert-az-pipeline`                                    |
| **Purpose**    | Convert Azure Pipelines templates to GitHub Actions      |
| **Output**     | Composite action or reusable workflow with documentation |
| **Language**   | UK English                                               |

### `/skills onboard-release-please`

| Aspect         | Details                                                                  |
| -------------- | ------------------------------------------------------------------------ |
| **Skill Name** | `onboard-release-please`                                                 |
| **Purpose**    | Onboard a repository with release-please                                 |
| **Output**     | `release-please-config.json`, `.release-please-manifest.json`, workflows |
| **Language**   | UK English                                                               |

## Key Features

- **Guided Workflows** – Structured, gated question sequences ensure completeness.
- **Task Mapping** – Azure Pipelines tasks, expressions, and variables are mapped
  to current, widely adopted GitHub Actions.
- **Generic Defaults** – Release-please configuration defaults contain no
  repository-specific assumptions.
- **No Fabrication** – Clear rules prevent hallucinated actions or options.

## Writing Standards

All skills enforce strict writing rules:

- **Concise language** – No marketing tone or storytelling.
- **Technical precision** – Fact-based, specific statements only.
- **Consistency** – Terminology aligned within documents.
- **No assumptions** – Questions asked if gaps are detected.
- **Markdown compliance** – Output adheres to linting standards.

## Troubleshooting

**Q: The skill isn't appearing in `/skills`**
A: Reload skills with `/skills reload` or restart the CLI.

**Q: Can I convert a nested Azure Pipelines template?**
A: Yes. The skill recursively handles nested templates, asking for each one
whether to convert it or reference an already converted action.

**Q: My repository uses a variable group for secrets.**
A: The skill will not inline secrets. It maps variable groups to repository or
environment secrets and variables, and flags secret redesign where required.

## Contributing

To report issues or suggest improvements to the @devops plugin:

1. Open an issue in the [awesome-ai repository](https://github.com/milkyware/awesome-ai)
2. Reference the plugin name and the skill.
3. Include the context or output that triggered the issue.

## License

This plugin is licensed under the MIT License. See the [awesome-ai repository LICENCE](../../LICENCE) for details.

## Related Resources

- [GitHub Actions documentation](https://docs.github.com/en/actions)
- [release-please](https://github.com/googleapis/release-please)
- [Azure Pipelines YAML schema](https://learn.microsoft.com/en-us/azure/devops/pipelines/yaml-schema/)
