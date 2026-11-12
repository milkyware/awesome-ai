---
name: create-pull-request
description: Create GitHub pull requests for an already-committed branch using the GitHub CLI. Use when asked to open, raise or submit a pull request, or to turn completed branch work into a reviewable PR with a Conventional Commits title and a body built from the repository's own pull request template.
---

# Create Pull Request

Open a pull request that a reviewer can assess without the original conversation. Write in UK English; be precise, concise and engineering-focused.

## Prerequisites and boundaries

- Prefer the authenticated GitHub CLI. Confirm availability and authorisation with `gh auth status`, and resolve the target repository before writing. If the session provides GitHub MCP tools with equivalent capability, they are an acceptable substitute; discover their actual signatures rather than assuming tool names.
- If GitHub access is unavailable or lacks write permission, do not pretend to create a pull request. Explain the limitation and provide the complete title, body and the exact `gh pr create` command the user can run.
- Apply this skill to **new pull requests** only. Editing, reopening, reviewing, merging and closing an existing pull request are separate operations.
- The branch is input, not output. Never commit, amend, rebase, force-push, merge, approve, or change branch protection as part of creating a pull request.
- Never run a test suite, linter or build as a side effect. Report what the user states they verified instead.
- Never state a test result, pipeline status or review approval that was not observed. Never claim a pull request was created until the operation returns a number or URL.
- Keep one logical change per pull request. Report unrelated commits rather than absorbing them silently.

## 1. Establish the target

Use details already stated in the request and conversation. Resolve, in order:

