---
name: scout-completion
description: Load when a scout task finishes its investigation report (`data/<id>/report.md`), presents a visual artifact, or is promoted to a ship task.
user-invocable: false
---

# scout-completion

1. Verify `data/<task-id>/report.md` exists and contains concrete, evidence-backed findings.
2. Review any unresolved decisions surfaced by the report:
   - For each genuine captain call, create or hold a task in `tasks-axi` (`tasks-axi hold <id> --kind captain --reason "<reason>"`).
3. Relay the substantive findings (not just "the report is done") to the captain in plain outcome language, along with any decisions needing their call.
4. Clean up the scratch worktree safely using:
   `& ".\bin\fm-teardown.ps1" -TaskId <task-id>`
   (`data/<task-id>/report.md` survives teardown).
5. If the captain later approves implementing the scout's plan, dispatch a new `ship` task referencing `data/<scout-id>/report.md` in its brief.
