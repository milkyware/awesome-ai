# Composite Action or Reusable Workflow?

Decide the output type before converting. Ask the user these questions, then
apply the rules below.

## Questions to Ask

1. Does the template orchestrate multiple jobs or stages with dependencies
   between them?
2. Does it need to run on its own trigger, or is it always called from a parent
   pipeline?
3. Does it produce anything other than a sequence of steps (for example
   environment gates, approvals, or job-level parallelism)?

## Rules

Choose a **composite action** when:

- The template is focused on a specific task or a set of related tasks.
- It is a sequence of steps with no job orchestration.
- It is always invoked from within a job, not as a top-level pipeline.
- The caller needs the steps to run in its own job context.

Choose a **reusable workflow** (`workflow_call`) when:

- The template orchestrates multiple jobs or stages.
- It needs environment gates, approvals, or job-level parallelism.
- It is a higher-level workflow that other workflows call with
  `jobs.<id>.uses`.
- Inputs and secrets are passed at the workflow level rather than the step level.

When both are plausible, prefer the composite action. It is simpler to compose
and easier to consume. Escalate to a reusable workflow only when job
orchestration is required.

## Mixed Case

When a reusable workflow contains long or repeated step sequences, offer to
extract those sequences into a composite action and call that action from the
workflow. This keeps the workflow focused on orchestration and the action focused
on implementation.
