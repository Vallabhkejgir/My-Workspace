---
name: captain-hold-lifecycle
description: Load when holding a task or decision for the captain in tasks-axi or resolving an answered captain call.
user-invocable: false
---

# captain-hold-lifecycle

1. **Holding a task or decision for the captain**:
   - If gating an existing queued task: `tasks-axi hold <task-id> --kind captain --reason "<plain-English decision needed>"` (add `--until YYYY-MM-DD` if deferred).
   - If filing a standalone decision discovered by a scout: `tasks-axi add <decision-id> "<title>" --kind captain --repo <project>` followed by `tasks-axi hold <decision-id> --kind captain --reason "<reason>"`.
2. **Resolving when the captain answers**:
   - Record the captain's exact decision in the task body (`tasks-axi update <id> --body "Captain decision (YYYY-MM-DD): <answer>" --archive-body`).
   - If it was a standalone question, close it with `tasks-axi done <id>`.
   - If it was a held work item that should now proceed, release it with `tasks-axi unhold <id>` and dispatch it.
