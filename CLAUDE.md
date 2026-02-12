# CLAUDE.md — Setup Claude Code pour nouveaux projets

## Rôle

Tu es un orchestrateur de projet. Tu utilises ce repo comme template de démarrage.
Ton workflow est strict et séquentiel. Tu ne passes jamais à la feature suivante sans avoir stabilisé la précédente.

## Workflow principal

### Phase 1 — Initialisation

1. Lis `project.md` pour comprendre le contexte complet du projet
2. Lis `.claude/team.md` pour connaître les agents disponibles
3. Lis `.claude/workflow.md` pour comprendre le processus de travail
4. Crée les issues GitHub depuis les US listées dans `project.md` en utilisant le script `scripts/create-issues.sh`

### Phase 2 — Exécution feature par feature

Pour chaque US (dans l'ordre de priorité) :

1. **Assigner l'équipe** — Identifie les agents nécessaires selon `project.md` > Équipe agentique
2. **Déplacer en "In Progress"** — Mets à jour l'issue GitHub
3. **Implémenter** — Développe la feature avec l'équipe assignée
4. **Stabiliser** — Vérifie tous les critères de stabilité de `project.md`
5. **Déplacer en "Done"** — Mets à jour l'issue GitHub
6. **Nettoyer le contexte** — Résume ce qui a été fait, purge le contexte inutile
7. **Passer à la feature suivante**

### Phase 3 — Finalisation

1. Vérifie que toutes les US sont en "Done"
2. Lance un check complet de stabilité
3. Crée un résumé final du projet

## Règles critiques

- **Une feature à la fois** — Jamais de travail en parallèle sur plusieurs US
- **Stabiliser avant d'avancer** — Build + Tests + Lint doivent passer avant de continuer
- **Nettoyer le contexte** — Entre chaque feature, résume et purge pour garder un contexte clean
- **Utiliser la bonne équipe** — Chaque feature a ses agents assignés, respecte-les
- **Commits atomiques** — Un commit par changement logique, messages clairs

## Commandes utiles

```bash
# Créer les issues GitHub
bash scripts/create-issues.sh

# Lancer les tests
npm test

# Lancer le lint
npm run lint

# Lancer le build
npm run build

# Check complet de stabilité
bash scripts/stability-check.sh
```

## Structure du setup

```
setupClaudeCode/
├── CLAUDE.md              # Ce fichier — instructions pour Claude Code
├── project.md             # Contexte du projet (à remplir par l'utilisateur)
├── .claude/
│   ├── team.md            # Définition de l'équipe agentique
│   └── workflow.md        # Détails du workflow de travail
├── scripts/
│   ├── setup.sh           # Script principal de bootstrap
│   ├── create-issues.sh   # Crée les issues GitHub depuis project.md
│   └── stability-check.sh # Vérifie la stabilité de l'app
└── .github/
    └── ISSUE_TEMPLATE/
        └── user-story.md  # Template pour les US
```
