# Pull Request Template Reference

Use this file in two ways:

1. **Fallback structure.** When the target repository has no pull request template, render the body from [The template](#the-template).
2. **Content guidance.** When the repository has its own template, preserve that structure exactly and use the section guidance below only to decide what each section should contain.

## The template

Reproduce this structure verbatim, then fill it. Strip the `[!IMPORTANT]` admonition and every HTML comment before creating the pull request; they are authoring scaffolding, not PR content.

```markdown
> [!IMPORTANT]
>
> Ensure that all checkboxes are in the following format with no extra spaces: `[X]`, `[x]` or `[ ]`. Checkboxes can also be [toggled through the PR UI](https://docs.github.com/en/get-started/writing-on-github/working-with-advanced-formatting/about-tasklists) once it's been created.

## Changes

<!-- Describe what behaviour is changed by this PR. -->

### Screenshots

<!-- Delete this section if the change does not affect the UI. -->

## Documentation

- [ ] I have updated the documentation
- [ ] No documentation update is required

## How I've tested my work

I have verified these changes via:

- [ ] Code inspection
- [ ] Manual testing
- [ ] Newly added/modified unit tests
```

## Section guidance

### Changes

Describe the behaviour that changes and the reason for it. Write in the present tense, as the state after merge. State what a reviewer must understand to judge the change, not a file-by-file account of the diff.

Cover these points when they are material:

- The problem or request that motivated the change.
- The chosen approach, and the alternative rejected if the choice is not obvious.
- Any user-visible, behavioural, data, configuration or contract change.
- Risk and rollback for changes touching data, authentication, migrations, infrastructure or public interfaces.

Omit the content only when the change is self-evident from the title; never leave the heading with no content.

### Screenshots

Present for UI changes and remove otherwise. Order images as before, then after, and label each state. See [Screenshot recommendations](#screenshot-recommendations).

### Documentation

Mutually exclusive. Tick exactly one:

- **I have updated the documentation** when the diff changes documentation files.
- **No documentation update is required** otherwise.

Tick both or neither only when the repository's own wording makes the pair non-exclusive.

### How I've tested my work

Tick only what the diff or the user's account evidences:

| Option                            | Ticked when                                                                                       |
| --------------------------------- | ------------------------------------------------------------------------------------------------- |
| `Code inspection`                 | Every changed file was reviewed; leave unticked when the diff was truncated or partially reviewed |
| `Manual testing`                  | The user states they performed it; never inferred from the diff                                   |
| `Newly added/modified unit tests` | The diff adds or modifies test files; this attests to their existence, not to a passing run       |

State separately, in the report, anything run and observed: commands, results and platform. A ticked box is not a substitute for that evidence, and a test file's presence is not a passing test suite.

## UI change detection

Treat a change as UI-affecting when the diff touches any of these:

- Markup, style or component files: `*.tsx`, `*.jsx`, `*.vue`, `*.svelte`, `*.html`, `*.razor`, `*.cshtml`, `*.css`, `*.scss`, `*.sass`, `*.less`
- Component, page, view, screen or layout directories: `**/components/**`, `**/pages/**`, `**/views/**`, `**/screens/**`, `**/layouts/**`
- Static assets and design tokens: `**/public/**`, `**/static/**`, `**/assets/**`, image, icon and font files
- Server-rendered templates that carry user-facing text

Widen the match when the repository documents what its UI layer is. Narrow it when matched files are clearly non-visual, such as a stylesheet consumed only in email templates.

## Screenshot recommendations

Recommend the evidence that shows the change works, not the largest number of images. Name the specific images to capture:

- **Before and after** for each altered state, in that order, with the state named in the alt text.
- **Empty, loading and error states** when the change affects data fetching, validation or permissions.
- **Narrow and wide viewports** when layout or responsive behaviour changes.
- **Dark mode** alongside light mode when the project supports both.
- **The changed control** rather than a full-page shot when the change is local to one element.

When images are supplied, attach them and describe each in the alt text. When they are not, leave the section in place with a short instruction for the author and report the omission.

## Test file patterns

A file is a test file when its path matches any of these:

- `**/*.test.*`, `**/*.spec.*`, `**/*.Test.*`, `**/*.Tests.*`
- `**/test/**`, `**/tests/**`, `**/__tests__/**`, `**/spec/**`
- `**/*_test.go`, `**/test_*.py`, `**/*Tests.cs`, `**/*Test.java`, `**/*_spec.rb`

## Body formatting

- Fenced code blocks carry a language hint.
- Same-repository references are relative links; anchors such as `#L20-L30` are appended to the path.
- External references are absolute URLs.
- Issue links use a closing keyword when the pull request resolves the issue: `Fixes #12`, `Closes #12`, `Resolves #12`. Use `Refs #12` when it does not.
