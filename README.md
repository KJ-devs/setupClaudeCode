# Setup Claude Code

Project starter template for Claude Code.
Uses official features: **Skills**, **Hooks**, **Rules**, **MCP**, and **GitHub Actions**.

## Quick Start

```bash
# 1. Clone this repo
git clone https://github.com/KJ-devs/setupClaudeCode.git

# 2. Copy the setup into your project
bash setupClaudeCode/scripts/setup.sh ~/my-project

# 3. Fill in project.md
cd ~/my-project
# Edit project.md with your user stories, stack, and stability criteria

# 4. Launch Claude Code
# Type: /init-project
# Then: /forge (for each user story)
```

## What the setup does

1. **Agentic team via Skills** — `/forge` as Team Lead orchestrating specialized agents (`/architect`, `/developer`, `/tester`, `/reviewer`, `/stabilizer`)
2. **User story management on GitHub** — Issues with `task` / `in-progress` / `done` labels + dependency graph
3. **TDD/BDD methodology** — Tests written before code (Red → Green → Refactor), BDD Given-When-Then naming
4. **Automatic stabilization** — `Stop` hook that verifies checks have been run
5. **One feature at a time** — `/forge` picks, decomposes, delegates, feedback loops, stabilizes, and clears the context
6. **Sensitive file protection** — `PreToolUse` hook blocks editing of `.env`, lockfiles, `.git/`
7. **Context re-injection** — `SessionStart` hook re-injects project.md after compaction
8. **Modular rules** — Stability, commit, branch, code style, and TDD/BDD rules activated by path
9. **US eligibility check** — Dependency guard preventing out-of-order feature starts

## Structure

```
├── CLAUDE.md                            # Concise instructions (imports project.md)
├── project.md                           # Project context (TO BE FILLED IN)
├── CLAUDE.local.md                      # Local session state (gitignored)
├── .gitignore
├── .mcp.json                            # MCP server config (team-shared)
├── .claude/
│   ├── settings.json                    # Hooks + permissions
│   ├── skills/
│   │   ├── forge/SKILL.md               # /forge — Team Lead orchestrator
│   │   ├── architect/SKILL.md           # /architect — planning
│   │   ├── developer/SKILL.md           # /developer — implementation
│   │   ├── tester/SKILL.md              # /tester — tests (TDD Red/Green)
│   │   ├── reviewer/SKILL.md            # /reviewer — code review
│   │   ├── stabilizer/SKILL.md          # /stabilizer — build+tests+lint
│   │   ├── init-project/SKILL.md        # /init-project — bootstrap
│   │   └── next-feature/SKILL.md        # /next-feature — linear workflow (simple features)
│   ├── hooks/
│   │   ├── protect-files.sh             # Blocks editing of sensitive files
│   │   └── reinject-context.sh          # Re-injects context after compaction
│   ├── rules/
│   │   ├── stability.md                 # Stability rules (path: src/**)
│   │   ├── commits.md                   # Commit conventions
│   │   ├── branches.md                  # Branch naming + Git rebase strategy
│   │   ├── code-style.md                # Code style
│   │   └── tdd-bdd.md                   # TDD/BDD methodology (path: src/**)
│   ├── team.md                          # Agentic team reference
│   └── workflow.md                      # Sequential workflow details
├── scripts/
│   ├── setup.sh                         # Bootstrap into a new project
│   ├── create-issues.sh                 # Creates GitHub issues
│   ├── stability-check.sh               # Full stability check
│   ├── pre-merge-check.sh               # Pre-merge verification
│   ├── check-us-eligibility.sh          # Dependency guard for US ordering
│   ├── search-skills.sh                 # Search community skills
│   └── install-skill.sh                 # Install a skill from GitHub
└── .github/
    ├── ISSUE_TEMPLATE/user-story.md     # User story issue template
    └── workflows/claude.yml             # CI: Claude Code on @claude mentions
```

## Skills

| Skill | Role | Invocation |
|-------|------|-----------|
| **forge** | Team Lead: decomposes US, delegates to agents, feedback loops, delivers stable | `/forge` or `/forge <issue-number>` |
| **architect** | Analyzes, plans, breaks down into sub-tasks | `/architect <description>` |
| **developer** | Implements the code | `/developer <description>` |
| **tester** | Writes tests (RED phase) and verifies passage (GREEN phase) | `/tester <description>` |
| **reviewer** | Quality + security review (read-only) | `/reviewer <scope>` |
| **stabilizer** | Build + Tests + Lint + Type-check | `/stabilizer` |
| **init-project** | Creates GitHub issues and generates agents from project.md | `/init-project` |
| **next-feature** | Linear pipeline for simple features (alternative to /forge) | `/next-feature` |

