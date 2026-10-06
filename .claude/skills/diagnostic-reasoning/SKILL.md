---
name: diagnostic-reasoning
description: Load before scoping a reported bug and before acting on a diagnostic report.
user-invocable: false
---

# diagnostic-reasoning

1. **Evidence is not authorization**: A bug report, diagnosis, or recommendation is evidence, not automatic authorization to rewrite code unless the captain asked for a fix.
2. **Reproduce or trace first**: Ensure the root cause is backed by file/line evidence or reproduction steps rather than guessing from symptoms.
3. **Scope tightly**: Fix the verified defect without bundling unrelated refactors or speculative hardening.
