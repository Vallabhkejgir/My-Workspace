# Firstmate Agentic Workspace — Architecture, Tools, Skills & Workflow Report

**Workspace Root:** `<workspace-root>` (e.g., `Vallabh/`)  
**Platform:** Windows 11 + VS Code Native Integration  
**Primary Agent Harness:** Claude Code (VS Code Extension & CLI)  
**Architecture Lineage:** Adapted from [`kunchenguid/firstmate`](https://github.com/kunchenguid/firstmate) for native Windows + VS Code execution  

---

## 1. Executive Overview

This workspace is a **Windows-native Firstmate Agent Distro** integrated directly into Visual Studio Code. Instead of juggling multiple terminal tabs and manually copy-pasting context across repositories, you interact with a single coordinating agent (**Firstmate**, the first mate) as the **Captain**.

Firstmate acts as the command layer over all repositories inside `Github/`:
- **Strict Separation of Command and Execution (Rule 1):** Firstmate is strictly read-only over project repositories in `Github/<project>`. Every code change, bug fix, feature, or deep investigation is delegated to an autonomous **crewmate** (a native Claude Code background subagent) running inside an isolated disposable Git worktree (`Github/.worktrees/<task-id>`).
- **Zero-Token Event-Driven Supervision:** Crewmates execute in background subagents and automatically wake Firstmate upon completion or when a decision gate is reached.
- **Pre-Push AI Validation & CI/CD (`no-mistakes`):** Ship tasks validate changes through `no-mistakes` (`review -> test -> docs -> lint -> push -> PR -> CI`) in an isolated worktree before code ever reaches a pull request.
- **Durable State Across Restarts:** All task queues (`tasks-axi`), project postures (`data/projects.md`), task briefs (`data/<id>/brief.md`), and investigation reports (`data/<id>/report.md`) live on disk rather than ephemeral chat memory.

---

## 2. Directory & Operational Layout

```text
Vallabh/
├── CLAUDE.md                  # Pointer (@AGENTS.md) auto-loaded by Claude Code on startup
├── AGENTS.md                  # Supervisor contract, prime directives, and lifecycle rules
├── workspace.md               # This comprehensive workspace architecture & workflow report
├── Vallabh.code-workspace     # VS Code Multi-Root Workspace (Firstmate + Github Projects)
├── .tasks.toml                # tasks-axi configuration (points to data/backlog.md)
├── .gitignore                 # Guards private operational state, credentials, and project clones
├── .vscode/
│   └── settings.json          # VS Code Git repository auto-detection & terminal PATH settings
├── .claude/
│   └── skills/                # User-invocable slash skills & internal agent reference skills
│       ├── ahoy/              # /ahoy — Session recap & open decision walkthrough
│       ├── bearings/          # /bearings — 4-section fleet status digest (+ optional PRs/file)
│       ├── stow/              # /stow — Knowledge sweep, memory curation & backlog persistence
│       ├── afk/               # /afk — Away-mode supervision posture
│       ├── quiet/             # /quiet — Quiet-mode notification batching posture
│       ├── lavish/            # /lavish — Interactive HTML visual review boards & diagrams
│       ├── project-management/# Internal skill: adding, cloning, creating, initializing repos
│       ├── validation-supervision/ # Internal skill: driving no-mistakes validation & CI workflows
│       ├── ship-landing/      # Internal skill: PR/branch landing & merge authority checks
│       ├── scout-completion/  # Internal skill: verifying scout reports & decision holds
│       ├── diagnostic-reasoning/   # Internal skill: evidence-first bug scoping
│       ├── ask-user-authority/     # Internal skill: adjudicating vs. escalating worker questions
│       ├── captain-hold-lifecycle/ # Internal skill: holding & resolving captain decisions
│       └── operational-home-layout/# Internal skill: path and file ownership reference
├── bin/                       # Windows PowerShell operational toolbelt
│   ├── fm-session-start.ps1   # Generates the Session Start digest (toolchain, repos, worktrees, backlog)
│   ├── fm-project-mode.ps1    # Resolves a project's registered delivery mode, +yolo, and branch prefix
│   ├── fm-brief.ps1           # Scaffolds data/<task-id>/brief.md for ship or scout tasks
│   ├── fm-worktree.ps1        # Creates & verifies isolated git worktrees at Github/.worktrees/<task-id>
│   ├── fm-merge-local.ps1     # Guarded fast-forward merge for approved local-only ship tasks
│   ├── fm-teardown.ps1        # Verifies landed work before removing a worktree & closing the task
│   └── fm-fleet-sync.ps1      # Safely fast-forwards clean clones in Github/ and prunes merged branches
├── config/                    # Local operating overrides (gitignored)
├── data/                      # Durable private fleet records (gitignored)
│   ├── projects.md            # Project registry (delivery mode, +yolo, branch prefix)
│   ├── backlog.md             # Durable task queue managed by tasks-axi
│   ├── done-archive.md        # Cold archive of completed tasks managed by tasks-axi
│   ├── captain.md             # Captain preferences & working style
│   ├── learnings.md           # Curated fleet-local operational facts
│   └── <task-id>/
│       ├── brief.md           # Per-task crewmate contract (Captain's intent & Firstmate spec)
│       └── report.md          # Standalone investigation report for scout tasks
├── state/                     # Runtime task metadata & status markers (gitignored)
└── Github/                    # Cloned project repositories (gitignored; read-only to Firstmate)
    └── .worktrees/            # Disposable per-task git worktrees (Github/.worktrees/<task-id>)
```

---

## 3. Installed Toolchain & Capabilities

### A. External Native CLI Tools (Windows 11)

| Tool | Version | Location | Purpose in Workspace |
| :--- | :--- | :--- | :--- |
| **`git`** | `2.45.1.windows.1` | `C:\Program Files\Git\cmd\git.exe` | Version control, `git worktree` isolation, and directory-scoped multi-account routing (`Vallabhkejgir` inside `Vallabh\`). |
| **`gh` (GitHub CLI)** | `2.102.0` | `C:\Program Files\GitHub CLI\gh.exe` | Creating repositories, opening/viewing/merging PRs, and inspecting GitHub Actions CI checks. |
| **`no-mistakes`** | `v1.84.0` | `~/.local/bin/no-mistakes.exe` | Local Git pre-push validation proxy (`review -> test -> docs -> lint -> push -> PR -> CI`) and `.github/workflows/ci.yml` generator (`no-mistakes ci-workflow`). |
| **`tasks-axi`** | `0.2.6` | Global npm (`tasks-axi`) | Token-efficient CLI backlog manager operating on `data/backlog.md` with dependency tracking (`block`/`unblock`), states (`queued`, `in_flight`, `done`), and captain holds (`hold --kind captain`). |
| **`lavish-axi`** | `0.1.83` | Global npm (`lavish-axi`) | Interactive local browser review surface for HTML plans, architecture diagrams, side-by-side comparisons, and editable Mermaid/Excalidraw whiteboards. |

### B. Claude Code Built-in Harness Tools

| Category | Tools | Role in Firstmate Operations |
| :--- | :--- | :--- |
| **Subagent Orchestration** | `Agent`, `SendMessage`, `ListAgents`, `Workflow` | Spawns autonomous crewmates (`ship` and `scout`) in isolated worktrees and steers them mid-flight. |
| **File & Code Inspection** | `Read`, `Write`, `Edit`, `NotebookEdit`, `Glob`, `Grep` | Allows Firstmate to read project files and maintain workspace state (`data/`, `bin/`, `AGENTS.md`), and allows crewmates to implement changes inside worktrees. |
| **Shell & Monitoring** | `PowerShell`, `Bash`, `Monitor`, `TaskStop` | Executes the `bin/fm-*.ps1` scripts, runs `tasks-axi`, `no-mistakes`, `lavish-axi`, and monitors background processes. |
| **VS Code IDE Bridge** | `mcp__ide__getDiagnostics`, `mcp__ide__executeCode` | Reads live compiler/linter diagnostics directly from VS Code and executes code in active Jupyter kernels. |
| **Planning & Isolation** | `EnterPlanMode`, `ExitPlanMode`, `EnterWorktree`, `ExitWorktree` | Interactive plan approval and worktree management. |
| **Interactive & Web** | `AskUserQuestion`, `WebSearch`, `WebFetch`, `Artifact`, `PushNotification` | Structured decision prompts, web documentation lookup, hosted artifacts, and desktop alerts. |

---

## 4. Skills Reference

### A. User-Invocable Slash Skills (Workspace & Global)

| Slash Command | Scope | What It Does |
| :--- | :--- | :--- |
| **`/ahoy`** | Firstmate | Recaps visible session events since your last message and walks through open decisions one at a time in impact order (falls back to `/bearings` on the first message of a session). |
| **`/bearings`** | Firstmate | Generates a 4-section fleet digest: **In flight**, **Waiting on you**, **Recently landed**, and **Queued**. Supports `/bearings file` (saves `data/status-report-YYYY-MM-DD.md`) and `/bearings include PRs` (live GitHub PR check). |
| **`/stow`** | Firstmate | Sweeps the session for uncaptured durable knowledge, updates `data/captain.md`, `data/learnings.md`, and `data/backlog.md` via `tasks-axi`, checks worktrees for cleanup, and confirms when the session is safe to reset. |
| **`/afk`** | Firstmate | Enters away-mode supervision (`state/.afk` = `away`). Crewmates continue working in the background while routine notifications are held until you return. |
| **`/quiet`** | Firstmate | Enters quiet mode (`state/.afk` = `quiet`) to batch non-urgent worker completions while you chat; disable with `/quiet off`. |
| **`/lavish`** | Firstmate | Authors and opens interactive HTML visual plans, comparisons, diagrams, or review boards in your browser using `lavish-axi`. |
| **`/code-review`** | Built-in | Reviews diffs, branches, or PRs for correctness bugs and code quality. |
| **`/simplify`** | Built-in | Reviews changed code for reuse, simplification, and efficiency cleanups. |
| **`/security-review`** | Built-in | Audits code and diffs for security vulnerabilities. |
| **`/run`** | Built-in | Launches and verifies an application (CLI, server, web app). |
| **`/dataviz`** | Built-in | Designs and builds accessible charts, plots, and dashboards. |

### B. Agent-Only Internal Reference Skills (`.claude/skills/`)

Loaded automatically by Firstmate at specific lifecycle triggers:
1. **`project-management`**: Triggered when adding, cloning, creating, initializing, or removing a repository under `Github/` and updating `data/projects.md`.
2. **`validation-supervision`**: Triggered when a `no-mistakes` ship task runs validation (`no-mistakes axi run` / `respond`) or generates CI workflows (`no-mistakes ci-workflow`).
3. **`ship-landing`**: Triggered when a ship worker reports a completed PR or local branch ready for merge review and worktree teardown.
4. **`scout-completion`**: Triggered when a scout worker completes `data/<task-id>/report.md` to verify findings, hold open captain decisions, and clean up the scratch worktree.
5. **`diagnostic-reasoning`**: Triggered before scoping a reported bug to ensure root-cause evidence precedes code changes.
6. **`ask-user-authority`**: Triggered when a worker or validation gate raises a question, determining whether Firstmate can answer from existing captain intent or must escalate to the captain.
7. **`captain-hold-lifecycle`**: Triggered when placing a task under a captain hold (`tasks-axi hold <id> --kind captain`) or recording the captain's resolution.
8. **`operational-home-layout`**: Reference map of all files and directories in the workspace.

---

## 5. End-to-End Operational Workflow

### Step 1: Session Start
At the start of a session, Firstmate runs `& ".\bin\fm-session-start.ps1"`, which outputs:
- Toolchain verification (`git`, `gh`, `no-mistakes`, `tasks-axi`, `lavish-axi`)
- Standing captain preferences (`data/captain.md`) and workspace learnings (`data/learnings.md`)
- Registered projects (`data/projects.md`) and cloned repos in `Github/`
- Active isolated worktrees (`Github/.worktrees/`)
- Live `tasks-axi` backlog summary (`in_flight`, `queued`, `held`, `done`)

### Step 2: Project Onboarding (`project-management`)
When you ask to work on a repository (e.g., *"Add my repo `AutoML`"* or *"Create a new project `my-api`"*):
1. Firstmate confirms the repository URL, local folder (`Github/<name>`), delivery posture (default `no-mistakes-prod-only` for remote repos, `local-only` for local repos), and merge autonomy (`yolo` off by default).
2. Clones or initializes the repo inside `Github/<name>`.
3. Registers the project in `data/projects.md`:
   ```markdown
   - AutoML [no-mistakes-prod-only] - Automated machine learning pipeline (added 2026-10-06)
   ```
4. For `no-mistakes` or `no-mistakes-prod-only` projects, runs `no-mistakes init && no-mistakes doctor` inside `Github/<name>`.

### Step 3: Task Intake & Classification
When you give an instruction (e.g., *"Fix the authentication timeout in X and investigate the memory usage in Y"*):
1. Firstmate classifies each item into one of two shapes:
   - **`ship`**: Authorized code change delivered via the project's delivery mode (`no-mistakes`, `direct-PR`, or `local-only`).
   - **`scout`**: Read-only investigation, audit, bug reproduction, or design plan delivered as `data/<task-id>/report.md`.
2. Firstmate files each task in `tasks-axi`:
   ```powershell
   tasks-axi add fix-auth-timeout "Fix authentication timeout" --kind ship --repo <project>
   ```

### Step 4: Brief Scaffolding & Worktree Isolation
1. Firstmate scaffolds the worker contract:
   ```powershell
   .\bin\fm-brief.ps1 -TaskId fix-auth-timeout -Project <project> -Kind ship -Mode no-mistakes -Yolo off -Intent "..." -Spec "..."
   ```
2. Firstmate creates the isolated Git worktree and transitions the task to `in_flight`:
   ```powershell
   .\bin\fm-worktree.ps1 -TaskId fix-auth-timeout -Project <project> -Kind ship -Mode no-mistakes
   ```
   This creates `Github/.worktrees/fix-auth-timeout` on branch `fm/fix-auth-timeout`, leaving `Github/<project>` untouched.

### Step 5: Autonomous Crewmate Execution & Validation
Firstmate spawns a native background `Agent` inside `Github/.worktrees/<task-id>`:
- **For `ship` (`no-mistakes` mode)**:
  - The crewmate implements and tests the change in the worktree, commits on `fm/<task-id>`, and runs `no-mistakes axi run --intent "..."`.
  - `no-mistakes` runs its automated review, test, docs, and lint gates in a disposable validation worktree, pushes the verified branch, opens the PR, and monitors CI.
- **For `ship` (`direct-PR` mode)**:
  - The crewmate implements, tests, commits, pushes `fm/<task-id>` to `origin`, and opens a PR via `gh pr create`.
- **For `ship` (`local-only` mode)**:
  - The crewmate implements, tests, and commits cleanly on local branch `fm/<task-id>` without pushing.
- **For `scout`**:
  - The crewmate investigates the codebase and writes a standalone evidence-backed report to `data/<task-id>/report.md`.

### Step 6: Landing, Merge Authority & Teardown
- **PR / Local Merge Review (`yolo=off` default)**: Firstmate presents the plain-English outcome, verification status, and full PR URL (or local diff summary) to you and waits for your explicit word (`"merge it"`).
- **Approved Local Merge**: Firstmate runs `.\bin\fm-merge-local.ps1 -TaskId <task-id>` to fast-forward `Github/<project>`.
- **Guarded Teardown**: Once landed (or once a scout report is verified), Firstmate runs:
  ```powershell
  .\bin\fm-teardown.ps1 -TaskId <task-id> [-PrUrl <url>]
  ```
  which verifies zero uncommitted/unlanded work, removes `Github/.worktrees/<task-id>`, and marks the task `done` in `tasks-axi`.

---

## 6. Prime Directives & Safety Boundaries

1. **Strict Rule 1 (No Direct Project Edits by Firstmate):** Firstmate never edits or commits inside `Github/<project>` directly unless you give an explicit, in-the-moment override for a specific operation.
2. **Explicit Merge Authority (Rule 2):** No PR or local branch is ever merged without your explicit instruction (unless `+yolo` is registered for that project and all checks are green).
3. **Zero Unlanded Work Loss (Rule 3):** `bin/fm-teardown.ps1` refuses to delete any worktree containing uncommitted files or unpushed/unmerged commits without explicit discard authorization.
4. **Single Point of Contact (Rule 4):** Crewmates never address you directly; Firstmate translates all internal worker mechanics into concise outcomes, consequences, and decisions.
5. **Privacy & Credential Isolation:** `.gitignore` excludes `.env`, `data/`, `state/`, `config/`, `Github/`, `.no-mistakes/`, `.lavish/`, and `.gitconfig-vallabh` so personal preferences, local project clones, and tokens are never committed to the workspace repository.
