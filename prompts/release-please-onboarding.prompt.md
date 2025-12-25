---
agent: agent
description: Onboard a repository with release-please by generating necessary manifest/config files, setting up workflows, and configuring repo settings.
---

# Release Please Onboarding

This plan outlines a prompt to onboard a repository with release-please, guiding the user through manifest/config creation, workflow setup, and repo settings.

## Steps

1. Get the latest tag from the repository to determine the current version.
2. If a tag is detected, confirm the tag is correct with the user.
3. If no tag is found, assume the current tag is `v0.0.0` and create a new git tag on the most recent main commit.
4. Generate a `.release-please-manifest.json` using the current tag following semantic versioning rules, excluding prefixes like `v` (e.g. 0.0.5). The manifest should follow the following format:

```json
{
  ".": "semantic version e.g. 0.0.0"
}
```

5. Present the `release-please-config.json` below as the default.

```json
{
  "exclude-paths": [
    ".git",
    ".idea",
    ".github",
    ".vscode"
  ],
  "release-type": "simple",
  "bump-minor-pre-major": true,
  "bump-patch-for-minor-pre-major": true,
  "include-v-in-tag": true,
  "packages": {
    ".": {
      "changelog-path": "CHANGELOG.md",
      "extra-files": [
        "README.md"
      ]
    }
  },
  "$schema": "https://raw.githubusercontent.com/googleapis/release-please/main/schemas/config.json"
}
```

6. Ask the user to confirm using the default config.
7. If confirmed, create or overwrite the `release-please-config.json` at the root of the repository using the default config.
8. If the user declines the default config, present all available release-please-config.json options up front, based on the official **[JSON schema](https://raw.githubusercontent.com/googleapis/release-please/main/schemas/config.json)**. Do not omit or invent options. For each option, provide a brief description and the default value if applicable.
9. Ask the user to specify their desired configuration for each option, or accept the default.
10. Validate the resulting config against the schema before writing. Ensure all values are the correct type (e.g., extra-label are comma-separated strings, not arrays).
11. Add a standard release-please workflow YAML file to `.github/workflows/`. such as below:

```yaml
name: Release Please

on:
  push:
    branches:
      - main
  workflow_dispatch:

permissions:
  contents: write
  pull-requests: write

jobs:
  release-please:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v6

      - uses: googleapis/release-please-action@v4
        with:
          token: ${{ secrets.GITHUB_TOKEN }}
```

12. Add a PR title validation workflow YAML file to `.github/workflows/` such as below:

```yaml
name: Validate PR Title

on:
  pull_request_target:
    types: 
      - opened
      - edited
      - reopened
      - synchronize

jobs:
  job:
    runs-on: ubuntu-latest
    permissions:
      pull-requests: read
    steps:
      - uses: amannn/action-semantic-pull-request@v6
        env: 
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

13. Prompt the user to ensure the following:
  - Squash merges are enabled with PR title as the default commit message
  - GitHub Actions are permitted to create and approve pull requests.

## Further Considerations

1. Should the manifest include all packages or just the root? (Monorepo vs. single package)
2. Offer to auto-detect or manually specify config options if the user declines the default.
3. Confirm if the user wants to review or customize the workflow YAMLs before adding.