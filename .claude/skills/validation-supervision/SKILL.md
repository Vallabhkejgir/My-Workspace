---
name: validation-supervision
description: Load when a ship starts or has an active no-mistakes validation run, or before deciding/answering any ask-user finding.
user-invocable: false
---

# validation-supervision

1. For a `no-mistakes` ship task, the crewmate working inside `Github/.worktrees/<task-id>` commits its changes and runs:
   `no-mistakes axi run --intent "<self-sufficient summary of Captain's intent>"`
2. The crewmate owns `no-mistakes axi run` and `no-mistakes axi respond` calls inside its worktree.
3. If `no-mistakes` surfaces an `ask-user` finding, the crewmate reports it to Firstmate. Firstmate loads `ask-user-authority`:
   - If the finding is purely mechanical/in-scope and already answered by the captain's stated intent, Firstmate steers the worker (`SendMessage`) with the exact response command.
   - If the finding affects product behavior, scope, security, or ambiguous intent, Firstmate escalates the decision to the captain with concrete evidence, consequence, options, and recommendation.
4. To generate a GitHub Actions CI workflow from `.no-mistakes.yaml` for CI/CD, instruct the crewmate to run `no-mistakes ci-workflow` inside its worktree.
