# DevOps Plugin

**Convert Azure Pipelines templates to GitHub Actions and onboard repositories with release-please using structured, AI-guided workflows.**

## Skills

| Skill                    | Purpose                                                                                         | Output                                                           |
| ------------------------ | ----------------------------------------------------------------------------------------------- | ---------------------------------------------------------------- |
| `convert-az-pipeline`    | Convert an Azure Pipelines template into a reusable GitHub Actions composite action or workflow | Composite action or `workflow_call` workflow with documentation  |
| `onboard-release-please` | Onboard a repository with release-please for single-package or mono-repo layouts                | Release-please configuration, manifest, and supporting workflows |

All skills enforce the repository [writing standards](../../README.md#writing-standards).

## Install

The plugin is published from the awesome-ai marketplace as an APM package. Register the marketplace once, then install the plugin for your harness.

```bash
apm marketplace add milkyware/awesome-ai
```

Use one target per project; APM reconciles the active target and removes deployments for targets that are no longer selected.

```bash
# GitHub Copilot CLI
apm install devops@awesome-ai --target copilot

# Claude Code
apm install devops@awesome-ai --target claude

# OpenCode
apm install devops@awesome-ai --target opencode
```

For a reproducible install, pin the plugin to its release tag:

```bash
apm install devops@awesome-ai#devops-v0.0.2 --target copilot
```

Replace the tag with the latest release for this plugin, then commit `apm.yml` and `apm.lock.yaml` and use `apm install --frozen` in CI. See [Reproducible installs](../../README.md#reproducible-installs).

## Usage

### Convert an Azure Pipeline

Ask the agent to convert an Azure Pipelines template. The skill will:

1. Read the Azure Pipelines template you provide.
2. Recommend a composite action or a reusable workflow, and let you choose.
3. Convert parameters and steps, splitting scripts longer than four lines into separate files.
4. Generate the `action.yml` or workflow file plus matching `README.md` documentation.

**Output:** A composite action or `workflow_call` workflow with documentation and no remaining Azure Pipelines syntax.

### Onboard release-please

Ask the agent to onboard a repository with release-please. The skill will:

1. Determine the current version from the latest tag.
2. Ask whether the repository is a single package or a mono-repo.
3. Ask whether versioning should start pre-1.0 (`0.0.1`) or at `1.0.0`.
4. Present a generic default configuration and tailor it to your answers.
5. Write `.release-please-manifest.json` and `release-please-config.json`.
6. Add the release-please and PR-title validation workflows.
7. Prompt the repository-settings checklist.

**Output:** A validated release-please configuration and the supporting workflows.

Invoke a skill from your agent's skill picker, or use `/skills <name>` in GitHub Copilot CLI.

## Troubleshooting

**Q: The skill is not appearing in `/skills`.**

A: Reload skills with `/skills reload` or restart the CLI.

**Q: Can I convert a nested Azure Pipelines template?**

A: Yes. The skill handles nested templates recursively and asks for each one whether to convert it or reference an already converted action.

**Q: My repository uses a variable group for secrets.**

A: The skill does not inline secrets. It maps variable groups to repository or environment secrets and variables, and flags secret redesign where required.

## Contributing

Report issues and suggest improvements in the [awesome-ai repository](https://github.com/milkyware/awesome-ai/issues). Reference the plugin and skill, and include the context or output that triggered the issue.

## License

This plugin is licensed under the MIT License. See the [awesome-ai repository LICENCE](../../LICENCE) for details.

## Related resources

- [GitHub Actions documentation](https://docs.github.com/en/actions)
- [release-please](https://github.com/googleapis/release-please)
- [Azure Pipelines YAML schema](https://learn.microsoft.com/en-us/azure/devops/pipelines/yaml-schema/)
