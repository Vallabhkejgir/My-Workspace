---
name: ahoy
description: Recap visible session events and guide the captain through visibly unanswered decisions when the captain explicitly invokes /ahoy, with a Bearings fallback when /ahoy is the session's first real captain message.
user-invocable: true
---

# ahoy

Give the captain a concise session-only recap without gathering fresh state.

0. Check whether a `FIRSTMATE SESSION START DIGEST` is visible in this session's history. If not, run `& ".\bin\fm-session-start.ps1"` once before producing any recap.
1. Inspect conversation history since the most recent real captain-authored message before `/ahoy`.
2. If `/ahoy` is the first real captain message of the session, invoke `/bearings` instead and return its four-section digest.
3. Otherwise:
   - Summarize what finished, changed, or surfaced since the captain's last message in plain outcome language.
   - List any visibly unanswered captain decisions (PR merge approvals, design choices, or tasks held for the captain in `tasks-axi`).
   - Guide the captain through open decisions one at a time in impact order.
