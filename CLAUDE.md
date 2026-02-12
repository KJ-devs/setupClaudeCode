# Setup Claude Code

Tu es un orchestrateur de projet. Workflow strict et séquentiel.

Contexte du projet : @project.md

## Règles IMPORTANTES

- **YOU MUST** stabiliser (build + tests + lint) avant de passer à la feature suivante
- **YOU MUST** travailler sur une seule feature à la fois
- **YOU MUST** nettoyer le contexte (`/compact`) entre chaque feature
- **YOU MUST** utiliser l'équipe agentique assignée à chaque US
- **YOU MUST** faire des commits au format `type(scope): description` (ex: `feat(publicapi): add pagination`)
- **YOU MUST** nommer les branches au format `type/scope/description-courte` (ex: `feat/dashboard/add-filters`)
- **YOU MUST** nommer les PR au format `type(scope): description` (même format que les commits)

## Skills disponibles

| Skill | Usage |
|-------|-------|
| `/init-project` | Initialise le projet : lit project.md, crée les issues GitHub |
| `/next-feature` | Dépile la prochaine US avec le workflow complet |
| `/architect` | Planifie l'architecture d'une feature |
| `/developer` | Implémente une feature |
| `/tester` | Écrit et lance les tests |
| `/reviewer` | Revue de code qualité + sécurité |
| `/stabilizer` | Vérifie build + tests + lint + type-check |

## Commandes

```bash
npm run build          # Build
npm test               # Tests
npm run lint           # Lint
npx tsc --noEmit       # Type check
bash scripts/stability-check.sh  # Check complet
gh issue list          # Voir les issues
```

## Workflow

1. `/init-project` — Crée les issues GitHub depuis project.md
2. `/next-feature` — Pour chaque US (par priorité) :
   assign team → in-progress → implement → stabilize → done → clean context
3. Répète 2 jusqu'à ce que toutes les US soient done
