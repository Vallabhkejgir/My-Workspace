---
name: stow
description: Sweep the session for uncaptured durable knowledge, persist open work records in tasks-axi, curate data/captain.md and data/learnings.md, and report what is safe to reset.
user-invocable: true
---

# stow

Sweep the session for uncaptured durable knowledge and ensure all state is safely persisted to disk before the captain resets or closes the session.

1. **Open Work & Decisions**:
   - Check if any work discussed in this session is unfiled in `tasks-axi` (`data/backlog.md`) or if any task status/note is stale. Update via `tasks-axi`.
2. **Knowledge Routing**:
   - **Captain preferences & working style** -> inspect `data/captain.md` and update in place (rewrite/prune rather than appending duplicates).
   - **Workspace operational facts & gotchas** -> inspect `data/learnings.md` and update with dated, evidence-backed entries.
   - **Task-specific notes** -> store on the task in `tasks-axi update <id> --body ...`.
   - **Investigation findings** -> ensure saved in `data/<id>/report.md`.
3. **Worktree Safety Check**:
   - Check `Github/.worktrees/` for any finished tasks that can be cleanly torn down via `bin/fm-teardown.ps1`, or warn if any worktree has uncommitted/unlanded work.
4. Report concisely to the captain what was stowed and confirm whether the session is clean to reset.
