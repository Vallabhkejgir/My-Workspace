---
name: bearings
description: Generate a concise four-section chat digest from fleet state (In flight, Waiting on you, Recently landed, Queued / Backlog); use `/bearings file` to also write `data/status-report-<YYYY-MM-DD>.md`, and `include PRs` for live GitHub PR enrichment.
user-invocable: true
---

# bearings

Generate a concise four-section fleet status digest for the captain.

1. Run `& ".\bin\fm-session-start.ps1"` (or `tasks-axi list`) to read current projects, active worktrees in `Github/.worktrees/`, and backlog state in `data/backlog.md`.
2. If the captain passed `include PRs`, also query open PRs across registered repositories in `data/projects.md` (via `gh pr list` or GitHub API for `Vallabhkejgir`).
3. Present the four-section digest in plain outcome language:
   - **In flight**: Active tasks currently running in isolated worktrees.
   - **Waiting on you**: Tasks held for the captain (`tasks-axi list` with `hold_kind=captain`) or PRs/local branches awaiting merge approval (always include full `https://...` URLs).
   - **Recently landed**: Recent `done` items from `tasks-axi list --state done`.
   - **Queued**: Ready or blocked items in `tasks-axi`.
4. If the captain passed `file`, also write the full report to `data/status-report-<YYYY-MM-DD>.md` and reference its path in the chat digest.
5. If the captain asks for a visual bearings board, render an interactive HTML dashboard under `.lavish/bearings-board.html` and open it with `lavish-axi .lavish/bearings-board.html`.
