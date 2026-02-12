# Setup Claude Code

Template de démarrage de projet avec Claude Code.
Clone ce repo, copie le setup dans ton nouveau projet, remplis `project.md`, et lance Claude Code.

## Utilisation rapide

```bash
# 1. Clone ce repo
git clone https://github.com/KJ-devs/setupClaudeCode.git

# 2. Copie le setup dans ton projet
bash setupClaudeCode/scripts/setup.sh ~/mon-projet

# 3. Va dans ton projet et remplis project.md
cd ~/mon-projet
# Édite project.md avec tes US, ta stack, etc.

# 4. Lance Claude Code
# Dis-lui : "Lis CLAUDE.md et initialise le projet"
```

## Ce que fait le setup

1. **Crée ton équipe agentique** — 5 agents spécialisés (architect, developer, tester, reviewer, stabilizer)
2. **Crée tes US sur GitHub** — Issues avec labels task / in-progress / done
3. **Stabilise après chaque feature** — Build + Tests + Lint obligatoires
4. **Dépile les tasks une par une** — En nettoyant le contexte entre chaque
5. **Assigne la bonne équipe** — Chaque feature a ses agents dédiés

## Structure

```
├── CLAUDE.md              # Instructions pour Claude Code
├── project.md             # Contexte du projet (à remplir)
├── .claude/
│   ├── team.md            # Équipe agentique
│   └── workflow.md        # Workflow de travail
├── scripts/
│   ├── setup.sh           # Bootstrap dans un nouveau projet
│   ├── create-issues.sh   # Crée les issues GitHub
│   └── stability-check.sh # Check de stabilité
└── .github/
    └── ISSUE_TEMPLATE/
        └── user-story.md  # Template d'issue
```

## Les agents

| Agent | Rôle |
|-------|------|
| `architect` | Planification, design technique, découpage |
| `developer` | Implémentation du code |
| `tester` | Tests unitaires et d'intégration |
| `reviewer` | Revue de code et qualité |
| `stabilizer` | Build, tests, lint — validation finale |

## Le workflow

```
Pour chaque US (par priorité) :
  1. Assigner l'équipe → 2. In Progress → 3. Implémenter
  → 4. Stabiliser → 5. Done → 6. Clean context → Next
```
