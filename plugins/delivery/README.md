# Delivery Plugin

**Produce implementation-ready plans and create delivery-ready Jira tickets, using structured, AI-guided workflows.**

## Overview

The **@delivery** plugin provides two specialised skills for delivery handoff
and tracking:

- **implementation-plan** – Converts an agreed design into a self-contained
  implementation contract: ordered steps, behavioural requirements, test
  cases, validation commands, risks and completion criteria. Inspects the
  repository; makes no changes.
- **create-jira-ticket** – Creates a Jira Story, Bug, Task, Epic, Spike or
  Sub-task from structured or free-form requests via the Atlassian MCP
  integration (`https://mcp.atlassian.com/v1/mcp`), with testable acceptance
  criteria.

The skills enforce UK English, technical precision, and no fabrication.

## Installation

The plugin is published from the awesome-ai repository as an APM package. Install
it with APM:

```bash
apm marketplace add milkyware/awesome-ai
apm install delivery@awesome-ai
```

For GitHub Copilot CLI, add the repository marketplace, then install the plugin:

```bash
copilot /plugin marketplace add https://github.com/milkyware/awesome-ai
copilot /plugin install delivery
```

For Claude Code:

```bash
apm marketplace add milkyware/awesome-ai
apm install delivery@awesome-ai
```

Or enable it directly by adding to your repository's `.github/copilot/settings.json`:

```json
{
  "enabledPlugins": {
    "delivery": true
  }
}
```

## Usage

### Produce an implementation plan

Ask the agent to plan an agreed change. The skill will:

1. Honour applicable project instructions (`AGENTS.md`,
   `.github/instructions/*`).
2. Inspect affected projects, files, patterns, tests and validation commands.
3. Produce the implementation contract: objective, agreed design, repository
   context, ordered steps, behavioural requirements, test plan, validation,
   risks and completion criteria.

**Output:** A concise, evidence-backed plan sufficient for an implementation
agent, with no repository modifications.

### Create a Jira ticket

Ask the agent to create a Jira issue. The skill will:

1. Establish project, issue type, summary, scope and – up front – whether a
   parent link is wanted.
2. Discover and validate Jira metadata via the Atlassian MCP server.
3. Author the ticket using the fixed description structure
   (Background / Problem / Proposed Change / Acceptance Criteria /
   Technical Notes / Out of Scope, adapted for Bug / Spike / Epic /
   Sub-task).
4. Confirm once before writing, create the issue, and report the key and URL.

**Output:** A created Jira issue, or – if creation is unavailable – a complete
ticket draft with no fabricated key or URL.

Requires a working Atlassian MCP integration with Jira create permission.

## Command Reference

### `/skills implementation-plan`

| Aspect         | Details                                                        |
| -------------- | -------------------------------------------------------------- |
| **Skill Name** | `implementation-plan`                                          |
| **Purpose**    | Repository-grounded implementation handoff for a coding agent  |
| **Output**     | Ordered steps, requirements, tests, validation, risks, done criteria |
| **Language**   | UK English                                                     |

### `/skills create-jira-ticket`

| Aspect         | Details                                                     |
| -------------- | ----------------------------------------------------------- |
| **Skill Name** | `create-jira-ticket`                                        |
| **Purpose**    | Create Jira issues with testable acceptance criteria        |
| **Output**     | Created Jira issue key and URL, or a complete ticket draft  |
| **Language**   | UK English                                                  |

## Key Features

- **Guided Workflows** – Structured, gated sequences ensure completeness.
- **No Fabrication** – File paths, symbols, field IDs and issue keys come
  from verified evidence only.
- **Generic by Default** – No hard-coded projects, issue types or custom
  fields; metadata is discovered per project.
- **Fixed Ticket Structure** – Jira descriptions follow a consistent,
  delivery-ready shape.

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

**Q: Jira creation reports no access.**
A: Connect the Atlassian MCP server (`https://mcp.atlassian.com/v1/mcp`)
with Jira metadata and create permission, then retry. The skill will provide
a manual draft in the meantime.

## Contributing

To report issues or suggest improvements to the @delivery plugin:

1. Open an issue in the [awesome-ai repository](https://github.com/milkyware/awesome-ai)
2. Reference the plugin name and the skill.
3. Include the context or output that triggered the issue.

## License

This plugin is licensed under the MIT License. See the [awesome-ai repository LICENCE](../../LICENCE) for details.

## Related Resources

- [Atlassian Remote MCP Server](https://mcp.atlassian.com/v1/mcp)
- [awesome-ai Repository](https://github.com/milkyware/awesome-ai)
