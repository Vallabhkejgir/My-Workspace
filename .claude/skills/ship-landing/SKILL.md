---
name: ship-landing
description: Load when a ship task reports a ready PR or local branch, when deciding or monitoring landing, and before task worktree teardown.
user-invocable: false
---

# ship-landing

1. When a ship crewmate completes its work:
   - Verify the worktree (`Github/.worktrees/<task-id>`) has zero uncommitted changes (`git status --porcelain`).
2. Check merge authority (`yolo=on` vs `yolo=off` in `state/<task-id>.meta`):
   - **`yolo=off` (default)**: Report the outcome, risk summary, verification status, and full PR URL (or local branch diff summary for `local-only`) to the captain and ask whether to merge/land.
   - **`yolo=on`**: Verify all checks/tests are green and the change is strictly in scope and non-destructive, then merge (or run `bin/fm-merge-local.ps1 -TaskId <task-id>` for `local-only`) and report the one-line outcome with full URL or commit hash.
3. Once landed (PR merged, or local branch merged via `bin/fm-merge-local.ps1`, or PR pushed and handed off), run:
   `& ".\bin\fm-teardown.ps1" -TaskId <task-id> [-PrUrl <url>]`
   and if a remote PR was merged, sync the primary clone with:
   `& ".\bin\fm-fleet-sync.ps1" -Project <project>`
