# Output Templates

Skeletons for the artefacts produced by this skill. Replace every placeholder.
Do not invent inputs, outputs, or defaults that the source template does not
support.

## Composite Action: `action.yml`

```yaml
name: <Action Name>
description: <One-line description of what the action does>

inputs:
  <input-name>:
    description: <What the input controls>
    required: <true|false>
    default: <default value, omit if not applicable>

outputs:
  <output-name>:
    description: <What the output contains>
    value: ${{ steps.<step-id>.outputs.<name> }}

runs:
  using: composite
  steps:
    - name: <Step name>
      shell: pwsh
      run: <inline script, or a file reference>
```

## Reusable Workflow: `<name>.yml`

```yaml
name: <Workflow Name>

on:
  workflow_call:
    inputs:
      <input-name>:
        description: <What the input controls>
        required: <true|false>
        type: <string|boolean|number>
        default: <default value, omit if not applicable>
    secrets:
      <secret-name>:
        description: <What the secret contains>
        required: <true|false>

permissions:
  <scope>: <read|write>

jobs:
  <job-id>:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: <Step name>
        run: <command>
```

## Readme (action or workflow)

````markdown
# <Name>

<Description>

## Basic Configuration

```yaml
<Example YAML that calls the action or workflow>
```

## Inputs

| Input | Description | Required | Default |
| ----- | ----------- | -------- | ------- |
|       |             |          |         |

## Required Permissions

```yaml
<Example permissions block>
```

## Outputs

| Output | Description |
| ------ | ----------- |
|        |             |

## Licence

<Licence statement>
````
