---
name: create-branch
description: Create a Git branch named in the repository's own convention, from the correct base, after checking that the working tree can take it. Use when asked to start a branch, name a branch, begin work on an issue or ticket, or check whether a branch name complies with the repository convention.
---

# Create Branch

Start a branch that a reviewer can place at a glance. Read the repository's own convention before inventing a name, and refuse to create a branch that the working tree cannot take.

## Prerequisites and boundaries

- Run every command from the repository root. Confirm it once with `git rev-parse --show-toplevel`, then use `git -C <root>` when the session started elsewhere.
- Creating a branch is local and reversible. Publishing it is not part of this skill.
- Never push, configure an upstream, delete, rename or move a branch, create an orphan branch, or change Git configuration. `gh issue develop` is the only operation that writes to the remote, and it needs explicit approval.
- Never create a branch named after a trunk branch, and never reuse a name that already exists locally or on the remote.
- Never add an agent or vendor prefix to a branch name. The name describes the work, not the tool that produced it.
- Report only what was observed. Never claim a branch exists until `git rev-parse --verify refs/heads/<name>` succeeds.

## 1. Establish the intent

Resolve two things from the request, and ask only for what is missing:

1. **The kind of work** — new capability, defect, urgent fix, release preparation or maintenance.
2. **A short description** — the outcome, not the mechanism. Take it from the issue or ticket title when one is supplied.

Capture an issue or ticket key when the user gives one. Never invent one.

## 2. Discover the naming convention

Read the repository's convention in this order, and stop at the first source that answers:

1. Explicit guidance in `CONTRIBUTING.md`, `AGENTS.md`, or a contributing section of `README.md`.
2. A branch-name validator in `.github/workflows`, or a pre-commit hook that checks branch names.
3. Recent branch names from `git branch -a --sort=-committerdate`. Use them only when the prefixes agree with one another. A repository that mixes `feat/`, `fix/` and `feature/` has no convention to read, so treat that as no answer rather than picking the majority.
4. The default table below.

| Prefix                | Use for                                                             | Typical commit type |
| --------------------- | ------------------------------------------------------------------- | ------------------- |
| `feature/` or `feat/` | New capability                                                      | `feat`              |
| `bugfix/` or `fix/`   | Defect in existing behaviour                                        | `fix`               |
| `hotfix/`             | Urgent production fix                                               | `fix`               |
| `release/`            | Release preparation, with a version suffix such as `release/v1.2.0` | `chore`             |
| `chore/`              | Dependencies, documentation or configuration                        | `chore`             |

State which source you used, and say so explicitly when you fell back to the default table. Never invent a prefix, and never widen the table with a prefix the repository does not use.

## 3. Compose the name

```text
<type>/<description>
```

- Put a ticket or issue key first in the description when one exists, as in `feature/ABC-123-add-token-refresh`.
- Use lower case and hyphens. Keep the description to two to five words.
- Aim for 50 characters in total, and truncate on a word boundary when the description is longer.
- Describe the outcome. `fix/login-timeout` is useful; `fix/bug` and `feature/changes` are not.

The prefix must agree with the commit type the work will produce. A branch called `feature/...` whose commits read `fix:` was named wrongly.

## 4. Validate the name

Run the authoritative check first:

```bash
git check-ref-format --branch "<name>"
```

A non-zero exit means Git will reject the name. Then confirm the following, without relying on the check alone:

- No upper case, spaces, underscores, or `~^:?*[\` characters.
- No `..`, no `--`, and no `.-` or `-.` sequence.
- No leading or trailing hyphen or dot, and no trailing `.lock`.
- Not a trunk branch name such as `main`, `master`, `develop` or `origin/HEAD`.
- Not already present, in either place:

```bash
git branch --list "<name>"
git ls-remote --heads origin "<name>"
```

Compare case-insensitively. Windows and macOS fold case in the filesystem while Git may still record two refs, so `Feat/login` and `feat/login` collide in practice. When the name is taken, propose three alternatives that differ in wording rather than in case.

## 5. Resolve the base

1. Take the base from the request when the user names one.
2. Otherwise use the remote default:

```bash
git symbolic-ref --short refs/remotes/origin/HEAD
```

3. If that fails, use the first of `main`, `master` or `develop` that exists locally, and state the assumption.

Then fetch the base so the branch does not start stale:

```bash
git fetch origin "<base>"
```

A base other than the default is a stacked branch. Say so, and name the branch it stacks on, because the pull request will target that base rather than the default.

## 6. Check that the working tree can take the branch

Stop and report when any of these is true:

- A rebase, merge, cherry-pick or revert is in progress. `git status --long` names the operation, and `git rev-parse -q --verify --symbolic-full-name MERGE_HEAD` prints a ref when a merge is active, as do the `CHERRY_PICK_HEAD` and `REVERT_HEAD` equivalents.
- The repository has no commit yet, so there is no base to branch from.
- Paths are unmerged, which `git diff --name-only --diff-filter=U` lists.

Uncommitted changes need care rather than refusal. `git switch -c` carries them onto the new branch, which is usually what the user wants and is never what they expect. State that the changes will travel. Ask before continuing when the request implies branching away from them, or when they belong to a different concern.

A detached checkout is allowed only as an explicit rescue: `git switch -c` keeps the commits reachable. Say that this is what the operation does before running it.

## 7. Create the branch

From the fetched base:

```bash
git switch -c "<name>" "origin/<base>"
```

From the current commit, when the user wants the work already on this checkout:

```bash
git switch -c "<name>"
```

Do not add `--track`, do not set an upstream, and do not push.

## 8. Offer issue linkage

When the user named a GitHub issue and wants the branch linked to it, the branch is created on the remote:

```bash
gh issue develop <number> --name "<name>" --base "<base>" --checkout
```

This links the branch in the issue sidebar and configures it as the pull request base. It also pushes, so ask before running it. Use `git switch -c` when the user does not need the linkage.

## 9. Report the result

State:

- The branch name, and which convention source it came from.
- The base and its short commit, from `git rev-parse --short HEAD`.
- Whether uncommitted changes were carried onto the branch.
- Whether the branch is local only, and the exact command to publish it.

## Related operations

This skill creates branches only. Use the matching command for a related change, on explicit request:

- Publish the branch: `git push -u origin "<name>"`
- Rename it: `git branch -m "<new-name>"`
- Delete it after merge: `git branch -d "<name>"`
- List local branches: `git branch --sort=-committerdate`
