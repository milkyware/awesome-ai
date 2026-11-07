---
name: create-github-issue
description: Create GitHub issues from structured or free-form engineering requests using the GitHub CLI. Use when asked to open a GitHub issue, bug report, feature request, user story, spike, epic or task, or to turn requirements into a delivery-ready issue with type, size and priority labels and testable acceptance criteria.
---

# Create GitHub Issue

Create an issue that can be understood and delivered without the original conversation. Write in UK English; be precise, concise and engineering-focused.

## Prerequisites and boundaries

- Prefer the authenticated GitHub CLI. Confirm availability and authorisation with `gh auth status`, and resolve the target repository before writing. If the session provides GitHub MCP tools with equivalent capability, they are an acceptable substitute; discover their actual signatures rather than assuming tool names.
- If GitHub access is unavailable or lacks write permission, do not pretend to create an issue. Explain the limitation and provide the complete draft with the exact `gh issue create` command the user can run.
- Apply this skill to **new issues** only. Use separate edit, comment and close operations for existing issues.
- Never open a public issue that discloses an unpatched vulnerability, credential or personal data. Report the exposure and point the user to the repository's private vulnerability reporting channel instead.
- Never claim an issue was created until the GitHub operation returns an issue number or URL.

## 1. Establish the target

Use details already stated in the request and conversation. Resolve, in order:

