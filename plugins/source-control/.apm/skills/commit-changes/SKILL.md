---
name: commit-changes
description: Create one or more Git commits from the working tree, staging only the paths each logical change owns and writing a Conventional Commits message for it. Use when asked to commit changes, split work into logical commits, or write and record a commit message.
---

# Commit Changes

Record the working tree as one commit per logical change. The message is the smaller half of the job: deciding what belongs together, and what must never be staged, is the work.

Read [conventional-commits.md](references/conventional-commits.md) before composing a message. It is the standard this skill applies, with the Conventional Commits 1.0.0 specification as its authority.

## Prerequisites and boundaries

- Run every command from the repository root. Confirm it once with `git rev-parse --show-toplevel`, then use `git -C <root>` when the session started elsewhere.
- This skill commits. It never pushes, amends, rebases, resets, reverts, tags, or changes Git configuration.
- Never run `git commit` with `--no-verify`, `--allow-empty`, `--all` or `--patch`.
- Never stage with `git add -A`, `git add .`, `git add -u`, `git add -p` or `git add -i`. The first three take files nobody reviewed, and the last two wait for a person.
- Never state that a commit exists until `git rev-parse --short HEAD` returns a new commit identity.
- Never state a test, lint or build result that was not observed.

## 1. Read the repository rules

The repository's own rules override this skill. Read them in this order, and stop at the first source that answers:

1. A commitlint configuration: `.commitlintrc`, `.commitlintrc.json`, `commitlint.config.js` or `commitlint.config.mjs`.
2. A commit-message or pull request-title validator in `.github/workflows` that declares an explicit type list.
3. Contribution guidance in `CONTRIBUTING.md`, `AGENTS.md`, or a contributing section of `README.md`, including any required trailers.
4. `git log --oneline -20`, for the scope vocabulary and the message shape actually in use.

Fall back to the default types in the reference only when nothing answers.

## 2. Inspect the working tree

```bash
git status --porcelain
git diff
git diff --cached
```

Then check for an operation in progress, running each command on its own:

```bash
git rev-parse -q --verify --symbolic-full-name MERGE_HEAD
git rev-parse -q --verify --symbolic-full-name CHERRY_PICK_HEAD
git rev-parse -q --verify --symbolic-full-name REVERT_HEAD
git diff --name-only --diff-filter=U
```

A printed ref means that operation is mid-flight, and the index already holds its result. Stop for a rebase, an am session, a cherry-pick or a revert: the user must finish or abort it. A merge is different, and [7. Commit](#7-commit) covers it. Unmerged paths stop everything until they are resolved.

When nothing is staged and nothing is modified, stop. There is no commit to make.

If the current branch is the repository's default branch, say so before staging. Warn rather than block: the repository decides its own policy.

## 3. Decide the commits

Group the changes into one commit per logical change, and show the proposal before staging anything:

- **One concern per commit.** A defect fix and the refactor that enabled it are two commits. A feature and its tests are one.
- **Group by intent, not by directory.** Files that changed for the same reason belong together even when they sit far apart.
- **Keep generated and hand-written changes apart** when the repository commits both.
- **Never split within a file.** Intra-file hunks need `git add -p`, which waits for a person. Propose the split and let the user stage it.

Say which paths each commit will contain and why, and ask once when the grouping is a judgement call. A direct request with a clear grouping is authorisation.

## 4. Stage the paths

Stage explicitly, one commit at a time:

```bash
git add -- path/to/file path/to/directory '*.test.*'
```

Quote every glob. Without quotes the shell expands it, and a glob that matches nothing in a subdirectory silently stages nothing.

Refuse these unless the user explicitly asks and confirms the risk:

- Secrets and local configuration: `.env`, `.env.*`, `*.pem`, `*.key`, `credentials.*`, `.npmrc`, `.netrc`.
- Build output, dependency directories and editor state.
- Agent working state, such as `.agent-workflow/`, which is local and must stay uncommitted.

Then confirm that the staged content is real:

```bash
git diff --cached --stat
```

An empty result means nothing will be committed. This catches the `core.autocrlf=true` case, where a line-ending rewrite reports a path as modified in `git status` while `git diff` is empty. Treat such a path as unchanged, and never commit it alone.

## 5. Compose the message

Follow [conventional-commits.md](references/conventional-commits.md). The rules that matter most:

- **Type** — `feat` or `fix` for a feature or a defect; the repository's own list for anything else.
- **Scope** — from the vocabulary the repository already uses, or from the branch name when the repository has none. Omit it rather than invent one.
- **Description** — imperative mood, lower case, no trailing period, 72 characters at most and 50 where the meaning allows.
- **Body** — why the change was needed and what it replaces, separated from the description by a empty line. Omit it when the description says everything.
- **Footers** — `Token: value`, one per line, after a empty line. Use the repository's closing keyword when the commit resolves an issue.
- **Breaking change** — `!` before the colon, with or without a `BREAKING CHANGE:` footer. Add the footer when the migration needs explaining.
- **Trailers** — add what the repository requires, such as `Co-authored-by:`. Never attribute a change to a tool that did not author it.

Put the type on the user-visible outcome. A feature that also adds tests is `feat`, not `test`. When a change genuinely spans two types, prefer two commits, as the specification recommends.

## 6. Confirm once

Show every commit in order: the paths, the full message including footers, and anything excluded with the reason. Ask for confirmation once, and only when the grouping or the wording was inferred. Then commit without further questions.

## 7. Commit

Pass the message on standard input through a literal here-string, so no part of it is expanded.

PowerShell:

```powershell
@'
feat(parser): accept empty input

An empty file crashed the reader.
'@ | git commit -F -
```

Bash:

```bash
git commit -F - <<'EOF'
feat(parser): accept empty input

An empty file crashed the reader.
EOF
```

When a merge, cherry-pick or revert is in progress, the message already exists. Commit it unchanged:

```bash
git commit --no-edit
```

Do not write a new message there, and do not remove the conflict comments Git prepared.

## 8. Handle a failed hook

A failing hook means no commit was created. Report the hook output verbatim, then:

1. Re-read the status. A formatter hook has usually rewritten files.
2. Stage only the paths the hook rewrote, and only for the same commit.
3. Retry the same command once.

Never add `--no-verify`. When the hook fails for a reason the change cannot satisfy, stop and hand the decision to the user.

## 9. Verify and report

```bash
git log -1 --stat
git status --porcelain
```

Report each new commit by its short identity and description, what remains uncommitted, and any hook that modified files. Never claim a commit that `git log` does not show.

## Related operations

This skill commits only. Use the matching command for a related change, on explicit request:

- Publish the branch: `git push -u origin <branch>`
- Reword the last commit before it is pushed: `git commit --amend`
- Undo the last commit while keeping its changes: `git reset --soft HEAD~1`
- Inspect the history: `git log --oneline --graph --decorate`
