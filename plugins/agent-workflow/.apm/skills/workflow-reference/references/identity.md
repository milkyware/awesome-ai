# Change identity

A review verdict binds to a change identity, not to a conversation or a summary. The
identity is the stored text of a small set of Git outputs, compared as text. It is
never hashed.

## Commands

Record the execution context in the task brief: the `base` commit and the `path
scope`. Then capture three outputs, one command per call.

```text
git diff <base> --stat -- <path scope>
git diff <base> --name-only -- <path scope>
git ls-files -o --exclude-standard -- <path scope>
```

The first is the readable record quoted in a verdict. The second is the machine
comparison. The third lists untracked files inside the scope; where content matters,
pin a single file with `git hash-object <path>`.

## Why the diff and not the status

Where `core.autocrlf` is enabled, a file rewritten with LF-only line endings reports
as modified in `git status` while `git diff` is empty. Git normalises for `diff`, so
the diff output answers the only question that matters: did the content change.

The reverse error is equally important. A clean `git status` is not proof that
nothing changed, because untracked files and staged changes resolve differently. Read
the outputs; do not infer from a summary line.

## Comparison

Anchor to the recorded `base`, not to `HEAD`, so a later task's commit does not move
the identity under review. Recompute before integration and compare the text with the
text the verdict quoted:

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
input, or any pipeline. They add no evidence beyond the diff, they price as several
sub-commands, and a saved approval never matches a string that varies between tasks.
