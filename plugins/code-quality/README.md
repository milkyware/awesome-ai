# Code Quality Plugin

**Review branch changes for correctness, scope, and merge readiness with a structured, AI-guided workflow.**

## Skills

| Skill         | Purpose                                           | Output                                                   |
| ------------- | ------------------------------------------------- | -------------------------------------------------------- |
| `code-review` | Read-only pre-PR review of the current Git branch | Findings, testing and scope summary, and a merge verdict |

All skills enforce the repository [writing standards](../../README.md#writing-standards).

## Install

The plugin is published from the awesome-ai marketplace as an APM package. Register the marketplace once, then install the plugin for your harness.

```bash
apm marketplace add milkyware/awesome-ai
```

Use one target per project; APM reconciles the active target and removes deployments for targets that are no longer selected.

```bash
# GitHub Copilot CLI
apm install code-quality@awesome-ai --target copilot

# Claude Code
apm install code-quality@awesome-ai --target claude

# OpenCode
apm install code-quality@awesome-ai --target opencode
```

For a reproducible install, pin the plugin to its release tag:

```bash
apm install code-quality@awesome-ai#code-quality-v0.0.1 --target copilot
```

Replace the tag with the latest release for this plugin, then commit `apm.yml` and `apm.lock.yaml` and use `apm install --frozen` in CI. See [Reproducible installs](../../README.md#reproducible-installs).

## Usage

### Review a branch

Ask the agent to review the current branch. The skill will:

1. Read applicable repository guidance, including `AGENTS.md` and instruction files.
2. Establish the project technology context from repository evidence.
3. Determine the branch, base, merge base, and diff.
4. Confirm the inferred branch goal with you where it is unclear.
5. Report findings by severity, testing gaps, scope assessment, and a merge verdict.

**Output:** A concise review with findings, a testing summary, a scope assessment, and one of: Ready for merge, Ready after minor changes, Further review required, or Not ready for merge.

Invoke the skill from your agent's skill picker, or use `/skills code-review` in GitHub Copilot CLI.

## Troubleshooting

**Q: The skill is not appearing in `/skills`.**

A: Reload skills with `/skills reload` or restart the CLI.

## Contributing

Report issues and suggest improvements in the [awesome-ai repository](https://github.com/milkyware/awesome-ai/issues). Reference the plugin and skill, and include the context or output that triggered the issue.

## License

This plugin is licensed under the MIT License. See the [awesome-ai repository LICENCE](../../LICENCE) for details.

## Related resources

- [awesome-ai repository](https://github.com/milkyware/awesome-ai)
