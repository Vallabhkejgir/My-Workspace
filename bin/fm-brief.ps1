# fm-brief.ps1 - Scaffold a Firstmate crewmate brief (data/<TaskId>/brief.md)
param(
    [Parameter(Mandatory=$true)][string]$TaskId,
    [Parameter(Mandatory=$true)][string]$Project,
    [ValidateSet("ship", "scout")][string]$Kind = "ship",
    [ValidateSet("no-mistakes", "direct-PR", "local-only")][string]$Mode = "no-mistakes",
    [ValidateSet("on", "off")][string]$Yolo = "off",
    [string]$BranchPrefix = "fm/",
    [string]$BaseBranch = "",
    [string]$Intent = "{TASK}",
    [string]$Spec = "{FIRSTMATE_SPEC}"
)

$fmRoot = Split-Path -Parent $PSScriptRoot
$taskDir = Join-Path $fmRoot "data\$TaskId"
New-Item -ItemType Directory -Force $taskDir | Out-Null

$briefPath = Join-Path $taskDir "brief.md"
$worktreePath = Join-Path $fmRoot "Github\.worktrees\$TaskId"
$primaryPath = Join-Path $fmRoot "Github\$Project"
$reportPath = Join-Path $taskDir "report.md"
$branchName = "$BranchPrefix$TaskId"

if ($Kind -eq "ship") {
    $dod = switch ($Mode) {
        "no-mistakes" {
            @"
1. Implement and test the requested changes inside your isolated worktree (`$worktreePath`).
2. Commit your changes cleanly on branch `$branchName` (NEVER add `Co-Authored-By` or any Claude/AI attribution trailers to commit messages or PR descriptions).
3. Run the `no-mistakes` agent pipeline from the worktree:
   `no-mistakes axi run --intent "<concise self-sufficient summary of Captain's intent>"`
4. Process every synchronous gate return (`no-mistakes axi respond ...`). If an `ask-user` finding arises, stop and report it to Firstmate so Firstmate can adjudicate or escalate it.
5. Report completion to Firstmate once the PR is opened and CI is green, including the full `https://github.com/.../pull/...` URL.
"@
        }
        "direct-PR" {
            @"
1. Implement and test the requested changes inside your isolated worktree (`$worktreePath`).
2. Commit your changes cleanly on branch `$branchName` (NEVER add `Co-Authored-By` or any Claude/AI attribution trailers to commit messages or PR descriptions).
3. Push the branch to `origin` (`git push -u origin $branchName`) and open a pull request using `gh pr create` (or GitHub API).
4. Report the full PR URL (`https://...`) and verification summary to Firstmate. Do NOT merge the PR yourself.
"@
        }
        "local-only" {
            @"
1. Implement and test the requested changes inside your isolated worktree (`$worktreePath`).
2. Commit all changes cleanly on local branch `$branchName` and ensure `git status --porcelain` is completely clean.
3. Do NOT push to any remote and do NOT merge into the primary checkout (`$primaryPath`).
4. Report the completed branch name, commit hash, and verification results to Firstmate.
"@
        }
    }

    $content = @"
# FIRSTMATE_OP: v1 launch-brief
- **Task ID**: `$TaskId`
- **Role**: `ship` worker (autonomous crewmate)
- **Project**: `$Project`
- **Isolated Worktree**: `$worktreePath`
- **Primary Checkout (DO NOT TOUCH)**: `$primaryPath`
- **Branch**: `$branchName`
- **Delivery Mode**: `$Mode` (yolo=`$Yolo`)

## Worker Role & Safety Contract
1. **Never address the captain**: You report solely to Firstmate. Never write "captain" in commits, PR descriptions, code, or comments.
2. **Worktree Isolation Assertion**: Before editing any file, verify your working directory is `$worktreePath` and NOT `$primaryPath`. If you are in `$primaryPath`, stop immediately.
3. **Never edit project AGENTS.md / CLAUDE.md** except to fix factually wrong statements broken by your change.

## Captain's intent
$Intent

## Firstmate spec
$Spec

## Definition of Done ($Mode)
$dod
"@
} else {
    $content = @"
# FIRSTMATE_OP: v1 launch-brief
- **Task ID**: `$TaskId`
- **Role**: `scout` worker (autonomous investigator)
- **Project**: `$Project`
- **Isolated Worktree**: `$worktreePath`
- **Report Deliverable**: `$reportPath`

## Worker Role & Safety Contract
1. **Never address the captain**: You report solely to Firstmate. Never write "captain" in reports, code, or comments.
2. **Read-Only / Scratch Investigation**: Do NOT push branches, open PRs, or modify `$primaryPath`.
3. **Deliverable**: Write your complete, evidence-backed findings and any open decisions to `$reportPath`.

## Captain's intent
$Intent

## Firstmate spec
$Spec

## Definition of Done (scout)
1. Investigate the codebase in `$worktreePath` and gather concrete file/line evidence.
2. Write the standalone report to `$reportPath`.
3. Clearly list any unresolved architectural or product decisions at the end of `$reportPath` so Firstmate can hold them for the captain if needed.
"@
}

$content | Out-File -FilePath $briefPath -Encoding utf8
Write-Output "Scaffolded $Kind brief at: $briefPath"
