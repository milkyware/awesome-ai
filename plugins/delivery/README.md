# Delivery Plugin

**Produce implementation-ready plans and create delivery-ready Jira tickets with structured, AI-guided workflows.**

## Skills

| Skill                 | Purpose                                                                                          | Output                                                                   |
| --------------------- | ------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------ |
| `implementation-plan` | Convert an agreed design into a repository-grounded implementation contract                      | Ordered steps, requirements, tests, validation, risks, and done criteria |
| `create-jira-ticket`  | Create a Jira issue from a structured or free-form request through the Atlassian MCP integration | Created Jira issue key and URL, or a complete ticket draft               |

All skills enforce the repository [writing standards](../../README.md#writing-standards).

## Install

The plugin is published from the awesome-ai marketplace as an APM package. Register the marketplace once, then install the plugin for your harness.

```bash
apm marketplace add milkyware/awesome-ai
```

Use one target per project; APM reconciles the active target and removes deployments for targets that are no longer selected.

```bash
# GitHub Copilot CLI
apm install delivery@awesome-ai --target copilot

# Claude Code
apm install delivery@awesome-ai --target claude

# OpenCode
apm install delivery@awesome-ai --target opencode
```

For a reproducible install, pin the plugin to its release tag:

```bash
apm install delivery@awesome-ai#delivery-v0.0.2 --target copilot
```

Replace the tag with the latest release for this plugin, then commit `apm.yml` and `apm.lock.yaml` and use `apm install --frozen` in CI. See [Reproducible installs](../../README.md#reproducible-installs).

## Usage

### Produce an implementation plan

Ask the agent to plan an agreed change. The skill will:

1. Honour applicable project instructions, including `AGENTS.md` and instruction files.
2. Inspect affected projects, files, patterns, tests, and validation commands.
3. Produce the implementation contract: objective, agreed design, repository context, ordered steps, behavioural requirements, test plan, validation, risks, and completion criteria.

**Output:** A concise, evidence-backed plan sufficient for an implementation agent, with no repository modifications.

### Create a Jira ticket

Ask the agent to create a Jira issue. The skill will:

1. Establish the project, issue type, summary, scope, and whether a parent link is wanted.
2. Discover and validate Jira metadata through the Atlassian MCP server.
3. Author the ticket using the fixed description structure, adapted for Bug, Spike, Epic, or Sub-task.
4. Confirm once before writing, create the issue, and report the key and URL.

**Output:** A created Jira issue, or a complete ticket draft with no fabricated key or URL if creation is unavailable.

Requires a working Atlassian MCP integration with Jira create permission.

Invoke a skill from your agent's skill picker, or use `/skills <name>` in GitHub Copilot CLI.

## Troubleshooting

**Q: The skill is not appearing in `/skills`.**

A: Reload skills with `/skills reload` or restart the CLI.

**Q: Jira creation reports no access.**

A: Connect the Atlassian MCP server (`https://mcp.atlassian.com/v1/mcp`) with Jira metadata and create permission, then retry. The skill provides a manual draft in the meantime.

## Contributing

Report issues and suggest improvements in the [awesome-ai repository](https://github.com/milkyware/awesome-ai/issues). Reference the plugin and skill, and include the context or output that triggered the issue.

## License

This plugin is licensed under the MIT License. See the [awesome-ai repository LICENCE](../../LICENCE) for details.

## Related resources

- [Atlassian Remote MCP Server](https://mcp.atlassian.com/v1/mcp)
- [awesome-ai repository](https://github.com/milkyware/awesome-ai)