1. **Repository**: accept `owner/repo`, a URL or an unambiguous name. Otherwise infer from the current Git remote (`git remote -v`, `gh repo view --json nameWithOwner`). Ask when the choice is ambiguous, such as a fork with an upstream, several remotes, or a workspace containing multiple repositories. Never hardcode a repository.
2. **Type of work**: honour an explicit choice. Otherwise infer from the request using [3. Classify the issue](#3-classify-the-issue). If the choice between two types changes the deliverable, ask.
3. **Parent**: ask up front whether the issue should be a sub-issue of an existing issue. Set a parent only when the user requests one or a repository convention establishes it.
4. **Assignee**: honour the user's instruction; otherwise leave the issue unassigned. Use `@me` only when asked to self-assign, and `@copilot` only when explicitly requested.
5. **Milestone and project**: apply only when requested or when an established repository convention makes the value unambiguous.
6. **Size and priority**: apply the labels described in [3. Classify the issue](#3-classify-the-issue); every issue carries one type, one size and one priority label unless it is an epic.
7. **Optional metadata**: further labels, dependencies and attachments: apply only what was requested or clearly implied.

If a default has been proposed but not approved, ask the user to confirm it before creation. Do not repeatedly reconfirm defaults the user has already accepted. Ask for missing essentials together when a structured question tool is available; otherwise use a concise conversational question.

## 2. Search for an existing issue

Search before creating. Use key terms from the request and check both open and closed issues:

```bash
gh issue list --repo <owner/repo> --state all --search "<key terms>" --limit 20
```

If a plausible match exists, show it and ask whether to comment on it or create a separate issue. Do not create a near-duplicate silently. When a previous creation timed out or failed ambiguously, search for the exact title before retrying.

## 3. Classify the issue

Apply exactly one label from each family. Each value is a single lowercase token after the family prefix, so filters such as `--label "type:story"` work unchanged.

**Type** describes the unit of work, not its domain:

| Label          | Meaning                                                              |
| -------------- | -------------------------------------------------------------------- |
| `type:epic`    | Body of work that must be split into sub-issues before delivery      |
| `type:feature` | Capability delivered across several stories                          |
| `type:story`   | User story: one deliverable slice of user value                      |
| `type:task`    | Engineering work with no direct user-facing outcome                  |
| `type:bug`     | Defect in existing behaviour                                         |
| `type:spike`   | Time-boxed investigation; the output is a decision, not working code |

**Priority** records urgency and impact; it does not describe effort or sequence:

| Label         | Meaning                                                                  |
| ------------- | ------------------------------------------------------------------------ |
| `priority:p0` | Outage, data loss or unpatched security exposure; act immediately        |
| `priority:p1` | Blocks current delivery or affects many users; address before other work |
| `priority:p2` | Planned work for the current cycle                                       |
| `priority:p3` | Worth doing, not time-critical                                           |
| `priority:p4` | Parked or speculative; no commitment to deliver                          |

**Size** records delivery effort relative to one issue:

| Label     | Meaning                                                                  |
| --------- | ------------------------------------------------------------------------ |
| `size:xs` | Isolated change within one function or file; no design work              |
| `size:s`  | Contained change in one component using an existing pattern              |
| `size:m`  | Change spanning a few components or introducing a pattern, with tests    |
| `size:l`  | Cross-cutting change, migration or new integration; confirm scope first  |
| `size:xl` | Larger than one issue can deliver; split into sub-issues before delivery |

Rules that keep the labels trustworthy:

- **Never two types, never none.** Choose the single best fit, and ask only when the choice changes the deliverable.
- **An epic takes no size label.** A container cannot be sized. Priority still applies.
- **`size:xl` and `type:epic` are different diagnoses.** `size:xl` means the issue is too large and must be split; `type:epic` means it is deliberately a container. A story that turns out to be `xl` becomes an epic plus sub-issues.
- **`type:feature` versus `type:story`:** a feature spans several stories; a story is independently releasable. If the work is both, prefer `type:story` and let the parent carry the feature.
- **Type is not a domain.** Do not use `type:docs`, `type:refactor` or `type:ci`; domain labels belong in a separate family that this skill does not manage.
- **Repository convention wins.** If the repository documents its own type, size or priority scheme, or tracks these values as GitHub Projects fields, apply that scheme and mirror the same values into the project fields. State the convention you followed.
- **Organisation issue types are additive.** When the organisation enables issue types, set the native type that corresponds to the chosen label and never let the two disagree. Always apply the label as well, because it works on every repository, including personal ones.
- **Infer with evidence.** When the evidence is thin, choose the lower-risk value and state the assumption instead of opening a separate question.
- **Never encode these values in the title**, such as a `[P1]` or `[BUG]` prefix; the labels are the record.
- **Labels must exist before the issue is created**, because GitHub rejects an issue that references an unknown label. Reconcile the label set first and create only the missing labels. See [github-labels.md](references/github-labels.md) for canonical names, colours, descriptions and creation commands.

## 4. Author the issue

- Write a specific title that can be understood in a list without surrounding context: action-led for changes, behaviour-led for defects, no trailing period and no type prefix already conveyed by the label or issue type.
- Use the structure in [github-issue-template.md](references/github-issue-template.md), which defines the standard sections and the per-type adaptations for Bug, Story, Feature, Task, Spike, Epic and sub-issue.
- Prefer `should` for requirements. Write acceptance criteria as `- [ ]` checkboxes, each independently verifiable and separate from implementation notes. A spike states its decision criteria and expected outputs instead; an epic states outcomes and boundaries.
- Do not invent file paths, endpoint names, log messages, retries or other specifics. Retain links and engineering details supplied by the user.
- If the repository defines issue forms or templates under `.github/ISSUE_TEMPLATE`, follow their required fields and structure rather than bypassing required context.
- Omit empty sections unless the missing content must be clarified for delivery. Distinguish facts, proposed approaches and open questions.
- Format for GitHub: fenced code blocks with a language hint, same-repository references as relative links (`../README.md`, `#L20-L30` anchors), and external references as absolute URLs.

## 5. Confirm before writing

- Show a short preview of the repository, title, type, size, priority, parent and the acceptance criteria when material details were inferred or remain uncertain.
- Ask for confirmation **once** before the write if the user has not already authorised creation with the final details. A direct, sufficiently detailed request to create the issue counts as authorisation; avoid an unnecessary extra approval loop.
- Do not create a duplicate after a timeout or ambiguous failure without checking whether the previous request succeeded.

## 6. Create the issue

Write the body to a temporary file outside the repository and pass it with `--body-file`. This preserves Markdown exactly and avoids shell quoting problems on every platform.

```bash
gh issue create \
  --repo <owner/repo> \
  --title "<title>" \
  --body-file <temporary-file> \
  --label "type:story" \
  --label "size:m" \
  --label "priority:p2"
```

- Add only the flags that apply: `--type <name>`, `--parent <number>`, `--assignee <login>`, `--milestone <name>`, `--project <title>`, `--blocked-by <numbers>`, `--blocking <numbers>` and `--attach <file>`.
- Omit `--label` for the size when the issue is an epic.
- Never close, lock or otherwise change issue state as part of creation.
- On a validation error, correct the specific field. Never guess a label, issue type, milestone or project name; resolve it with `gh label list`, `gh issue list` or `gh project list` first.
- If `gh` prints recovery instructions after a failed interactive run, use `gh issue create --recover <token>` instead of starting again.
- If some `--attach` uploads fail, the issue is still created and its URL is printed; report which attachments were omitted.
- Remove the temporary body file once the command finishes.

## 7. Report the result

On success, provide the **issue number** and **clickable URL**, along with repository, title, type, size, priority, parent, milestone, project and any omitted or rejected metadata. Construct the URL only from a verified repository and the returned number.

On failure, explain the error and leave the user with the complete draft and the exact command. Do not fabricate an issue number or URL.

## Related operations

This skill creates issues only. Use the matching command when the user asks for a related change:

- Create a working branch: `gh issue develop <number> --checkout`
- Add existing issues as sub-issues: `gh issue edit <parent> --add-sub-issue <numbers>`
- Record a dependency: `gh issue edit <number> --add-blocked-by <numbers>`
- Mark a duplicate: `gh issue close <number> --duplicate-of <other> --reason duplicate`
- Link delivery work: reference the issue from the pull request body with a closing keyword such as `Fixes #<number>`
