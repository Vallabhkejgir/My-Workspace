# fm-worktree.ps1 - Create & verify an isolated git worktree for a task, and start it in tasks-axi
param(
    [Parameter(Mandatory=$true)][string]$TaskId,
    [Parameter(Mandatory=$true)][string]$Project,
    [ValidateSet("ship", "scout")][string]$Kind = "ship",
    [string]$Mode = "no-mistakes",
    [string]$Yolo = "off",
    [string]$BranchPrefix = "fm/",
    [string]$BaseBranch = ""
)

$ErrorActionPreference = 'Stop'
$env:Path = "$env:Path;$env:USERPROFILE\.local\bin;C:\Program Files\GitHub CLI"

$fmRoot = Split-Path -Parent $PSScriptRoot
$repoPath = Join-Path $fmRoot "Github\$Project"
$worktreeRoot = Join-Path $fmRoot "Github\.worktrees"
$worktreePath = Join-Path $worktreeRoot $TaskId
$stateDir = Join-Path $fmRoot "state"
$metaPath = Join-Path $stateDir "$TaskId.meta"
$statusPath = Join-Path $stateDir "$TaskId.status"

if (-not (Test-Path $repoPath)) {
    Write-Error "refused: Project clone not found at $repoPath. Clone or initialize the project first."
    exit 2
}

New-Item -ItemType Directory -Force $worktreeRoot | Out-Null
New-Item -ItemType Directory -Force $stateDir | Out-Null

if ($BaseBranch -eq "") {
    $BaseBranch = (git -C $repoPath rev-parse --abbrev-ref HEAD).Trim()
}

$branchName = "$BranchPrefix$TaskId"

if (-not (Test-Path $worktreePath)) {
    $branchExists = git -C $repoPath branch --list $branchName
    if ($branchExists) {
        git -C $repoPath worktree add $worktreePath $branchName
    } else {
        git -C $repoPath worktree add -b $branchName $worktreePath $BaseBranch
    }
    if ($LASTEXITCODE -ne 0) {
        Write-Error "refused: Failed to create git worktree at $worktreePath"
        exit 2
    }
}

# Verify isolation: worktree path must differ from primary checkout
$resolvedPrimary = (Resolve-Path $repoPath).Path
$resolvedWorktree = (Resolve-Path $worktreePath).Path
if ($resolvedPrimary -eq $resolvedWorktree) {
    Write-Error "refused: Isolation assertion failed! Worktree resolved to primary checkout."
    exit 2
}

# Record metadata
@"
id=$TaskId
project=$Project
kind=$Kind
mode=$Mode
yolo=$Yolo
branch=$branchName
base_branch=$BaseBranch
worktree=$resolvedWorktree
primary=$resolvedPrimary
created=$((Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ'))
"@ | Out-File -FilePath $metaPath -Encoding utf8

if (-not (Test-Path $statusPath)) {
    "working: spawned $Kind task $TaskId on $Project ($branchName)" | Out-File -FilePath $statusPath -Encoding utf8
}

# Transition tasks-axi item to in_flight if present
Set-Location $fmRoot
try {
    tasks-axi start $TaskId 2>$null | Out-Null
} catch {}

Write-Output "Worktree ready: $resolvedWorktree (branch: $branchName, base: $BaseBranch)"
