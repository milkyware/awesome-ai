# Azure Pipelines to GitHub Actions Mapping

Mapping table for the Azure Pipelines tasks, expressions, and constructs commonly
found in Azure Pipelines templates. Use the GitHub Actions column as the
replacement, then apply the surrounding notes.

## Tasks

| Azure Pipelines task           | GitHub Actions replacement                                                                     | Notes                                                                                                                                         |
| ------------------------------ | ---------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------- |
| `PowerShell@2`                 | `run: pwsh ./script.ps1` (or `shell: pwsh` for inline)                                         | Keep scripts over 4 lines in a separate file. Ensure cross-platform paths.                                                                    |
| `AzureCLI@2`                   | `azure/login@v2` (OIDC federated credentials) + `run: az ...`                                  | Map `scriptType: pscore` to `shell: pwsh`. Replace the Azure service connection with `azure/login` and repository or environment secrets.     |
| `UseDotNet@2`                  | `actions/setup-dotnet@v4`                                                                      | Pass the version through from the former task input.                                                                                          |
| `DotNetCoreCLI@2`              | `run: dotnet build` / `dotnet test` / `dotnet pack`                                            | Requires `actions/setup-dotnet` first. Preserve `dotnet test --logger trx --collect "Code coverage"` where the template used it.              |
| `Cache@2`                      | `actions/cache@v4`                                                                             | Convert the Azure `key` string into `key` and `path` inputs.                                                                                  |
| `PublishBuildArtifacts@1`      | `actions/upload-artifact@v4`                                                                   | Set `name` from the former artifact or stage name.                                                                                            |
| `PublishPipelineArtifact@1`    | `actions/upload-artifact@v4`                                                                   | Same as above.                                                                                                                                |
| `DownloadBuildArtifacts@1`     | `actions/download-artifact@v4`                                                                 | Use for inter-job artifact transfer.                                                                                                          |
| `PublishTestResults@2`         | `dorny/test-reporter@v1` or `mikepenz/action-junit-report@v1`                                  | Choose one action and pin it. Convert TRX to JUnit where required.                                                                            |
| `PublishCodeCoverageResults@2` | `codecov/codecov-action@v5`                                                                    | Emit Cobertura XML from `dotnet test` before uploading.                                                                                       |
| `CopyFiles@2`                  | `run: Copy-Item` (pwsh) or `run: cp`                                                           | Combine with `actions/upload-artifact` when the copy fed an artifact.                                                                         |
| `ArchiveFiles@2`               | `run: Compress-Archive` (pwsh) or `run: tar`                                                   | Combine with `actions/upload-artifact` when the archive was published.                                                                        |
| `Bash@3`                       | `run: ...` with `shell: bash`                                                                  | Preserve the inline script body.                                                                                                              |
| `Npm@1`                        | `actions/setup-node@v4` + `run: npm ci` / `npm install`                                        | Choose `npm ci` when a lockfile is present.                                                                                                   |
| `TerraformInstaller@1`         | `hashicorp/setup-terraform@v3`                                                                 | Pass the version through.                                                                                                                     |
| `TerraformTaskV4@4`            | `run: terraform init` / `plan` / `apply`                                                       | Replace the Azure service connection with backend authentication via `azure/login`.                                                           |
| `DownloadSecureFile@1`         | No direct equivalent                                                                           | Redesign to GitHub environment secrets or `azure/get-keyvault-secrets@v1`. Do not emulate by committing files. Flag this clearly to the user. |
| `NuGetAuthenticate@1`          | `actions/setup-dotnet@v4` with feed credentials, or an explicit `dotnet nuget add source` step | Requires a token secret for private feeds.                                                                                                    |

## Expressions and Variables

| Azure Pipelines construct         | GitHub Actions replacement                                        | Notes                                                                                     |
| --------------------------------- | ----------------------------------------------------------------- | ----------------------------------------------------------------------------------------- |
| `##vso[task.setvariable]`         | `$GITHUB_OUTPUT` (step output) or `$GITHUB_ENV` (environment)     | Rewrite each `##vso` command into the corresponding file append.                          |
| `##vso[task.logissue]`            | `::warning::` / `::error::` workflow commands                     | Rewrite the message-level commands.                                                       |
| `parameters:`                     | `inputs:` (`action.yml` or `on.workflow_call`)                    | Types differ; validate and coerce.                                                        |
| `variables:`                      | `env:` (inline) or `vars` / `secrets` (repository or environment) | Never inline secrets.                                                                     |
| Variable groups (`- group:`)      | GitHub repository or environment secrets and variables            | Split secret and non-secret values.                                                       |
| Compile-time `${{ }}` expressions | `${{ inputs.* }}`, `${{ github.* }}`, `${{ env.* }}`              | Not a one-to-one rewrite; remap each expression.                                          |
| `each` loops                      | `strategy.matrix`                                                 | Move the loop iteration values into a matrix.                                             |
| `condition:`                      | `if:`                                                             | Rewrite `succeeded()`, `failed()`, `always()` using `success()`, `failure()`, `always()`. |
| `dependsOn`                       | `needs:`                                                          | Map stage and job dependencies onto `needs`.                                              |
| `$(Variable)` runtime macro       | `${{ env.VAR }}` or `$VAR` inside the script                      | Choose by scope; macro syntax does not exist in GitHub Actions.                           |
| Service connections               | `azure/login@v2` with OIDC, or named secrets                      | Requires federated credentials configured on the Azure identity.                          |
| Environments and approvals        | GitHub Environments with required reviewers                       | Map ADO environment checks onto environment protection rules.                             |
| Multi-stage pipelines             | Multiple jobs, or a reusable workflow per stage                   | Higher-level orchestration becomes a reusable workflow.                                   |
