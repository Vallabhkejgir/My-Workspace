# fm-fleet-sync.ps1 - Safely fast-forward clean clones in Github/ and prune merged branches
param(
    [string]$Project = ""
)

$ErrorActionPreference = 'Continue'
$fmRoot = Split-Path -Parent $PSScriptRoot
$githubDir = Join-Path $fmRoot "Github"

if (-not (Test-Path $githubDir)) {
    Write-Output "No Github/ directory found."
    exit 0
}

$clones = Get-ChildItem -Path $githubDir -Directory -Force | Where-Object { $_.Name -ne ".worktrees" }
if ($Project -ne "") {
    $clones = $clones | Where-Object { $_.Name -eq $Project }
}

foreach ($c in $clones) {
    $name = $c.Name
    $path = $c.FullName
    $modeOut = & "$PSScriptRoot\fm-project-mode.ps1" $name 2>$null
    if ($modeOut -like "local-only*") {
        Write-Output "[$name] skipped (local-only)"
        continue
    }
    $dirty = git -C $path status --porcelain 2>$null
    if ($dirty) {
        Write-Output "[$name] skipped (dirty working tree)"
        continue
    }
    git -C $path fetch --prune origin 2>$null
    git -C $path pull --ff-only 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Output "[$name] synced (fast-forwarded)"
    } else {
        Write-Output "[$name] could not fast-forward cleanly"
    }
}
