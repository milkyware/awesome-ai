# Code-Quality Plugin

**Review branch changes for correctness, scope and merge readiness, using structured, AI-guided workflows.**

## Overview

The **@code-quality** plugin provides:

- **code-review** – Reviews the code in the current Git branch before a pull
  request is raised, against the branch objective, repository instructions,
  code quality, tests, logging, scope and merge readiness.

The skill enforces UK English, technical precision, repository evidence over
preference, and no fabrication.

## Installation

The plugin is published from the awesome-ai repository as an APM package. Install
it with APM:

```bash
apm marketplace add milkyware/awesome-ai
apm install code-quality@awesome-ai
```

For GitHub Copilot CLI, add the repository marketplace, then install the plugin:

```bash
copilot /plugin marketplace add https://github.com/milkyware/awesome-ai
copilot /plugin install code-quality
```

For Claude Code:

```bash
apm marketplace add milkyware/awesome-ai
apm install code-quality@awesome-ai
```

Or enable it directly by adding to your repository's `.github/copilot/settings.json`:

```json
{
  "enabledPlugins": {
    "code-quality": true
  }
}
```

## Usage

### Review a branch

Ask the agent to review the current branch. The skill will:

1. Read applicable repository guidance (`AGENTS.md`, `.github/instructions/*`).
2. Establish the project technology context from repository evidence.
3. Determine the branch, base, merge base and diff.
4. Confirm the inferred branch goal with you where it is unclear.
5. Report severed findings (Critical / High / Medium / Low / Question),
   testing gaps, scope assessment and a merge verdict.

**Output:** A concise review with findings, testing summary, scope
assessment and one of Ready for merge / Ready after minor changes /
Further review required / Not ready for merge.

## Command Reference

### `/skills code-review`

| Aspect         | Details                                            |
| -------------- | -------------------------------------------------- |
| **Skill Name** | `code-review`                                      |
| **Purpose**    | Read-only pre-PR review of the current Git branch  |
| **Output**     | Findings, testing and scope summary, merge verdict |
| **Language**   | UK English                                         |

## Key Features

- **Guided Workflow** – Fixed review sequence ensures completeness.
- **Repository Evidence** – Recommendations fit the existing stack; no new
  technology is introduced without demonstrated need.
- **No Fabrication** – Findings cite file, line or symbol with impact.
- **Safe Validation** – Read-only commands only; nothing is modified.

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

## Contributing

To report issues or suggest improvements to the @code-quality plugin:

1. Open an issue in the [awesome-ai repository](https://github.com/milkyware/awesome-ai)
2. Reference the plugin name and the skill.
3. Include the context or output that triggered the issue.

## License

This plugin is licensed under the MIT License. See the [awesome-ai repository LICENCE](../../LICENCE) for details.

## Related Resources

- [awesome-ai Repository](https://github.com/milkyware/awesome-ai)
