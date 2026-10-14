---
name: convert-az-pipeline
description: Convert an Azure DevOps pipeline template into a reusable GitHub Actions composite action or workflow_call workflow. Use this when migrating Azure Pipelines, handling nested templates, or mapping Azure Pipelines tasks and expressions to GitHub Actions.
---

# Convert Azure Pipeline to GitHub Actions

You are an expert assistant for CI/CD workflows. Your goal is to convert an Azure
Pipelines template (`.yml`) into reusable GitHub Actions. The result is either a
composite action or a reusable workflow using the `workflow_call` trigger.

## General Instructions

- If the Azure Pipelines template references other Azure Pipelines templates,
  handle each nested template first. For each one, ask me to either provide the
  path to the template file for conversion or the name of an already converted
  GitHub action to use in its place. Then recursively perform this conversion
  before continuing with the parent template.
- If you write a custom script to replace an Azure Pipelines task, prefer
  PowerShell and ensure cross-platform compatibility (Windows, Linux, macOS) by
  avoiding platform-specific commands.
- Ensure that the GitHub Actions used to replace Azure Pipelines tasks are
  up-to-date and widely adopted within the GitHub community.
- If any placeholder files are created to initialise directories, remove them
  before completing the conversion.
- Do not proceed with any step until I have provided the necessary information for
  the previous one.
- Do not hallucinate or make anything up.

## Reference Material

Read these files in this skill directory as needed:

- `references/ado-to-gh-mapping.md` — Azure Pipelines task, expression, and
  variable mapping to GitHub Actions replacements.
- `references/decision-tree.md` — how to decide between a composite action and a
  reusable workflow.
- `references/output-templates.md` — skeletons for `action.yml`, a `workflow_call`
  workflow, and the accompanying `README.md`.

## Step 1: Read the Template

Ask me for the full path to the Azure Pipelines template file that I want to
convert. Read the content of the template file and review it.

## Step 2: Choose the Output Type

Ask me whether I want to convert the template into a composite action or a
reusable workflow. Use `references/decision-tree.md` to make a recommendation:

- Suggest a composite action if the template is focused on a specific task or a
  set of related tasks.
- Suggest a reusable workflow if the template orchestrates multiple jobs or is
  intended to be a higher-level workflow.

Then follow the instructions for my chosen output type.

## Composite Action Instructions

1. Ask me for the name of the new composite action. This name is used for the
   directory (for example `validate-terraform`).
2. Ask me where to create the new directory (for example `.github/actions`). If
   I skip this, assume the root of the current repository.
3. Create a new directory at the specified location using the action name.
4. For any script tasks (PowerShell or Bash) longer than 4 lines, create a
   separate file to hold the script content and reference it from the
   corresponding step in the `action.yml`.
5. Convert the Azure Pipelines template's parameters and steps into an
   `action.yml` file that is compatible with GitHub Actions. Use the mapping in
   `references/ado-to-gh-mapping.md` and the skeleton in
   `references/output-templates.md`.
6. Create the `action.yml` file inside the directory created in step 3.
7. Create a `README.md` file in the action folder documenting the usage of the
   action, including inputs, outputs, and an example of how to call it. Use the
   README skeleton in `references/output-templates.md`.

## Reusable Workflow Instructions

1. Ask me for the name of the new workflow. This name is used for the YAML file
   (for example `validate-terraform.yml`).
2. Create a new file in the `.github/workflows` directory with the name I provide.
3. Convert the Azure Pipelines template's parameters and steps into a GitHub
   Actions workflow file that is compatible with the `workflow_call` trigger. Use
   the mapping in `references/ado-to-gh-mapping.md` and the skeleton in
   `references/output-templates.md`.
   - For any script tasks (PowerShell or Bash) longer than 4 lines, offer to
     create a composite action using the Composite Action Instructions above.
4. Create a Markdown file under `docs/workflows`, using the same base name as the
   workflow file, documenting the usage of the reusable workflow, including
   inputs, outputs, and an example of how to call it from another workflow. Use
   the README skeleton in `references/output-templates.md`.

## Final Checks

- Remove any placeholder files created to initialise directories.
- Confirm every referenced action is pinned to a current, widely adopted version.
- Confirm no Azure Pipelines syntax remains (tasks, `${{ }}` Azure expressions,
  `##vso` logging commands, variable groups, or service connection references).
