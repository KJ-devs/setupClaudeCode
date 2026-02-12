# Setup Claude Code

Template de démarrage de projet avec Claude Code.
Utilise les features officielles : **Skills**, **Hooks**, **Rules**, **MCP**, et **GitHub Actions**.

## Quick Start

```bash
# 1. Clone ce repo
git clone https://github.com/KJ-devs/setupClaudeCode.git

# 2. Copie le setup dans ton projet
bash setupClaudeCode/scripts/setup.sh ~/mon-projet

# 3. Remplis project.md
cd ~/mon-projet
# Édite project.md avec tes US, ta stack, tes critères de stabilité

# 4. Lance Claude Code
# Tape : /init-project
# Puis : /next-feature (pour chaque US)
```

## Ce que fait le setup

1. **Équipe agentique** via Skills — 5 agents spécialisés activables par `/architect`, `/developer`, `/tester`, `/reviewer`, `/stabilizer`
2. **Gestion des US sur GitHub** — Issues avec labels `task` / `in-progress` / `done`
3. **Stabilisation automatique** — Hook `Stop` qui vérifie que les checks ont été lancés
4. **Features une par une** — `/next-feature` dépile, implémente, stabilise, et nettoie le contexte
5. **Protection des fichiers sensibles** — Hook `PreToolUse` bloque l'édition de `.env`, lockfiles, `.git/`
6. **Réinjection de contexte** — Hook `SessionStart` réinjecte project.md après compaction
7. **Rules modulaires** — Règles de stabilité, commits, et code style activées par path

## Structure

```
├── CLAUDE.md                            # Instructions concises (imports project.md)
├── project.md                           # Contexte du projet (A REMPLIR)
├── CLAUDE.local.md                      # État de session local (gitignored)
├── .gitignore
├── .mcp.json                            # Config MCP servers (team-shared)
├── .claude/
│   ├── settings.json                    # Hooks + permissions
│   ├── skills/
│   │   ├── architect/SKILL.md           # /architect — planification
│   │   ├── developer/SKILL.md           # /developer — implémentation
│   │   ├── tester/SKILL.md              # /tester — tests
│   │   ├── reviewer/SKILL.md            # /reviewer — revue de code
│   │   ├── stabilizer/SKILL.md          # /stabilizer — build+tests+lint
│   │   ├── init-project/SKILL.md        # /init-project — bootstrap
│   │   └── next-feature/SKILL.md        # /next-feature — workflow complet
│   ├── hooks/
│   │   ├── protect-files.sh             # Bloque l'édition de fichiers sensibles
│   │   └── reinject-context.sh          # Réinjecte le contexte après compaction
│   ├── rules/
│   │   ├── stability.md                 # Règles de stabilité (path: src/**)
│   │   ├── commits.md                   # Conventions de commits
│   │   └── code-style.md               # Style de code
│   ├── team.md                          # Référence de l'équipe agentique
│   └── workflow.md                      # Détail du workflow séquentiel
├── scripts/
│   ├── setup.sh                         # Bootstrap dans un nouveau projet
│   ├── create-issues.sh                 # Crée les issues GitHub
│   └── stability-check.sh              # Check complet de stabilité
└── .github/
    ├── ISSUE_TEMPLATE/user-story.md     # Template d'issue US
    └── workflows/claude.yml             # CI: Claude Code sur @claude mentions
```

## Skills

| Skill | Rôle | Invocation |
|-------|------|-----------|
| **architect** | Analyse, planifie, découpe en sous-tâches | `/architect <description>` |
| **developer** | Implémente le code | `/developer <description>` |
| **tester** | Écrit et lance les tests | `/tester <description>` |
| **reviewer** | Revue qualité + sécurité (read-only) | `/reviewer <scope>` |
| **stabilizer** | Build + Tests + Lint + Type-check | `/stabilizer` |
| **init-project** | Crée les issues GitHub depuis project.md | `/init-project` |
| **next-feature** | Dépile la prochaine US avec le workflow complet | `/next-feature` |

## Hooks

| Hook | Event | Rôle |
|------|-------|------|
| **protect-files** | `PreToolUse` (Edit/Write) | Bloque `.env`, lockfiles, `.git/` |
| **reinject-context** | `SessionStart` (compact) | Réinjecte project.md + état des issues |
| **startup-banner** | `SessionStart` (startup) | Affiche les skills disponibles |
| **stability-reminder** | `Stop` | Rappelle de lancer /stabilizer si du code a changé |

## Workflow

```
/init-project
    │
    ▼
┌─────────────────────────────┐
│  /next-feature              │
│  1. Pick US (par priorité)  │
│  2. Assign team             │
│  3. → in-progress           │
│  4. architect (si assigné)  │
│  5. developer               │
│  6. tester (si assigné)     │
│  7. reviewer (si assigné)   │
│  8. stabilizer              │
│  9. → done                  │
│  10. /compact (clean ctx)   │
└──────────────┬──────────────┘
               │
               ▼
         [Next US or End]
```

## Configuration avancée

### Ajouter un MCP server

Édite `.mcp.json` pour partager avec l'équipe :

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

### Ajouter une règle path-specific

Crée un fichier dans `.claude/rules/` :

```markdown
---
paths:
  - "src/api/**/*.ts"
---
# Règles API
- Tous les endpoints doivent valider les inputs
```

### Personnaliser le workflow

Édite `CLAUDE.local.md` (gitignored) pour tes préférences locales.
