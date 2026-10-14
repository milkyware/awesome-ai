---
name: onboard-release-please
description: Onboard a repository with release-please by generating the manifest, configuration, workflows, and repository-settings checklist for a single-package or mono-repo layout. Use this when setting up release-please, choosing versioning options, or tailoring its configuration.
---

# Onboard Release Please

You are an expert at release automation. Your goal is to onboard a repository with
release-please by generating the manifest and configuration files, adding the
required workflows, and guiding the user through the repository settings.

Work through the steps in order. Do not proceed to a later step until the user has
answered the current one.

## Step 1: Determine the Current Version

1. Get the latest tag from the repository to determine the current version.
2. If a tag is detected, confirm the tag is correct with the user.
3. If no tag is found, assume the repository is unreleased and start from a
   pre-1.0 version. Do not use `0.0.0` in the manifest; release-please ignores it.

## Step 2: Choose the Repository Layout

Ask the user whether the repository is a single package or a mono-repo.

- **Single package**: the manifest uses `"."` as its only key.
- **Mono-repo**: the manifest uses one key per package path.

## Step 3: Choose the Starting Version

Ask the user whether versioning should start with a pre-1.0 version (for example
`0.0.1`) or with a stable `1.0.0`.

Do not use `0.0.0`; release-please treats it as unreleased and ignores it.

## Step 4: Present the Default Configuration

Present the following generic configuration as the default, and show the contents
of `references/default-config.json`.

```json
{
  "$schema": "https://raw.githubusercontent.com/googleapis/release-please/main/schemas/config.json",
  "release-type": "simple",
  "bump-minor-pre-major": true,
  "bump-patch-for-minor-pre-major": true,
  "include-v-in-tag": true,
  "exclude-paths": [".git", ".idea", ".vscode"],
  "packages": { ".": {} }
}
```

Ask the user to confirm the default. If the user declines, present the options
from the official JSON schema at the `$schema` URL. Do not omit or invent options.
For each option, provide a brief description and its default value where
applicable.

## Step 5: Changelog Path

Ask the user whether to default the changelog to the top of the package or to
customise it:

- **Single package**: `CHANGELOG.md` at the repository root.
- **Mono-repo**: `CHANGELOG.md` at the top of each package path.

If the user customises it, capture the path per package.

## Step 6: Mono-Repo Packages

If the user chose a mono-repo:

1. Propose a `packages` object with one key per package path.
2. Ask the user to confirm or refine the proposal.
3. Set `always-update` to `true`. For a single package, omit `always-update`.

## Step 7: Optional Tailoring

Ask the user whether to tailor any of the following, and apply only what they
confirm:

- `release-type` (default `simple`; use a language-specific type when
  appropriate).
- Tag format: `include-v-in-tag`, `include-component-in-tag`, `tag-separator`.
- `separate-pull-requests`.
- `changelog-sections`.
- `extra-files` version bump targets per package (for example a JSON or YAML
  file with a `version` field).
- `exclude-paths` edits.

## Step 8: Validate Before Writing

Validate the resulting configuration against the schema before writing it. Ensure
all values are the correct type (for example `extra-label` values are
comma-separated strings, not arrays). Do not write an invalid configuration.

## Step 9: Write the Files

1. Write `.release-please-manifest.json` with the starting version from Step 3,
   using semantic versioning without a `v` prefix (for example `0.0.1`).
2. Write `release-please-config.json` at the repository root.

## Step 10: Add the Workflows

Confirm with the user whether they want to review the workflow YAML before it is
added.

Add a release-please workflow to `.github/workflows/`:

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
        uses: actions/checkout@v4

      - uses: googleapis/release-please-action@v4
        with:
          token: ${{ secrets.GITHUB_TOKEN }}
```

Add a PR title validation workflow to `.github/workflows/`:

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
  validate:
    runs-on: ubuntu-latest
    permissions:
      pull-requests: read
    steps:
      - uses: amannn/action-semantic-pull-request@v6
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

## Step 11: Repository Settings Checklist

Prompt the user to confirm the following:

- Squash merges are enabled, with the PR title as the default commit message.
- GitHub Actions are permitted to create and approve pull requests.

## Final Checks

- The manifest uses a real version, never `0.0.0`.
- `always-update` is present only for a mono-repo.
- The configuration validates against the schema.
- Both workflows are present and use `secrets.GITHUB_TOKEN`.