## Rules

| Rule file | Scope | Purpose |
|-----------|-------|---------|
| `commits.md` | always | Conventional commits format |
| `branches.md` | always | Branch naming + rebase-only Git strategy |
| `code-style.md` | always | TypeScript style, no `any`, no console.log |
| `stability.md` | `src/**` | Stability checks before push |
| `tdd-bdd.md` | `src/**`, `tests/**` | TDD Red→Green→Refactor, BDD Given-When-Then |

## Hooks

| Hook | Event | Role |
|------|-------|------|
| **protect-files** | `PreToolUse` (Edit/Write) | Blocks `.env`, lockfiles, `.git/` |
| **reinject-context** | `SessionStart` (compact) | Re-injects project.md + issue state |
| **startup-banner** | `SessionStart` (startup) | Displays available skills |
| **stability-reminder** | `Stop` | Reminds to run /stabilizer if code has changed |

## Workflow

```
/init-project
    │
    ▼
┌──────────────────────────────────────────────┐
│  /forge [issue-number]                       │
│                                              │
│  Phase 0 — Select eligible US                │
│  Phase 1 — Analyze + decompose (Team Lead)   │
│  Phase 2 — Git setup (branch + push)         │
│  Phase 3 — Execute pipeline:                 │
│    [architect]   Plan + design interfaces    │
│    [tester RED]  Write failing tests         │
│    [developer]   Implement → GREEN           │
│    [tester]      Verify all tests pass       │
│    [reviewer]    Quality + security review   │
│    [stabilizer]  Quality gate                │
│    (with feedback loops between agents)      │
│  Phase 4 — Rebase + PR                       │
│  Phase 5 — Close issue + compact context     │
└──────────────────┬───────────────────────────┘
                   │
                   ▼
            [Next US or End]
```

> `/next-feature` is available as a simpler linear alternative for straightforward features.

## TDD/BDD

All features follow **Red → Green → Refactor**:

- **RED** — Tester writes failing tests before any implementation
- **GREEN** — Developer writes the minimum code to pass the tests
- **REFACTOR** — Improve code without breaking tests

Tests use **BDD Given-When-Then** naming:
- Frontend: Playwright E2E (`Given [context], When [action], Then [result]`)
- Backend: Jest/Vitest unit + integration (`should [verb] [object] when [condition]`)

## Git Strategy

```
main ─────────────────────────────────────────────
  │                                        ↑
  └── feat/scope/feature ──── rebase ──── PR ── squash merge ── delete branch
```

- **Rebase only** — never `git merge` into a feature branch
- **Push** — `git push --force-with-lease origin <branch>`
- **PR** — `gh pr create --base main`

## Scripts

| Script | Purpose |
|--------|---------|
| `scripts/setup.sh` | Bootstrap setup into a new project |
| `scripts/stability-check.sh` | Full build + test + lint + type-check |
| `scripts/pre-merge-check.sh` | Pre-merge verification against main |
| `scripts/check-us-eligibility.sh <n>` | Check if a US's dependencies are satisfied |
| `scripts/check-us-eligibility.sh --list` | List all eligible US (dependencies met) |
| `scripts/create-issues.sh` | Create GitHub issues from project.md |
| `scripts/search-skills.sh --stack` | Search community skills |
| `scripts/install-skill.sh <owner/repo>` | Install a skill from GitHub |

## Advanced Configuration

### Adding an MCP server

Edit `.mcp.json` to share with your team:

```json
{
  "mcpServers": {
    "github": {
      "type": "http",
      "url": "https://api.githubcopilot.com/mcp",
      "headers": { "Authorization": "Bearer ${GITHUB_TOKEN}" }
    }
  }
}
```

### Adding a path-specific rule

Create a file in `.claude/rules/`:

```markdown
---
paths:
  - "src/api/**/*.ts"
---
# API Rules
- All endpoints must validate inputs
```

### Customizing the workflow

Edit `CLAUDE.local.md` (gitignored) for your local preferences.
