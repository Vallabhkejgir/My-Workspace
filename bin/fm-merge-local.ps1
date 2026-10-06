# fm-merge-local.ps1 - Guarded fast-forward merge for approved local-only ship tasks
param(
    [Parameter(Mandatory=$true)][string]$TaskId
)

$ErrorActionPreference = 'Stop'
$fmRoot = Split-Path -Parent $PSScriptRoot
$metaPath = Join-Path $fmRoot "state\$TaskId.meta"

if (-not (Test-Path $metaPath)) {
    Write-Error "refused: Metadata file not found for $TaskId"
    exit 2
}

$meta = @{}
foreach ($line in (Get-Content $metaPath)) {
    if ($line -match "^([^=]+)=(.*)$") {
        $meta[$Matches[1]] = $Matches[2]
    }
}

$primaryPath = $meta["primary"]
$worktreePath = $meta["worktree"]
$branch = $meta["branch"]
$baseBranch = $meta["base_branch"]

# Verify worktree is clean
if (Test-Path $worktreePath) {
    $wtDirty = git -C $worktreePath status --porcelain
    if ($wtDirty) {
        Write-Error "refused: Worktree $worktreePath has uncommitted changes."
        exit 2
    }
}

# Verify primary checkout is clean and on baseBranch
$primDirty = git -C $primaryPath status --porcelain
if ($primDirty) {
    Write-Error "refused: Primary checkout $primaryPath has uncommitted changes."
    exit 2
}

$currentBranch = (git -C $primaryPath rev-parse --abbrev-ref HEAD).Trim()
if ($currentBranch -ne $baseBranch) {
    Write-Error "refused: Primary checkout is on '$currentBranch', expected '$baseBranch'."
    exit 2
}

# Fast-forward merge
git -C $primaryPath merge --ff-only $branch
if ($LASTEXITCODE -ne 0) {
    Write-Error "refused: Fast-forward merge failed. Have the worker rebase $branch onto $baseBranch first."
    exit 2
}

$headSha = (git -C $primaryPath rev-parse --short HEAD).Trim()
Write-Output "Merged $branch into $baseBranch ($headSha) in $primaryPath"
