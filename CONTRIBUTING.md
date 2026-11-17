# Contributing

Issues and pull requests are welcome. For a useful report, describe the
problem or proposed change, the expected outcome, and enough context to
reproduce or assess it. Identify the affected plugin, skill, or agent where
relevant.

For `agent-workflow` issues, include the agent involved, the objective, the
workflow step that misbehaved, and the expected and actual outcomes. Name the
active harness when the issue may depend on how agents are installed or run.

## Content contributions

- Use concise, neutral, fact-based language and UK English.
- Keep terminology consistent and avoid duplicating a canonical reference.
- Include examples when they make a workflow or expected output clearer.
- Keep APM manifests as the source for package distribution. Regenerate the
  marketplace catalog with APM rather than editing generated output by hand.

Before opening a pull request, review the changed files, check Markdown links
and formatting, and run the validation relevant to the change. Changes to APM
manifests, plugin structure, or the generated marketplace should pass the APM
checks described in [AGENTS.md](AGENTS.md). Include a concise summary and note
any checks that could not be run.
