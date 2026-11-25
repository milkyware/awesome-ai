# Change identity

A review verdict binds to a change identity, not to a conversation or a summary. The
identity is the stored text of a small set of Git outputs, compared as text. It is
never hashed.

## Commands

Record the execution context in the task brief: the dispatch base and the path scope as a
boundary. Then capture four literal strings, one command per call:

```text
git rev-parse HEAD
git diff HEAD --stat
git diff HEAD --name-only
git ls-files -o --exclude-standard
```

None of them carries an argument. The first records the base. The second is the readable
record quoted in a verdict, the third is the machine comparison, and the fourth lists
untracked paths. Where an untracked file's content matters, pin that one path with
`git hash-object <path>`: the path is the subject of the command, not a label attached to
it. The vocabulary's other variables are the staged paths and the commit command's
objective root, and every one of them is fixed before the call runs.

`git diff HEAD` and not `git diff`, because it compares the working tree to the commit and
so still reports content after an accidental staging.

## Why the diff and not the status

Where `core.autocrlf` is enabled, a file rewritten with LF-only line endings reports
as modified in `git status` while `git diff` is empty. Git normalises for `diff`, so
the diff output answers the only question that matters: did the content change.

The reverse error is equally important. A clean `git status` is not proof that
nothing changed, because untracked files and staged changes resolve differently. Read
the outputs; do not infer from a summary line.

## Comparison

Execution is sequential on one shared tree: workers leave their changes uncommitted, the
orchestrator commits one reviewed task at a time, and `HEAD` therefore does not move
between dispatch and integration. Two consequences follow. The base is recorded but never
used as a diff argument. And the diff has no path scope, so a write outside the task
appears in the identity rather than being filtered out of it.

Recompute before integration and compare the text with the text the verdict quoted:

- equal text: the same change, so the verdict still applies;
- different text: a different change, so the verdict does not apply and the task
  returns to review.

## Read-only delegations

Take `git diff HEAD --name-only` before and after the delegation. A difference means
the read-only boundary was crossed: reject the result, restore the reviewed state if
needed, and record a decision. This detects a violation; it does not prevent one, so
pair it with a harness permission that denies writes where the harness supports it.

## Recipes to avoid

Do not build an identity with a stash, a tree object hash, a hash piped from standard
input, or any pipeline. They add no evidence beyond the diff, and a pipe is a compound
command: the harness checks each subcommand separately, so it prompts per subcommand
rather than once.
