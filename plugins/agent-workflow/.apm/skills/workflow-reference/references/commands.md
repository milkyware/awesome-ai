# Shell vocabulary

Every shell call an agent makes is one of the literal strings below, or a string a task
brief names under `Expected verification` or `Formatting`. A string is copied whole.
Composing commands, adding an argument, or substituting a value changes the call, so it is a
new command with no recorded approval. When the work needs a string that is not here, stop
and report `blocked` with the missing command.

The agent definitions are normative. This page is the long form: what each string proves,
which agent may run it, and why the strings carry no placeholders.

## Rule

One command per call. No `|`, `&&`, `;`, `$()`, redirect, heredoc, wrapper or alias.

The harness scans a command into its subcommands and checks each one. A compound command is
therefore a chain of prompts, not one command, and one subcommand outside the approved set
asks for the whole call. A saved approval is a prefix pattern, such as
`shell: git status * → allow`, so it covers later variants of the same command; it does not
cover a different command.

## Vocabulary

| Purpose                         | Literal string                                                      | Agents                                        |
| ------------------------------- | ------------------------------------------------------------------- | --------------------------------------------- |
| Dispatch base and ledger        | `git rev-parse HEAD`                                                | architect, orchestrator, reviewer             |
| Precondition: the tree is clean | `git status --porcelain`                                            | all                                           |
| Identity: readable record       | `git diff HEAD --stat`                                              | all                                           |
| Identity: machine comparison    | `git diff HEAD --name-only`                                         | all                                           |
| Identity: untracked paths       | `git ls-files -o --exclude-standard`                                | all                                           |
| Untracked content, one path     | `git hash-object <path>`                                            | architect, orchestrator, reviewer             |
| History window                  | `git log --oneline -n 10`                                           | architect, orchestrator, reviewer, researcher |
| Integrated commit, stat         | `git show --stat HEAD`                                              | architect, orchestrator, reviewer             |
| Integrated commit, patch        | `git show HEAD`                                                     | orchestrator, reviewer                        |
| Stage the reviewed paths        | `git add -- <paths>`                                                | orchestrator                                  |
| Commit the reviewed change      | `git commit -F .agent-workflow/<objective-root>/commit-message.txt` | orchestrator                                  |
| Undo your own unpushed commit   | `git revert --no-edit HEAD`                                         | orchestrator                                  |

Three entries carry an argument, and in each it is the subject of the command rather than a
label attached to it. `git hash-object <path>` pins the content of an untracked file, which
has no diff to read; run it only for a path returned by `git ls-files -o --exclude-standard`.
`git add -- <paths>` names the reviewed paths, which the brief has already fixed.
`git commit -F .agent-workflow/<objective-root>/commit-message.txt` names the objective
directory, which the dispatch has already fixed.

`git status --porcelain` is a precondition, never evidence: where `core.autocrlf` is
enabled, it reports a line-ending-only rewrite as a modification.

## Identity

```text
git rev-parse HEAD
git diff HEAD --stat
git diff HEAD --name-only
git ls-files -o --exclude-standard
```

The first records the dispatch base as text. The other three read the working tree against
that commit. Use `git diff HEAD` and not `git diff`, so an accidental staging still shows.

Execution is sequential on one shared tree: workers leave their changes uncommitted, the
orchestrator commits one reviewed task at a time, and `HEAD` therefore does not move between
dispatch and integration. Two consequences are deliberate. The base is recorded but never
used as a diff argument. And the diff has no path scope, so a write outside the task's scope
appears in the identity instead of being filtered out of it: a boundary breach becomes
visible evidence.

An untracked file is listed by path and pinned by content hash. Take the hash whenever a
verdict depends on an untracked file: a rewrite that keeps the path and changes the content
is then a different identity rather than the same listing.

## Integration

Write the commit message with `write` to `.agent-workflow/<objective-root>/commit-message.txt`,
then run two commands, one per call:

```text
git add -- <paths>
git commit -F .agent-workflow/<objective-root>/commit-message.txt
```

The message file is ignored with the rest of the workflow root and is never staged. No
message string reaches the shell, so quoting and line endings cannot break the commit. One
commit per task.

The objective root is the one variable in the vocabulary. The consumer grant
`git commit -F *` already covers it, because `*` spans `/`, so one grant still covers
every objective directory.

The message header follows the repository's commit convention, recorded in the execution
plan. When the plan records none, use Conventional Commits: a `type(scope): subject`
header naming the change, a body stating what and why, and `Objective`, `Task`, and
`Requirements` footers carrying the traceability. A contract break adds `!` and a
`BREAKING CHANGE:` footer. The T0 formatting fix-forward is `chore`.

## Recipes to avoid

- `git stash create` piped into `git rev-parse <commit>^{tree}`: the stash is a pipe, and a
  tree hash proves nothing that the diff text does not.
- `git hash-object --stdin`: reads from a pipe, and the pipe is the compound command.
- `git add -A` and `git add .`: stage changes the task did not review.
- `git commit -m "<message>"`: embeds a value that differs per task and needs quoting on
  every shell.
- `git status` as identity: a hint for reading, not evidence.
