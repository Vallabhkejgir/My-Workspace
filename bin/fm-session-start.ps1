# fm-session-start.ps1 - Generate the Firstmate Session Start digest on Windows
$ErrorActionPreference = 'Continue'
$env:Path = "$env:Path;$env:USERPROFILE\.local\bin;C:\Program Files\GitHub CLI"

$fmRoot = Split-Path -Parent $PSScriptRoot
Set-Location $fmRoot

Write-Output "=== FIRSTMATE SESSION START DIGEST ==="
Write-Output "Home: $fmRoot"
Write-Output "Timestamp: $((Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ'))"
Write-Output ""

# 1. Toolchain status
Write-Output "--- TOOLCHAIN ---"
$tools = @("git", "gh", "no-mistakes", "tasks-axi", "lavish-axi")
foreach ($t in $tools) {
    $cmd = Get-Command $t -ErrorAction SilentlyContinue
    if ($cmd) {
        Write-Output "  [OK] $t ($($cmd.Source))"
    } else {
        Write-Output "  [MISSING] $t"
    }
}
Write-Output ""

# 2. Captain & Learnings summary
Write-Output "--- CAPTAIN & LEARNINGS ---"
if (Test-Path "$fmRoot\data\captain.md") {
    Get-Content "$fmRoot\data\captain.md" | Write-Output
} else {
    Write-Output "  data/captain.md: ABSENT"
}
Write-Output ""
if (Test-Path "$fmRoot\data\learnings.md") {
    Get-Content "$fmRoot\data\learnings.md" | Write-Output
} else {
    Write-Output "  data/learnings.md: ABSENT"
}
Write-Output ""

# 3. Registered Projects & Clones in Github/
Write-Output "--- PROJECTS REGISTRY (data/projects.md) ---"
if (Test-Path "$fmRoot\data\projects.md") {
    $regLines = Get-Content "$fmRoot\data\projects.md" | Where-Object { $_ -match "^- " }
    if ($regLines) {
        $regLines | Write-Output
    } else {
        Write-Output "  (No projects registered yet)"
    }
} else {
    Write-Output "  data/projects.md: ABSENT"
}

Write-Output ""
Write-Output "--- CLONED REPOSITORIES (Github/) ---"
if (Test-Path "$fmRoot\Github") {
    $clones = Get-ChildItem -Path "$fmRoot\Github" -Directory -Force | Where-Object { $_.Name -ne ".worktrees" }
    if ($clones) {
        foreach ($c in $clones) {
            $branch = git -C $c.FullName rev-parse --abbrev-ref HEAD 2>$null
            Write-Output "  - $($c.Name) (branch: $branch)"
        }
    } else {
        Write-Output "  (No repositories cloned in Github/ yet)"
    }
}
Write-Output ""

# 4. Active Isolated Worktrees
Write-Output "--- ACTIVE TASK WORKTREES (Github/.worktrees/) ---"
if (Test-Path "$fmRoot\Github\.worktrees") {
    $wts = Get-ChildItem -Path "$fmRoot\Github\.worktrees" -Directory -Force
    if ($wts) {
        foreach ($wt in $wts) {
            $branch = git -C $wt.FullName rev-parse --abbrev-ref HEAD 2>$null
            $dirty = (git -C $wt.FullName status --porcelain 2>$null | Measure-Object).Count
            Write-Output "  - $($wt.Name) [branch=$branch, dirty_files=$dirty]"
        }
    } else {
        Write-Output "  (None)"
    }
}
Write-Output ""

# 5. Backlog (tasks-axi)
Write-Output "--- BACKLOG (tasks-axi) ---"
if (Get-Command tasks-axi -ErrorAction SilentlyContinue) {
    tasks-axi
} else {
    Write-Output "  tasks-axi not found"
}
Write-Output "=== END SESSION START DIGEST ==="
