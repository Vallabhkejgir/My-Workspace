---
name: ask-user-authority
description: Load before deciding or answering any worker blocker or no-mistakes ask-user gate finding.
user-invocable: false
---

# ask-user-authority

When a worker or `no-mistakes` validation run raises a question or finding:
1. **Answer directly as Firstmate ONLY when**:
   - The captain's explicit intent in `data/<task-id>/brief.md` or `data/captain.md` already unambiguously settles the question, OR
   - It is a purely internal mechanical fix (e.g., formatting, lint, test import) that does not alter product behavior, scope, public API, or security.
2. **Escalate to the captain immediately when**:
   - The choice changes user-visible behavior, architecture, schema, or scope.
   - The action is destructive, irreversible, or security-sensitive.
   - Multiple valid product directions exist.
3. Lead escalations with concrete evidence -> consequence -> options -> recommendation.
