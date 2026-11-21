# Troubleshooting

## A specialist did not run

Delegation and agent selection depend on the active harness. If the harness
cannot invoke the requested specialist, the architect or orchestrator should
identify the handoff as manual rather than claim that delegation occurred. Run
the named specialist using the mechanism available in that harness, then return
its result to the dispatching agent.

## The orchestrator stops when started directly

The orchestrator owns execution of an approved slice but does not own design
approval or the user-facing channel. Start with the architect, which can obtain
approval and issue a slice to the orchestrator.

## `.agent-workflow/` was committed

The directory is local workflow state and should remain ignored. Stop using the
committed state, confirm that `.agent-workflow/` is in `.gitignore`, and inspect
the repository state before removing anything from the index. Preserve any
useful local records; do not discard them while tidying.

## A read-only specialist changed a file

Treat the change as a boundary violation. Stop and compare the affected files
with the recorded tree identity. Do not accept the result as read-only, and do
not restore files blindly because the working tree may contain user changes.
Escalate with the affected paths and evidence.

## The reviewed change no longer matches

A review verdict applies only to the identity it assessed. If the recorded diff
output changes before integration, return the task for review against the new
change. Do not integrate based on an earlier verdict or on a matching
`git status` alone.

## `git status` shows a change that `git diff` does not

With `core.autocrlf` enabled, a file rewritten with LF-only line endings reports
as modified while its content identity is unchanged. Do not normalise line
endings, add a `.gitattributes` rule, or disable `core.autocrlf` to quiet it.
Compare the recorded `git diff` output instead: equal text means the same change.

## A shell call asks for approval on every task

A compound command is priced by its sub-commands, so one outside the allowlist
asks for the whole call, and a saved approval only matches the exact string it
was granted for. Run the single command the brief names, without pipes, `&&`,
`;`, `$()` or redirects. If the brief does not name one, the brief is defective:
amend it rather than composing a command at the prompt.

## Verification is missing or fails

A completion claim without actual check results is not verified. Ask for the
missing evidence or return the task for revision. Classify failures before
retrying: a product failure needs a correction; an environment mismatch should
be escalated with its output; an incomplete brief should be corrected before
redispatch. Do not repeat an unchanged failure without evidence that the next
attempt can succeed.

## The requested capability is not available

The architect records capabilities observed in the repository and declared by
installed packages; it does not assume a tool, skill, or dependency is present.
If no available capability meets a requirement, the design must state whether
the orchestrator will handle it directly or whether the work needs a decision
from the user. Technology-specific packages can be installed alongside this
domain-neutral plugin when needed.

## How much process does a small change need?

Use the risk tier. A documentation-only change may be T0 and use a short brief;
a contained behaviour change is at least T1 and requires independent task
review. The architect classifies the work and explains the gates. See the
[risk tiers and approval gates](workflow.md#risk-tiers-and-gates).
