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
- **YOU MUST** utiliser `rebase` — JAMAIS `merge` pour intégrer les changements de `main`
- **YOU MUST** créer la branche sur GitHub dès le début (`git push -u origin <branch>`)
- **YOU MUST** créer une PR via `gh pr create` après stabilisation
- **YOU MUST** lancer `bash scripts/stability-check.sh` AVANT tout push
- **YOU MUST** re-lancer le stability check APRÈS chaque rebase
- **YOU MUST** vérifier l'éligibilité d'une US avant de la démarrer (`bash scripts/check-us-eligibility.sh <numero>`)
- **YOU MUST NOT** démarrer une US dont les dépendances ne sont pas satisfaites
- **YOU MUST NOT** merger une PR si le stability check échoue
- **YOU MUST NOT** utiliser `git push --force` — utilise `--force-with-lease` uniquement

## Skills disponibles

### Skills core (toujours présents)

| Skill | Usage |
|-------|-------|
| `/init-project` | **Setup automatique** : analyse le projet, brainstorm les US, génère agents + règles + issues |
| `/forge` | **Team Lead** : décompose une US, délègue aux agents spécialisés, feedback loops, livre stable |
| `/next-feature` | Pipeline linéaire simple (alternative à /forge pour les features simples) |
| `/reviewer` | Revue de code qualité + sécurité |
| `/stabilizer` | Vérifie build + tests + lint + type-check |

### Skills générés par /init-project (spécifiques au projet)

Les agents spécialisés sont **auto-générés** en fonction de la stack et des US.
Exemples : `/frontend-dev`, `/api-dev`, `/db-architect`, `/e2e-tester`...

Après `/init-project`, consulte `.claude/team.md` pour voir les agents disponibles.

### Skills fallback (génériques, utilisés si pas d'agents générés)

| Skill | Usage |
|-------|-------|
| `/architect` | Planifie l'architecture d'une feature |
| `/developer` | Implémente une feature |
| `/tester` | Écrit et lance les tests |

## Commandes

```bash
npm run build                      # Build
npm test                           # Tests
npm run lint                       # Lint
npx tsc --noEmit                   # Type check
bash scripts/stability-check.sh    # Check complet de stabilité
bash scripts/pre-merge-check.sh    # Vérification pré-merge d'une branche
bash scripts/check-us-eligibility.sh --list     # US éligibles (dépendances vérifiées)
bash scripts/check-us-eligibility.sh <numero>   # Vérifier une US spécifique
bash scripts/search-skills.sh --stack           # Chercher des skills communautaires
bash scripts/install-skill.sh <owner/repo>      # Installer un skill depuis GitHub
gh issue list                      # Voir les issues
gh pr list                         # Voir les PRs ouvertes
gh pr view <numero>                # Détail d'une PR
```

## Workflow

1. `/init-project` — Analyse le projet → brainstorm → génère agents + règles → crée les issues
2. `/forge` — Pour chaque US (par priorité) :
   analyse → décompose → délègue aux agents → feedback loops → stabilize → PR → done → clean context
3. Répète 2 jusqu'à ce que toutes les US soient done

> `/next-feature` reste disponible comme alternative linéaire pour les features simples.

## Stratégie Git

```
main ─────────────────────────────────────────────
  │                                        ↑
  └── feat/scope/feature ──── rebase ──── PR ── squash merge ── delete branch
```

- **Rebase only** : `git fetch origin main && git rebase origin/main`
- **Push** : `git push --force-with-lease origin <branch>`
- **PR** : `gh pr create --base main`
- **Après merge** : vérifier que main est stable
