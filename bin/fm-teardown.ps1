# fm-teardown.ps1 - Guarded teardown of a task worktree after verifying work is landed
param(
    [Parameter(Mandatory=$true)][string]$TaskId,
    [string]$PrUrl = "",
    [switch]$Force
)

$ErrorActionPreference = 'Stop'
$env:Path = "$env:Path;$env:USERPROFILE\.local\bin;C:\Program Files\GitHub CLI"

$fmRoot = Split-Path -Parent $PSScriptRoot
$metaPath = Join-Path $fmRoot "state\$TaskId.meta"
$worktreePath = Join-Path $fmRoot "Github\.worktrees\$TaskId"

if (-not (Test-Path $metaPath)) {
    Write-Error "refused: Metadata file not found at $metaPath"
    exit 2
}

$meta = @{}
foreach ($line in (Get-Content $metaPath)) {
    if ($line -match "^([^=]+)=(.*)$") {
        $meta[$Matches[1]] = $Matches[2]
    }
}

$kind = $meta["kind"]
$project = $meta["project"]
$branch = $meta["branch"]
$baseBranch = $meta["base_branch"]
$primaryPath = $meta["primary"]

if (Test-Path $worktreePath) {
    if ($kind -eq "scout") {
        $reportPath = Join-Path $fmRoot "data\$TaskId\report.md"
        if (-not (Test-Path $reportPath) -and -not $Force) {
            Write-Error "refused: Scout report does not exist at $reportPath. Cannot tear down scout worktree without report."
            exit 2
        }
    } else {
        # Ship task: check uncommitted changes
        $dirty = git -C $worktreePath status --porcelain
        if ($dirty -and -not $Force) {
            Write-Error "refused: Worktree $worktreePath has uncommitted changes. Never tear down unlanded work without explicit captain discard approval (-Force)."
            exit 2
        }

        # Check if commits on branch are either merged into baseBranch or pushed to origin
        $unmergedLocal = git -C $worktreePath log "$baseBranch..HEAD" --oneline 2>$null
        if ($unmergedLocal -and -not $Force) {
            $remoteBranch = git -C $worktreePath rev-parse --verify "origin/$branch" 2>$null
            $localHead = git -C $worktreePath rev-parse HEAD 2>$null
            if ($LASTEXITCODE -ne 0 -or $remoteBranch -ne $localHead) {
                # Also check if merged into origin/$baseBranch
                $unmergedRemote = git -C $worktreePath log "origin/$baseBranch..HEAD" --oneline 2>$null
                if ($unmergedRemote) {
                    Write-Error "refused: Branch $branch has unlanded commits not merged into $baseBranch or pushed to origin/$branch."
                    exit 2
                }
            }
        }
    }

    # Remove worktree
    git -C $primaryPath worktree remove $worktreePath --force
}

# Close in tasks-axi
Set-Location $fmRoot
if ($kind -eq "scout") {
    tasks-axi done $TaskId --report "data/$TaskId/report.md"
} elseif ($PrUrl -ne "") {
    tasks-axi done $TaskId --pr $PrUrl
} else {
    tasks-axi done $TaskId
}

Remove-Item -Force "$fmRoot\state\$TaskId.meta" -ErrorAction SilentlyContinue
Remove-Item -Force "$fmRoot\state\$TaskId.status" -ErrorAction SilentlyContinue

Write-Output "Teardown complete for $TaskId ($kind on $project)."
