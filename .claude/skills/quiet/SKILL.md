---
name: quiet
description: Enter quiet-mode posture (`state/.afk` = quiet) to batch non-urgent worker notifications while chatting with the captain; use `/quiet off` to exit.
user-invocable: true
---

# quiet

Manage quiet mode while the captain remains at the helm.

1. `/quiet` writes `quiet` to `state/.afk`. While active, batch routine background worker completions into your next natural reply and surface only urgent blockers, finished deliverables ready for merge/review, or direct answers to the captain's current chat.
2. `/quiet off` removes `state/.afk` and restores immediate reporting.
