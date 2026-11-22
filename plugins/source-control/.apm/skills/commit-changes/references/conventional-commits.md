# Conventional Commits

The message standard this plugin applies. Its authority is the [Conventional Commits 1.0.0 specification](https://www.conventionalcommits.org/en/v1.0.0/#specification), which is published under CC BY 3.0 and mandates only two types. The remaining types in the default table come from the Angular convention, which `@commitlint/config-conventional` also uses.

The repository's own configuration overrides this file. Read it first, as described in the skill.

## Format

```text
<type>[optional scope]: <description>

[optional body]

[optional footers]
```

- The type, an optional scope, an optional `!`, and the terminal colon and space are required before the description. The scope is a noun in parentheses, as in `fix(parser):`.
- Separate the description, the body and the footer block with one blank line each.
- The body is free-form and may hold any number of paragraphs.

## Type

- `feat` when the commit adds a new feature to an application or library.
- `fix` when the commit is a bug fix.
- Any other type the repository allows. The specification permits others; the default table below is the Angular set.
- Type and scope are treated as case-insensitive by implementations, so choose one casing and keep to it.

### Default types

Use these only when the repository declares no list of its own.

| Type | Use for |
| --- | --- |
| `feat` | New capability visible to a user or consumer |
| `fix` | Defect in existing behaviour |
| `docs` | Documentation only |
| `style` | Formatting with no behavioural change |
| `refactor` | Restructuring with no behavioural change |
| `perf` | Performance improvement |
| `test` | Test additions or corrections only |
| `build` | Build tool, packaging or dependencies |
| `ci` | Continuous integration configuration |
| `chore` | Maintenance with no source or test change |
| `revert` | Reverts an earlier commit |

When a change spans several types, prefer several commits. The specification's own guidance is to go back and split the work rather than stretch one type to cover two intentions.

## Scope

- A noun describing a section of the codebase, in parentheses, as in `fix(parser):`.
- Lower case, one word, no spaces.
- Use the vocabulary the repository already uses: a package, module, plugin or command name.
- Take it from the branch name when the repository has no vocabulary, as a branch named `fix/parser-timeout` suggests `fix(parser)`.
- Omit it rather than invent one.

## Description

The specification requires a short summary to follow the colon and space. These are conventions layered on top, not requirements of the specification:

- Imperative mood: `add`, `fix`, `remove`, not `added`, `fixes` or `removes`.
- Lower case after the colon, and no trailing period.
- Say what changes for the user or consumer, not which file was edited.
- 72 characters at most, and 50 where the meaning allows.

## Body

- Explain why the change was needed and what it replaces. The diff already shows what changed.
- Wrap at 72 characters.
- Omit it when the description is sufficient. An empty body is honest; a padded one is noise.

## Footers

- One footer per line, in a block after one blank line from the body or description.
- Each footer is a word token, then either `: ` or ` #`, then the value. Both `Closes: #123` and `Closes #123` are valid; Git treats only `Token: value` as a trailer, so prefer that form.
- A token uses `-` in place of whitespace, as in `Reviewed-by`. `BREAKING CHANGE` is the one exception and may carry a space.
- A value may contain spaces and newlines. Parsing continues until the next valid token and separator pair, so a multi-line explanation needs no continuation marker.

## Breaking changes

A break must be indicated in the prefix, in the footer, or in both. It may belong to a commit of any type.

```text
feat(api)!: remove the v1 token endpoint
```

```text
feat: allow a provided config object to extend other configs

BREAKING CHANGE: the `extends` key in the config file now extends other config files
```

- `!` goes immediately before the colon, after the type and any scope.
- A `BREAKING CHANGE:` footer must use upper case in the token, followed by a colon, a space and the description.
- `BREAKING-CHANGE:` is synonymous when used as a token.
- When `!` is used, the footer may be omitted, and the description then carries the explanation. Add the footer anyway when the migration needs more than one line.

## Reverts

The specification does not define revert behaviour and leaves it to tooling. The recommended shape is the `revert` type with a footer naming the reverted commits:

```text
revert: remove the experimental cache

Refs: 676104e, a215868
```

## Issue references

- Close an issue the commit resolves: `Closes: #123`.
- Reference one it does not: `Refs: #123`.
- Use the repository's own keyword when it defines one.

## Trailers

Add the trailers the repository requires, one per line in the footer block, for example `Co-authored-by: Name <email>`. Never attribute a change to a tool that did not author it.

## Examples

```text
feat(parser): accept empty input

An empty file crashed the reader. The parser now returns an empty
document instead of raising.

Closes: #412
```

```text
fix(auth): stop the refresh loop on an expired session

A request that expired mid-flight triggered a refresh, which failed
validation and triggered another refresh. A guard now aborts the second
attempt and returns 401.
```

```text
refactor(agent-workflow)!: replace the fingerprint with content identity

BREAKING CHANGE: recorded fingerprints no longer resolve. Recreate them
with the identity command set.
```

## What to avoid

- `update files`, `fix bug`, `changes`, `wip` — a description that could describe any change describes none.
- `fixed the thing that was broken` — past tense, vague and conversational.
- A description that lists files: `update skill.md and readme.md`.
- A body that repeats the description.
- A scope invented for one commit.
- Emoji, ticket prefixes and bracketed tags unless the repository requires them.
