# fm-project-mode.ps1 - Resolve a project's registered delivery posture from data/projects.md
# Usage:
#   powershell -ExecutionPolicy Bypass -File bin/fm-project-mode.ps1 [-Raw] [-BranchPrefix] <ProjectName>
param(
    [switch]$Raw,
    [switch]$BranchPrefix,
    [Parameter(Mandatory=$true, Position=0)]
    [string]$ProjectName
)

$fmRoot = Split-Path -Parent $PSScriptRoot
$regPath = Join-Path $fmRoot "data\projects.md"

$mode = "no-mistakes"
$yolo = "off"
$branch = "fm/"

if (-not (Test-Path $regPath)) {
    [Console]::Error.WriteLine("warn: no registry at $regPath; defaulting $ProjectName to no-mistakes off")
    if ($BranchPrefix) { Write-Output $branch } else { Write-Output "$mode $yolo" }
    exit 0
}

$found = $false
foreach ($line in (Get-Content $regPath)) {
    $prefix = "- $ProjectName"
    if ($line.StartsWith($prefix)) {
        $after = $line.Substring($prefix.Length)
        if ($after -ne "" -and -not $after.StartsWith(" [") -and -not $after.StartsWith(" - ")) {
            continue
        }
        $found = $true
        if ($after.StartsWith(" [")) {
            $closeIdx = $after.IndexOf("]")
            if ($closeIdx -gt 2) {
                $bracketContent = $after.Substring(2, $closeIdx - 2)
                $tokens = $bracketContent -split "\s+"
                $modeSet = $false
                foreach ($tok in $tokens) {
                    if ($tok -eq "+yolo") { $yolo = "on"; continue }
                    if ($tok -like "branch=*") { $branch = $tok.Substring(7); continue }
                    if ($tok -ne "" -and -not $modeSet) {
                        $mode = $tok
                        $modeSet = $true
                    }
                }
            }
        }
        break
    }
}

if (-not $found) {
    [Console]::Error.WriteLine("warn: project '$ProjectName' not in registry; defaulting to no-mistakes off")
}

if ($mode -notin @("no-mistakes", "direct-PR", "local-only", "no-mistakes-prod-only")) {
    [Console]::Error.WriteLine("warn: unknown mode '$mode' for $ProjectName; defaulting to no-mistakes off")
    $mode = "no-mistakes"
    $yolo = "off"
    $branch = "fm/"
}

if ($BranchPrefix) {
    Write-Output $branch
    exit 0
}

if (-not $Raw -and $mode -eq "no-mistakes-prod-only") {
    $mode = "no-mistakes"
}

Write-Output "$mode $yolo"