1. **Repository**: accept `owner/repo`, a URL or an unambiguous name. Otherwise infer from the current Git remote (`git remote -v`, `gh repo view --json nameWithOwner`). Ask when the choice is ambiguous, such as a fork with an upstream, several remotes, or a workspace containing multiple repositories. Never hardcode a repository.
2. **Head branch**: the current branch, confirmed with `git rev-parse --abbrev-ref HEAD`. Stop if the result is `HEAD`, which means a detached checkout; a pull request needs a branch.
3. **Base branch**: the user's explicit choice, otherwise the repository default from `gh repo view --json defaultBranchRef --jq .defaultBranchRef.name`. Treat any non-default base as a deliberate choice and state it; stacked pull requests depend on it.
4. **Ready or draft**: create the pull request as **ready for review** by default. Add `--draft` only when the user asks for a draft or states the work is incomplete. Never infer draft from an unfinished checklist.
5. **Assignees, reviewers, labels, milestone and project**: apply only when the user requests them or the repository records an unambiguous convention. Do not duplicate CODEOWNERS requests or labeller automation.
6. **Screenshots**: follow [5. Compose the body](#5-compose-the-body).

If the head branch equals the base branch, stop and explain that the change needs its own branch or the exact branch name to use.

## 2. Verify the branch is ready

Run these before composing anything. They are read-only.

```bash
git status --porcelain
git rev-parse --abbrev-ref --symbolic-full-name '@{upstream}'
git rev-list --count '@{upstream}..HEAD'
git fetch origin <base>
git rev-list --left-right --count 'origin/<base>...HEAD'
git log --oneline 'origin/<base>..HEAD'
git diff --name-only 'origin/<base>...HEAD'
```

Then judge the result:

- **Uncommitted changes present.** Stop and ask whether to continue without them. Never commit them as part of opening a pull request.
- **No upstream, or the upstream is behind the head.** The branch is not pushed. Offer `git push -u origin <branch>` and wait for confirmation before pushing.
- **Zero commits ahead of the base.** There is nothing to review. Stop.
- **Behind the base.** Report the divergence. Do not rebase or merge the base automatically; that rewrites or extends the branch.
- **Mixed or unrelated commits.** Name them and ask whether to proceed, to narrow the base, or to split the work.
- **Merge commits or fixup commits.** Report them. The repository may require a linear history or a squash strategy.

Review every changed file. The review establishes the body content and the evidence needed for [tick criteria](references/pull-request-template.md#how-ive-tested-my-work). If the diff is too large to review in full, say so once and continue with what was reviewed; do not tick `Code inspection` in that case.

## 3. Search for an existing pull request

Search before creating:

```bash
gh pr list --head '<branch>' --state all --json number,url,title,state
```

If a pull request already exists for the branch, show it and stop. A closed pull request for the same branch is a decision for the user, not an invitation to reopen or duplicate one. When a previous attempt failed ambiguously, run this search before retrying.

## 4. Compose the title

Use Conventional Commits. Read the repository's own configuration first, then fall back to the default set:

1. A commitlint configuration (`.commitlintrc`, `commitlint.config.js`, `commitlint.config.mjs`).
2. A title or commit-message validator in `.github/workflows` that declares an explicit type list, such as `types:` on a semantic pull request action.
3. Contribution guidance in `CONTRIBUTING.md` or `AGENTS.md`.

Default types, when no configuration narrows them:

| Type       | Use for                                      |
| ---------- | -------------------------------------------- |
| `feat`     | New capability visible to a user or consumer |
| `fix`      | Defect in existing behaviour                 |
| `docs`     | Documentation only                           |
| `style`    | Formatting with no behavioural change        |
| `refactor` | Restructuring with no behavioural change     |
| `perf`     | Performance improvement                      |
| `test`     | Test additions or corrections only           |
| `build`    | Build tool, packaging or dependencies      |
| `ci`       | Continuous integration configuration         |
| `chore`    | Maintenance with no source or test change    |
| `revert`   | Reverts an earlier commit                    |

Format rules:

- `type(scope): description`, with the scope optional and lower case. Use the scope when the repository's history or configuration establishes a vocabulary; do not invent one.
- The description is imperative, lower case and has no trailing period. Start from what the change does, not from a filename.
- Mark a breaking change with `!` before the colon, as in `feat(api)!: drop v1 token endpoint`, and explain the break in the body.
- Keep the title within 72 characters where the description allows.
- No ticket identifiers, version numbers or bracketed tags unless the repository requires them.
- When the change spans several types, choose the type of the user-visible outcome. A feature that also adds tests is `feat`.

The title is the squash-merge commit message in most repositories, so it is the permanent record of the change.

## 5. Compose the body

Locate the repository's template, in this order:

1. `.github/pull_request_template.md`, then case variants such as `PULL_REQUEST_TEMPLATE.md`.
2. `.github/PULL_REQUEST_TEMPLATE/` used as a directory. When it holds several templates, choose by change type or ask; never merge them.
3. `docs/pull_request_template.md`.
4. `pull_request_template.md` at the repository root.
5. No template. Render [pull-request-template.md](references/pull-request-template.md) instead.

Rules for the body:

- **The repository template is the structure.** Preserve its headings, order and checkbox wording exactly. Fill the sections; do not reorder, rename, merge or replace them. The reference file informs content only.
- **Delete authoring scaffolding.** Remove HTML comments and `[!IMPORTANT]` admonitions that instruct the author. Keep anything that is genuine PR content.
- **Describe behaviour, not the diff.** State what changes after merge and why. Never reproduce a file-by-file changelog that a reviewer can read.
- **Evidence, not assertion.** Record the commands run, their results and the platform. Never upgrade an observed result into a broader claim.
- **State risk and rollback** when the change touches data, authentication, migrations, infrastructure or a public interface.
- **Link the issue** with a closing keyword when the pull request resolves it, as in `Fixes #12`. Use `Refs #12` when it does not.
- **Never invent** file paths, endpoints, metrics, screenshots or log excerpts.
- **Remove empty sections** that carry no content, unless the template's own instructions require them to stay.
- **Format for GitHub**: fenced code blocks with a language hint, same-repository references as relative links, external references as absolute URLs.

Then handle screenshots, following [UI change detection](references/pull-request-template.md#ui-change-detection):

- **UI change detected and no images supplied.** Ask once. Recommend the specific images: before and after for each altered state, empty, loading and error states, narrow and wide viewports, and dark mode where supported. Offer two paths: supply the image paths now, or leave the section in place for the author to complete after creation.
- **UI change detected and images supplied.** Attach each with `--attach '<path>#<alt text>'`. Write the matching `![alt](./path)` reference in the body so the upload rewrites it in place.
- **No UI change and no images.** Remove the Screenshots section.
- **Images supplied without a UI change.** Keep the section and attach them; the user's judgement overrides detection.

Write the body to a temporary file outside the repository, in the same directory as any screenshots, because `--body-file` resolves relative paths against the file's own directory.

## 6. Confirm before writing

Show a compact preview:

- Repository, and `base ← head`.
- Title, and whether the pull request is ready or draft.
- The body as it will be written.
- Which checkboxes are ticked and why, and which are left for the author.
- Any attachments, omitted images or rejected metadata.
- Any divergence, unrelated commits or uncommitted changes the user chose to proceed with.

Ask for confirmation **once**, and only when material details were inferred or remain uncertain. A direct, sufficiently detailed request to open the pull request counts as authorisation.

## 7. Create the pull request

```bash
gh pr create \
  --repo <owner/repo> \
  --base <base> \
  --head <branch> \
  --title "<type>(<scope>): <description>" \
  --body-file <temporary-body-file>
```

- Add `--draft` only when the user asked for a draft.
- Add `--attach '<path>#<alt text>'` once per image, and `--label`, `--reviewer`, `--assignee`, `--milestone` or `--project` only when requested.
- Use `--head <owner>:<branch>` when the head branch lives in a fork.
- Never use `--fill`, `--fill-first` or `--fill-verbose`. They take the title and body from commits and discard the template and the review evidence.
- `--dry-run` prints the details without creating the pull request, but may still push Git changes. Use it only when the user asks for a preview in the terminal.
- When the command reports that a pull request already exists, report that URL. Do not retry with a different base or title.
- When some attachments fail, the pull request is still created and its URL is still printed, but the command exits non-zero. Report which uploads failed.
- Never change the ready or draft state of another pull request, and never push follow-up commits to resolve a creation error.
- Remove the temporary body file once the command finishes.

## 8. Report the result

On success, provide the **pull request number** and **clickable URL**, along with repository, base and head branches, title, ready or draft state, ticked checkboxes, attachments, and any omitted or rejected metadata. Report the check status only as observed at that moment, and do not poll for it.

On failure, explain the error and leave the user with the complete title, body and exact command. Do not fabricate a number or URL.

## Related operations

This skill creates pull requests only. Use the matching command when the user asks for a related change:

- Mark ready for review: `gh pr ready <number>`
- Open in the browser: `gh pr view <number> --web`
- Request a review: `gh pr edit <number> --add-reviewer <handle>`
- Observe check status: `gh pr checks <number>`
- Merge, only on explicit request: `gh pr merge <number> --squash --delete-branch`
