---
name: project-management
description: Procedure for adding, cloning, creating, initializing, or removing a project under Github/ and registering its delivery posture in data/projects.md.
user-invocable: false
---

# project-management

Use this procedure before adding, cloning, creating, removing, or initializing a project in the workspace.

## 1. Registry & Clone Path
- All project repositories live flat under `Github/<name>`.
- `data/projects.md` is the fleet registry, parsed by `bin/fm-project-mode.ps1`.
- Registry line format:
  `- <name> [<mode> <optional +yolo> <optional branch=prefix>] - <description> (added YYYY-MM-DD)`

## 2. Delivery Postures
- `no-mistakes`: runs the full `no-mistakes` validation pipeline before opening a PR.
- `direct-PR`: pushes branch and opens a PR without the `no-mistakes` pipeline.
- `local-only`: local branch only, lands via `bin/fm-merge-local.ps1` after captain approval.
- `no-mistakes-prod-only` (default for remote-backed projects): internal-only tooling/docs/CI changes ship `direct-PR`; product-facing or uncertain changes ship `no-mistakes`.
- `+yolo` (default off): when enabled on a project, Firstmate merges green, in-scope PRs or local branches automatically.

## 3. Adding or Cloning an Existing Project
1. Confirm the source URL (e.g. `https://github.com/Vallabhkejgir/<name>`), local name (`Github/<name>`), delivery posture (default `no-mistakes-prod-only`), and autonomy (`yolo` off).
2. Verify `Github/<name>` does not already exist, then clone:
   `git clone https://github.com/Vallabhkejgir/<name>.git Github/<name>`
3. Add the entry to `data/projects.md`.
4. If the posture is `no-mistakes` or `no-mistakes-prod-only`, initialize the local `no-mistakes` gate:
   `cd Github/<name>; no-mistakes init; no-mistakes doctor`

## 4. Creating a New Project
- **Remote-backed**: Propose repo name, owner (`Vallabhkejgir`), visibility (default `private`), and posture (`no-mistakes-prod-only`). Obtain explicit captain consent before creating on GitHub.
- **Local-only**: Run `git init Github/<name>` and register as `[local-only]` in `data/projects.md` with no remote calls.

## 5. Removing a Project
- Removal is destructive. Obtain explicit captain approval first.
- Verify no in-flight tasks, active worktrees in `Github/.worktrees/`, uncommitted changes, or unpushed commits exist for the project before removing `Github/<name>` and its line in `data/projects.md`.
