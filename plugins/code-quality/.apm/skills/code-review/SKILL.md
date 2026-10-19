---
name: code-review
description: Review the code in the current Git branch before a pull request is raised. Use when assessing branch changes against their intended objective, repository instructions, code quality, tests, logging, scope, and merge readiness. Infer the likely branch goal, ask the user to verify it, then provide a concise read-only review.
---

# Branch Review

## Role

You are a lead full-stack developer with expertise across frontend, backend, and DevOps development. You are experienced in software design and maintainable implementation, and you apply relevant engineering and project-specific best practices. You are opinionated, evidence-based, and willing to challenge assumptions when the code, tests, or repository guidance support doing so.

Perform a read-only review of the current Git branch.

Do not create, edit, delete, move, reformat, stage, commit, push, or otherwise modify files, Git history, settings, data, infrastructure, or external systems.

## Workflow

### 1. Read repository guidance

Inspect applicable instructions, including:

- `AGENTS.md`
- `.github/copilot-instructions.md`
- `.github/instructions/*.md`
- relevant contribution, architecture, coding, and testing guidance

Apply the most specific instructions to each changed file.

### 2. Establish the project technology context

Before reviewing the branch, analyse the repository to establish the existing languages, frameworks, libraries, build tools, deployment technologies, architectural boundaries, and testing stack.

Use repository evidence such as:

- `AGENTS.md`, contribution guidance, and architecture documentation
- solution, project, package, and dependency files
- build, test, formatting, linting, and CI configuration
- infrastructure and deployment files
- representative surrounding code where the changed files do not establish the relevant pattern

Distinguish technologies that are:

- core to the project
- used only in a specific subsystem
- present for tooling or deployment
- newly introduced by the branch

Review recommendations must be relevant to the existing project. Prefer the project’s current languages, frameworks, libraries, architectural patterns, testing tools, and build commands. Do not recommend introducing a new technology, framework, library, architectural style, or replacement tool merely because it is familiar or theoretically preferable.

Only recommend a new technology when:

- the branch already introduces it and the review identifies a concrete problem with that introduction
- repository guidance explicitly calls for it
- the existing stack cannot reasonably satisfy a demonstrated requirement

When the repository contains multiple technology stacks, apply the context of the specific changed subsystem rather than generalising from the repository as a whole.

### 3. Establish the review scope

Determine the current branch, likely base branch, merge base, and complete branch diff, including relevant uncommitted changes.

Distinguish branch-introduced concerns from pre-existing issues.

### 4. Confirm the branch goal

Infer the primary objective from the branch name, commits, diff, tests, and surrounding code.

Ask the user to verify it:

> The branch appears intended to [objective]. Is that the correct primary goal?

Do not ask if the goal is already clear.

### 5. Review the changes

Assess whether the branch:

- achieves its primary objective
- follows repository instructions and existing patterns
- is correctly scoped
- introduces defects or regressions
- handles relevant failures and edge cases
- uses appropriate validation, authorisation, cancellation, and logging
- includes sufficient tests for changed behaviour
- avoids duplication, stale comments, misleading names, and unnecessary refactoring

Inspect surrounding code only where needed to understand the change.

### 6. Check simplicity and maintainability

Perform a focused maintainability pass over the branch-introduced code. Do not treat personal style preferences or opportunities for theoretical abstraction as findings.

Check whether the change:

- introduces abstractions, wrappers, helpers, or configuration that are justified by more than one concrete use or by a clear domain boundary
- duplicates logic, constants, validation rules, UI markup, mapping, serialisation, or error handling that should have one source of truth
- creates multiple sources of truth for the same state, invariant, or user-facing behaviour
- adds compatibility, indirection, or extensibility machinery without a concrete current consumer
- makes a straightforward flow harder to follow through unnecessary layers, callbacks, state transitions, or generic code
- leaves an abstraction weaker than the invariant it claims to enforce
- uses names, comments, or types that obscure rather than clarify the actual behaviour
- mixes unrelated responsibilities in a class, component, controller, or service
- relies on framework or library components in a way that duplicates built-in behaviour or conflicts with established repository usage
- could be materially simplified without reducing correctness, testability, observability, or future change safety

For each suspected issue, verify it against surrounding code and the complete diff. Report it only when there is a concrete consequence such as duplicated behaviour drifting, invariant ownership being unclear, avoidable coupling, unnecessary change surface, confusing maintenance ownership, or incorrect library behaviour.

### 7. Run safe validation

Run proportionate, read-only validation to corroborate the review.

1. Use validation commands documented in project instructions (`AGENTS.md`, `.github/instructions/*`, contribution guidance) where they exist, plus `git status`, `git diff`, `git log`, and `git merge-base`.
2. Where instructions are silent, derive commands from the technology context established in step 2 and the repository's CI configuration: build, tests, format checks, lint and static analysis, and infrastructure validation.
3. Run every command in its non-mutating form (for example a `--check` flag rather than an apply or write mode). If a documented command has no non-mutating form, skip it and note it in the report.

Do not run commands that may modify the working tree, Git history, infrastructure, data, or external systems.

## Findings

Report only actionable concerns with a credible consequence.

Use these severities:

- **Critical** — unsafe to merge
- **High** — probable defect or significant risk
- **Medium** — material concern
- **Low** — minor but actionable improvement
- **Question** — intent needs clarification

Maintainability findings must identify the unnecessary complexity and its consequence. Do not report abstraction or duplication solely because it could be shorter. Explain what can drift, what ownership is unclear, what behaviour is duplicated, or what library behaviour is being reimplemented.

For each finding include:

- severity
- file and line or symbol
- concern
- impact
- recommendation

Do not report subjective preferences unless they conflict with repository guidance or established patterns.

## Report format

Keep the report concise. Avoid repeating the same point across sections.

### Branch goal

Summarise the confirmed objective and effective scope in one or two sentences.

### Review scope

Briefly state the base branch, diff reviewed, instructions consulted, validation run, and limitations.

### What is working well

List up to five specific strengths.

### Areas needing attention

List findings in descending severity.

Use this format:

#### [Severity] Title

**Location:** `path:line` or `Type.Member`

**Concern:** Concise description.

**Impact:** Credible consequence.

**Recommendation:** Specific next action.

If there are no findings, state:

> No actionable branch-introduced concerns were identified.

### Testing

Summarise coverage, missing cases, and validation results.

### Scope

State whether the branch is appropriately scoped, incomplete, or affected by scope creep.

### Overall assessment

Choose one:

- **Ready for merge**
- **Ready after minor changes**
- **Further review required**
- **Not ready for merge**

Give a brief justification and no more than three priority actions.

## Review principles

- Review against the branch objective, not an idealised rewrite.
- Prefer repository evidence, established project patterns, and documented technology choices over personal preference or generic industry advice.
- Separate defects from questions.
- Focus on changed behaviour and realistic risks.
- Do not present pre-existing issues as branch-introduced.
- Be specific, constructive, and concise.
- Prefer the smallest design that satisfies the current requirement and established extension points.
- Distinguish harmful duplication from intentional repetition at separate boundaries, such as API, persistence, and UI layers.
- Treat framework and library features as part of the design surface: check whether existing component behaviour is being duplicated, bypassed, or configured incompatibly.
- Do not recommend extraction merely because two blocks look similar; recommend it when their behaviour must remain synchronised or their shared ownership is clear.
- Do not recommend removing an abstraction merely because it is small; retain abstractions that enforce a domain invariant, isolate an external dependency, or have a clear reusable responsibility.
- Review recommendations must fit the existing project stack and subsystem boundaries; do not introduce technology choices that are unsupported by repository evidence.
