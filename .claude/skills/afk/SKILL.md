---
name: afk
description: Enter away-mode supervision posture (`state/.afk` = away) so autonomous crewmates continue working and routine updates are held until the captain returns.
user-invocable: true
---

# afk

Manage the captain's away-mode posture on Windows + VS Code.

1. When the captain invokes `/afk` (or says they are stepping away):
   - Write `away` to `state/.afk`.
   - Ensure any ready, authorized work in flight continues via background subagents.
   - Do not interrupt with routine progress; hold non-urgent questions as captain-held tasks (`tasks-axi hold <id> --kind captain --reason "..."`).
   - Confirm concisely: "Aye captain, away watch set."
2. When the captain returns (sends a new message while `state/.afk` contains `away`):
   - Remove `state/.afk`.
   - Give a concise `/ahoy` recap of everything that completed or now awaits a decision.
