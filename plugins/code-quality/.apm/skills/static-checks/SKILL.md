---
name: static-checks
description: Run the project's formatters, linters and static validators against the working tree. Use when proving formatting conformance, reporting or triaging lint findings, applying automatic fixes, checking spelling, auditing GitHub Actions security, validating an APM marketplace, or producing the exact canonical check or fix command a task brief needs. Selects read-only or write commands from a per-tool catalogue and requires every write to be proved by a read-only re-run.
---

# Static Checks

## Role

You run the project's formatters, linters and static validators and report the
result as evidence. You use the canonical commands in `references/catalogue.md`,
never a derived or composed variant. You treat a write action as a correction,
never as proof.

## Workflow

### 1. Read repository guidance

Inspect applicable instructions, including:

- `AGENTS.md`
- `.github/copilot-instructions.md`
- `.github/instructions/*.md`
- CI workflow configuration that invokes formatters or linters

Where project guidance names a formatter or linter command, that command takes
precedence over the catalogue. Record the exact string; do not paraphrase it.

### 2. Detect the tool

Match the project against the `Detect by` column of `references/catalogue.md`.
Prefer configuration files; fall back to dependency presence when no
configuration file exists.

If no formatter or linter is detected, report that there is none. Do not
install, infer, or invent one.

### 3. Validate with the read-only command

Run the catalogue's `Read-only` command for the detected tool. Copy the string
whole, as one command per call, with no `|`, `&&`, `;`, `$()`, redirect, or
other composition.

Capture the result in the terms the catalogue records as that tool's failure
signal. Some tools exit non-zero and list nonconforming paths; others exit zero
and list them. Proof requires reading the signal the tool actually produces.

If the runner cannot fetch the tool (restricted network or registry outage),
retry once with `--offline`. If that also fails, report `blocked` and name the
tool. Never install tooling into the project to obtain a command.

### 4. Select the variant

- The objective is to prove conformance or report findings: stop after step 3.
  The read-only result is the evidence.
- The objective is to correct deviations or findings: run the `Write` command
  only after step 3 has established what is wrong, then run the `Read-only`
  command again. The second read-only run is the evidence; the write run never
  is.

### 5. Apply corrections by fix class

For a `safe` tool, the correction is mechanical: run the write command, then
re-run the read-only command and confirm it passes.

For a `classified` tool, restrict the fix scope to what the catalogue permits.
Do not enable unsafe fixes unless the project opts in explicitly and the
command naming them comes from the brief. Findings the tool cannot fix
automatically are code changes, not formatting; leave them for the task that
owns the code.

A write that reaches paths outside the task's write scope is scope drift, not
formatting. Report it with the affected paths and do not accept it silently.

### 6. Report

State, for each tool run:

- the exact command string executed
- the variant used: read-only or write
- the observed result, in the tool's own failure-signal terms
- whether the final read-only run passed

Format command strings so they can be copied verbatim into a task brief's
`Formatting` or `Expected verification` field, or into a report.

## Rules

- Use the catalogue's canonical command for the detected tool unless project
  guidance names a different one.
- One command per call. Never compose commands with `|`, `&&`, `;`, `$()`,
  redirects, or substitution.
- Never pin a tool version in a command; the project's own pins decide the
  version.
- Keep the tool and mode segment of every command fixed so saved approvals and
  permission rules match later invocations; vary only trailing paths.
- Never treat a write run as evidence.
- Never reformat files outside the task's write scope.
- Never install tools. Ephemeral runners only.
- Read-only commands are safe to repeat; run them again rather than reasoning
  about whether the tree is clean.

## Output

Use a compact block:

| Tool   | Variant   | Command | Result            |
| ------ | --------- | ------- | ----------------- |
| <tool> | read-only | <exact> | <signal observed> |

Then a one-line verdict: passing, findings remain with a count and their
categories, or `blocked` with the tool named.
