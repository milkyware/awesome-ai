# Source Control Plugin

**Name branches in the repository's own convention, record changes as Conventional Commits, and raise reviewable pull requests, using structured, gated workflows.**

## Skills

| Skill                 | Purpose                                                                                                              | Output                                                                     |
| --------------------- | -------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------- |
| `create-branch`       | Create a branch named in the repository's convention, from the correct base, with no upstream                        | Created branch, or a validated name and the exact command                  |
| `commit-changes`      | Split the working tree into logical commits with Conventional Commits messages                                       | Created commits, or a proposed grouping and message                        |
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
apm install source-control@awesome-ai --target copilot

# Claude Code
apm install source-control@awesome-ai --target claude

# OpenCode
apm install source-control@awesome-ai --target opencode
```

For a reproducible install, pin the plugin to its release tag:

```bash
apm install source-control@awesome-ai#source-control-v0.0.2 --target copilot
```

Replace the tag with the latest release for this plugin, then commit `apm.yml` and `apm.lock.yaml` and use `apm install --frozen` in CI. See [Reproducible installs](../../README.md#reproducible-installs).

### MCP servers

Branch and commit work need only Git. The plugin also declares the GitHub MCP server for pull requests, which APM configures for each active target.

The server runs the [`ghcr.io/github/github-mcp-server`](https://github.com/github/github-mcp-server) container and authenticates through GitHub OAuth. Docker must be available, and port `8085` must be free for the OAuth callback. The `gh` CLI remains the primary path in every skill; the MCP server is the substitute when the CLI is unavailable.

A self-defined MCP server declared by an installed package needs trust before it is activated. Pass `--trust-transitive-mcp` to approve these non-interactively, or redeclare the server in your own `apm.yml`.

## Usage

### Create a branch

Ask the agent to start a branch for the work. The skill will:

1. Resolve the kind of work and a short description, taking an issue or ticket key when one is supplied.
2. Read the repository convention from configuration or from recent branches, and fall back to a documented default rather than inventing a prefix.
3. Compose and validate the name against `git check-ref-format`, then check that it does not already exist locally or on the remote.
4. Resolve the base, fetch it, and refuse to continue during a rebase, merge, cherry-pick or revert.
5. Create the branch with `--no-track` and confirm it has no upstream, then state whether uncommitted changes travelled with it.

**Output:** A local branch, or a validated name and the exact command when creation is not possible.

Branch creation is local. Publishing is a separate step, and the branch is created without an upstream, so the first push is an explicit publish rather than a push to the branch it started from. `gh issue develop` is the only operation that writes to the remote, and it is used only when the branch is to be linked to an issue.

### Commit changes

Ask the agent to commit the changes. The skill will:

1. Read the repository rules: a commitlint configuration, a commit validator, contribution guidance, then the message shape in recent history.
2. Check for a rebase, merge, cherry-pick or revert in progress, and stop when one must be finished first.
3. Propose one commit per logical change, naming the paths each commit owns.
4. Stage those paths explicitly, refusing secrets, build output and agent working state, and verify that the staged diff is not empty.
5. Compose a Conventional Commits message, with a scope drawn from the repository's vocabulary or from the branch name.
6. Commit, and report each new commit by its short identity.

**Output:** One commit per logical change, or a proposed grouping and message when the commit cannot be made.

The skill never pushes, amends, rebases or rewrites history, and never bypasses a failing hook. When a change spans several types, it prefers several commits.

### Create a pull request

Ask the agent to open a pull request for the branch. The skill will:

1. Resolve the repository, base branch and head branch, and refuse to continue from a detached checkout, an unpushed branch, or a branch with no commits ahead of the base.
2. Check for an existing pull request for the branch, and review every changed file.
3. Compose a Conventional Commits title, reading the repository's commitlint or title configuration before falling back to the default types.
4. Build the body from the repository's own pull request template, preserving its structure and removing only the authoring comments. Without a template, it uses the reference structure in [pull-request-template.md](.apm/skills/create-pull-request/references/pull-request-template.md).
5. Tick only the checkboxes that the change evidences, and ask for screenshots when the change affects the UI.
6. Create the pull request as ready for review, and report the number and URL.

**Output:** A created pull request, or a complete title and body with no fabricated number or URL when creation is not possible.

Pull requests are created ready for review; a draft is created only when one is requested. The skill never commits as part of opening a pull request. Uncommitted changes are reported, and the `commit-changes` skill is the place to resolve them.

## Maintaining this plugin

`commit-changes/references/conventional-commits.md` is the canonical commit standard for this plugin, with the [Conventional Commits 1.0.0 specification](https://www.conventionalcommits.org/en/v1.0.0/#specification) as its authority. Every skill that composes a commit message or a pull request title derives its rules from it.

`create-pull-request` needs the type vocabulary inline, so it carries a title-only extract of the table and links to the canonical file for the rest. A skill ships only its own `references/` directory, and the sibling skills arrive with it, so the link resolves after installation. Change the canonical file first, then the extract, and keep both tables identical.

## Troubleshooting

**Q: The skill is not appearing in `/skills`.**

A: Reload skills with `/skills reload` or restart the CLI.

**Q: Branch creation refuses because the name already exists.**

A: The check covers local branches and `origin`. Delete the stale branch with `git branch -d`, or with `git push origin --delete <branch>`, and retry. Otherwise choose a name that differs in wording rather than in case.

**Q: The new branch already contains changes that were uncommitted.**

A: `git switch -c` carries uncommitted changes onto the new branch. That is expected behaviour. Commit them, or move them elsewhere with `git stash` first.

**Q: A push from a GUI landed the branch on the default branch.**

A: The branch inherited an upstream from its start point, because `branch.autoSetupMerge` defaults to `true` and the start point was the default branch. Remove the upstream with `git branch --unset-upstream`, publish explicitly with `git push -u origin <branch>`, and confirm the installed skill creates branches with `--no-track`.

**Q: Committing reports that the staged diff is empty.**

A: The path is most likely a line-ending rewrite, common under `core.autocrlf=true`, where `git status` reports a modification that `git diff` does not. Confirm with `git diff -- <path>`; when the output is empty, the file is unchanged and should not be committed alone.

**Q: A pre-commit hook failed and no commit was created.**

A: The hook output states the reason. Fix the cause and retry; the skill never passes `--no-verify`. A formatter hook usually rewrote files, so re-stage the paths it touched.

**Q: The commit landed on the default branch.**

A: Branch before committing. The skill warns but does not block, because each repository decides its own policy.

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

- [Conventional Commits 1.0.0](https://www.conventionalcommits.org/en/v1.0.0/#specification)
- [Git: git-switch](https://git-scm.com/docs/git-switch)
- [Git: git-check-ref-format](https://git-scm.com/docs/git-check-ref-format)
- [GitHub CLI: gh issue develop](https://cli.github.com/manual/gh_issue_develop)
- [GitHub CLI: gh pr create](https://cli.github.com/manual/gh_pr_create)
- [awesome-ai repository](https://github.com/milkyware/awesome-ai)
