[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Name,
    [Parameter(Mandatory = $true)]
    [string]$Owner
)
begin
{
    $InformationPreference = 'Continue'
    if ($env:RUNNER_DEBUG)
    {
        $DebugPreference = 'Continue'
        $VerbosePreference = 'Continue'
    }
    $repoRoot = Split-Path -Parent (Split-Path -Path $PSScriptRoot)
}
process {
  $pluginFiles = Get-ChildItem -Path "plugins/*/plugin.json" -File

  $plugins = [System.Collections.ArrayList]::new()
  $pluginFiles | ForEach-Object {
    $json = Get-Content $_.FullName | ConvertFrom-Json

    $source = (Resolve-Path -Path $_.DirectoryName -Relative) -replace '\\', '/'
    Write-Verbose "source=$source"
    
    $plugin = [ordered]@{
      name = $json.name
      description = $json.description
      version = $json.version
      source = $source
    }
    $plugins.Add($plugin) | Out-Null
  }

  $marketplace = [ordered]@{
    name = $Name
    owner = [ordered]@{
      name = $Owner
    }
    plugins = $plugins
  }

  $marketplaceJson = $marketplace | ConvertTo-Json -Depth 100
  $marketplaceJson | Out-File -FilePath ".github/plugin/marketplace.json" -Force
}