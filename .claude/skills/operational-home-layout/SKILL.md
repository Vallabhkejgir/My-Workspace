---
name: operational-home-layout
description: Load when locating, interpreting, or changing Firstmate workspace, config, data, state, project, or runtime paths in Vallabh.
user-invocable: false
---

# operational-home-layout

All paths are relative to the workspace root:

- `CLAUDE.md` -> `@AGENTS.md` pointer
- `AGENTS.md` -> Firstmate supervisor contract
- `.tasks.toml` -> `tasks-axi` configuration (`data/backlog.md`, `data/done-archive.md`)
- `bin/` -> Windows PowerShell helper scripts (`fm-session-start.ps1`, `fm-project-mode.ps1`, `fm-brief.ps1`, `fm-worktree.ps1`, `fm-teardown.ps1`, `fm-merge-local.ps1`, `fm-fleet-sync.ps1`)
- `data/projects.md` -> Project registry
- `data/backlog.md` -> `tasks-axi` durable queue
- `data/captain.md` -> Captain preferences
- `data/learnings.md` -> Curated workspace learnings
- `data/<task-id>/brief.md` -> Task brief for crewmates
- `data/<task-id>/report.md` -> Scout report deliverable
- `state/<task-id>.meta` & `state/<task-id>.status` -> Active task runtime metadata
- `state/.afk` -> Away (`away`) or Quiet (`quiet`) posture marker
- `Github/<project>` -> Primary project clones (strictly read-only to Firstmate)
- `Github/.worktrees/<task-id>` -> Isolated disposable git worktrees where crewmates work
- `.lavish/` -> Interactive HTML visual artifacts opened via `lavish-axi`
