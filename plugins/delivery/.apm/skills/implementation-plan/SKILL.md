---
name: implementation-plan
description: Prepare a repository-grounded, implementation-ready plan for a coding agent from an already agreed design. Use when the user wants to convert settled planning or architecture decisions into a precise implementation handoff for a smaller model. The skill inspects applicable project instructions, relevant code and tests, then produces ordered implementation steps, behavioural requirements, test cases, validation commands, risks, and completion criteria without modifying the repository.
---

# Implementation Plan

Convert an agreed design into a self-contained implementation contract. Inspect and reason; do not modify the repository or external systems.

Do not reopen settled design decisions unless repository evidence shows that the agreed approach is unsafe, contradictory, or unimplementable. If that occurs, identify the conflict clearly rather than redesigning the solution.

## 1. Honour project instructions

Discover and follow all instructions applicable to the planned changes, including:

* `AGENTS.md`, including nested files whose scope covers affected paths;
* `.github/copilot-instructions.md`;
* `.github/instructions/*.md` and their path filters;
* equivalent repository-specific instruction files.

Resolve scope and precedence before preparing the plan. Apply relevant constraints directly to implementation steps.

## 2. Inspect repository context

Inspect only what is needed to make the handoff executable:

* affected projects, files, symbols, configuration, and dependency registrations;
* existing patterns and neighbouring implementations;
* tests, fixtures, mocks, and validation commands;
* dependency versions or external documentation where they affect implementation.

Prefer repository evidence over intuition. Distinguish verified facts from assumptions. Never invent file paths, symbols, signatures, or commands; provide a precise search target when exact details cannot be verified.

## 3. Produce the implementation contract

Use the following structure.

### Objective

State:

* current behaviour;
* required outcome;
* scope;
* constraints;
* non-goals.

### Agreed design

Summarise:

* the chosen approach;
* component responsibilities;
* data or control flow;
* decisions the implementation agent must preserve.

Do not re-evaluate alternatives unless needed to explain an implementation constraint.

### Repository context

Identify:

* applicable project instructions;
* relevant projects, files, and symbols;
* configuration and dependency registrations;
* tests, fixtures, and existing patterns.

### Implementation steps

Provide one canonical, ordered checklist of atomic changes.

For each step include, where relevant:

* file path or precise search target;
* symbol or code area;
* exact required change;
* expected signature or contract;
* dependency on earlier steps;
* required observable behaviour;
* associated tests;
* applicable scoped instructions.

Avoid vague directions such as “update the service”, “add validation”, “handle errors”, or “write tests”. State the triggering condition, required action, and expected result.

### Behavioural requirements

Define only the relevant:

* success behaviour;
* validation and failure behaviour;
* cancellation and timeout handling;
* concurrency and idempotency;
* logging and observability;
* security and authorisation;
* compatibility and migration behaviour;
* rollback or contingency measures.

### Test plan

For each required test specify:

* project and target file or fixture;
* scenario or proposed test name;
* setup and dependencies;
* action;
* observable assertions;
* mocks, fakes, or fixtures;
* edge and regression coverage.

Prefer observable behaviour over internal implementation details.

### Validation

Provide:

* exact targeted and broad validation commands where verified;
* expected successful results;
* manual or environment-specific checks.

### Risks and safeguards

List:

* likely implementation mistakes;
* assumptions that must hold;
* compatibility or migration hazards;
* safeguards the implementation agent must preserve.

### Completion criteria

Provide objective, independently verifiable conditions for completion.

## 4. Quality gate

Before returning the plan, verify that:

* applicable repository instructions are honoured;
* the agreed design has been preserved;
* the checklist is complete, internally consistent, and correctly ordered;
* no step requires the implementation agent to make a material design decision;
* risks, dependencies, assumptions, and unknowns are visible;
* exact details are evidence-backed;
* the plan is concise but sufficient for implementation;
* nothing implies that changes were made.
