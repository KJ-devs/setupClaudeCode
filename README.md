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
# Then: /next-feature (for each user story)
```

## What the setup does

1. **Agentic team** via Skills — 5 specialized agents activatable via `/architect`, `/developer`, `/tester`, `/reviewer`, `/stabilizer`
2. **User story management on GitHub** — Issues with `task` / `in-progress` / `done` labels
3. **Automatic stabilization** — `Stop` hook that verifies checks have been run
4. **One feature at a time** — `/next-feature` picks, implements, stabilizes, and clears the context
5. **Sensitive file protection** — `PreToolUse` hook blocks editing of `.env`, lockfiles, `.git/`
6. **Context re-injection** — `SessionStart` hook re-injects project.md after compaction
7. **Modular rules** — Stability, commit, and code style rules activated by path

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
│   │   ├── architect/SKILL.md           # /architect — planning
│   │   ├── developer/SKILL.md           # /developer — implementation
│   │   ├── tester/SKILL.md              # /tester — tests
│   │   ├── reviewer/SKILL.md            # /reviewer — code review
│   │   ├── stabilizer/SKILL.md          # /stabilizer — build+tests+lint
│   │   ├── init-project/SKILL.md        # /init-project — bootstrap
│   │   └── next-feature/SKILL.md        # /next-feature — full workflow
│   ├── hooks/
│   │   ├── protect-files.sh             # Blocks editing of sensitive files
│   │   └── reinject-context.sh          # Re-injects context after compaction
│   ├── rules/
│   │   ├── stability.md                 # Stability rules (path: src/**)
│   │   ├── commits.md                   # Commit conventions
│   │   └── code-style.md               # Code style
│   ├── team.md                          # Agentic team reference
│   └── workflow.md                      # Sequential workflow details
├── scripts/
│   ├── setup.sh                         # Bootstrap into a new project
│   ├── create-issues.sh                 # Creates GitHub issues
│   └── stability-check.sh              # Full stability check
└── .github/
    ├── ISSUE_TEMPLATE/user-story.md     # User story issue template
    └── workflows/claude.yml             # CI: Claude Code on @claude mentions
```

## Skills

| Skill | Role | Invocation |
|-------|------|-----------|
| **architect** | Analyzes, plans, breaks down into sub-tasks | `/architect <description>` |
| **developer** | Implements the code | `/developer <description>` |
| **tester** | Writes and runs tests | `/tester <description>` |
| **reviewer** | Quality + security review (read-only) | `/reviewer <scope>` |
| **stabilizer** | Build + Tests + Lint + Type-check | `/stabilizer` |
| **init-project** | Creates GitHub issues from project.md | `/init-project` |
| **next-feature** | Picks the next user story with the full workflow | `/next-feature` |

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
┌─────────────────────────────────┐
│  /next-feature                  │
│  1. Pick user story (by prio.)  │
│  2. Assign team                 │
│  3. → in-progress               │
│  4. architect (if assigned)     │
│  5. developer                   │
│  6. tester (if assigned)        │
│  7. reviewer (if assigned)      │
│  8. stabilizer                  │
│  9. → done                      │
│  10. /compact (clean ctx)       │
└──────────────┬──────────────────┘
               │
               ▼
         [Next US or End]
```

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
