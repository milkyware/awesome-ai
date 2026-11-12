# Delivery Plugin

**Produce implementation-ready plans, create delivery-ready Jira tickets, open GitHub issues, and raise reviewable pull requests with structured, AI-guided workflows.**

## Skills

| Skill                 | Purpose                                                                                                              | Output                                                                     |
| --------------------- | -------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------- |
| `implementation-plan` | Convert an agreed design into a repository-grounded implementation contract                                          | Ordered steps, requirements, tests, validation, risks, and done criteria   |
| `create-jira-ticket`  | Create a Jira issue from a structured or free-form request through the Atlassian MCP integration                     | Created Jira issue key and URL, or a complete ticket draft                 |
| `create-github-issue` | Create a GitHub issue with type, size, and priority labels through the GitHub CLI                                    | Created issue number and URL, or a complete issue draft                    |
| `create-pull-request` | Open a reviewable pull request with a Conventional Commits title and a body built from the repository's own template | Created pull request number and URL, or a complete title, body and command |

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

### MCP servers

The plugin declares two MCP servers: the Atlassian remote server for Jira, and the GitHub MCP server for issues and pull requests. APM configures the declared servers for each active target.

The GitHub server runs the [`ghcr.io/github/github-mcp-server`](https://github.com/github/github-mcp-server) container and authenticates through GitHub OAuth. Docker must be available, and port `8085` must be free for the OAuth callback. The `gh` CLI remains the primary path in every skill; the MCP server is the substitute when the CLI is unavailable.

A self-defined MCP server declared by an installed package needs trust before it is activated. Pass `--trust-transitive-mcp` to approve these non-interactively, or redeclare the server in your own `apm.yml`.

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

### Create a GitHub issue

Ask the agent to open a GitHub issue. The skill will:

1. Resolve the repository and the type of work, and ask whether a parent issue is wanted.
2. Search open and closed issues before creating a new one.
3. Classify the work with one `type:`, one `size:`, and one `priority:` label, creating missing labels first.
4. Author the issue using the fixed description structure, adapted for Bug, Story, Feature, Task, Spike, or Epic.
5. Confirm once before writing, create the issue, and report the number and URL.

**Output:** A created GitHub issue, or a complete issue draft with no fabricated number or URL if creation is unavailable.

Requires an authenticated `gh` CLI with write access to the target repository, or the declared GitHub MCP server.

The label vocabulary is fixed: `type:` for `epic`, `feature`, `story`, `task`, `bug`, and `spike`; `size:` for `xs` to `xl`; `priority:` for `p0` to `p4`. An epic takes no size label. Canonical names, colours, and descriptions are in [github-labels.md](.apm/skills/create-github-issue/references/github-labels.md).

### Create a pull request

Ask the agent to open a pull request for the current branch. The skill will:

1. Resolve the repository, base branch, and head branch, and refuse to continue from a detached checkout, an unpushed branch, or a branch with no commits ahead of the base.
2. Check for an existing pull request for the branch, and review every changed file.
3. Compose a Conventional Commits title, reading the repository's commitlint or PR-title configuration before falling back to the default types.
4. Build the body from the repository's own pull request template, preserving its structure and removing only the authoring comments. Without a template, it uses the reference structure in [pull-request-template.md](.apm/skills/create-pull-request/references/pull-request-template.md).
5. Tick only the checkboxes that the change evidences, and ask for screenshots when the change affects the UI.
6. Create the pull request as ready for review, and report the number and URL.

**Output:** A created pull request, or a complete title and body with no fabricated number or URL if creation is unavailable.

Requires an authenticated `gh` CLI with write access to the target repository, or the declared GitHub MCP server.

Pull requests are created ready for review. A draft is created only when one is requested. When a UI change is detected without screenshots, the skill recommends the specific images to capture and leaves the section for the author rather than blocking.

Invoke a skill from your agent's skill picker, or use `/skills <name>` in GitHub Copilot CLI.

## Troubleshooting

**Q: The skill is not appearing in `/skills`.**

A: Reload skills with `/skills reload` or restart the CLI.

**Q: Jira creation reports no access.**

A: Connect the Atlassian MCP server (`https://mcp.atlassian.com/v1/mcp`) with Jira metadata and create permission, then retry. The skill provides a manual draft in the meantime.

**Q: GitHub issue creation reports no access.**

A: Run `gh auth status`, then `gh auth login` if needed, and confirm you have write access to the target repository. Alternatively, confirm the GitHub MCP server is running with `docker ps` and has completed its OAuth flow. The skill provides a complete draft and the exact command in the meantime.

**Q: GitHub issue creation fails because a label does not exist.**

A: Creating labels also requires write access. Ask the skill to reconcile the labels first, or create them with `gh label create` using the names and colours in [github-labels.md](.apm/skills/create-github-issue/references/github-labels.md).

**Q: The pull request is created as a draft unexpectedly.**

A: Drafts are created only when asked for. Mark it ready with `gh pr ready <number>`, or ask the skill to do so.

**Q: The pull request ignores the repository template.**

A: The template must be at `.github/pull_request_template.md`, `.github/PULL_REQUEST_TEMPLATE/`, `docs/pull_request_template.md`, or the repository root. Confirm the path and its case, then ask the skill to regenerate the body.

**Q: Pull request creation fails because the branch has no upstream.**

A: Push the branch first with `git push -u origin <branch>`, then retry. The skill reports the missing upstream instead of pushing on its own.

**Q: The GitHub MCP server is not configured after installing the plugin.**

A: Self-defined MCP servers declared by a package need trust. Re-run the install with `--trust-transitive-mcp`, or copy the `github` entry from the plugin's `apm.yml` into your own dependencies. Confirm the container starts with `docker run -i --rm -p 127.0.0.1:8085:8085 ghcr.io/github/github-mcp-server`.

## Contributing

Report issues and suggest improvements in the [awesome-ai repository](https://github.com/milkyware/awesome-ai/issues). Reference the plugin and skill, and include the context or output that triggered the issue.

## License

This plugin is licensed under the MIT License. See the [awesome-ai repository LICENCE](../../LICENCE) for details.

## Related resources

- [Atlassian Remote MCP Server](https://mcp.atlassian.com/v1/mcp)
- [GitHub MCP Server](https://github.com/github/github-mcp-server)
- [GitHub CLI: gh issue create](https://cli.github.com/manual/gh_issue_create)
- [GitHub CLI: gh pr create](https://cli.github.com/manual/gh_pr_create)
- [GitHub Docs: managing labels](https://docs.github.com/issues/using-labels-and-milestones-to-track-work/managing-labels)
- [awesome-ai repository](https://github.com/milkyware/awesome-ai)
