# Règles de branches

- **YOU MUST** nommer les branches avec le format : `type/scope/description-courte`
  - `feat/publicapi/add-pagination`
  - `fix/dashboard/chart-mobile-rendering`
  - `refactor/integrations/stripe-service`
  - `test/publicapi/auth-e2e`
- Le **scope** dans le nom de branche doit correspondre au scope des commits
- Description en kebab-case (mots séparés par des tirets)
- Pas de majuscules, pas d'espaces, pas de caractères spéciaux

# Stratégie Git : Rebase Only

- **YOU MUST** utiliser `rebase` au lieu de `merge` — historique linéaire obligatoire
- **YOU MUST NOT** utiliser `git merge` pour intégrer des changements de `main` dans une branche feature
- **YOU MUST** rebase ta branche feature sur `main` avant de créer/mettre à jour la PR

## Workflow rebase pour chaque feature

```bash
# 1. Créer la branche depuis main à jour
git checkout main
git pull --rebase origin main
git checkout -b type/scope/description-courte

# 2. Pendant le développement — garder la branche à jour
git fetch origin main
git rebase origin/main

# 3. Avant de push — toujours rebase sur main
git fetch origin main
git rebase origin/main
git push --force-with-lease origin type/scope/description-courte
```

## Résolution de conflits pendant le rebase

```bash
# Si des conflits apparaissent :
# 1. Résoudre les conflits dans les fichiers marqués
# 2. Ajouter les fichiers résolus
git add <fichiers-résolus>
# 3. Continuer le rebase
git rebase --continue
# 4. Si la situation est irrécupérable, annuler
git rebase --abort
```

## Règles strictes

- **JAMAIS** de `git merge main` dans une branche feature
- **JAMAIS** de `git push --force` — utilise `--force-with-lease` uniquement
- **JAMAIS** de rebase sur `main` directement (rebase seulement les branches feature)
- Si le rebase cause des conflits complexes, **demander à l'utilisateur** avant de continuer

# Cycle de vie d'une branche

```
main ─────────────────────────────────────────────
  │                                        ↑
  └── feat/scope/feature ──── rebase ──── PR ── squash merge ── delete branch
```

1. **Créer** la branche depuis `main` à jour
2. **Développer** avec des commits atomiques
3. **Rebase** sur `main` avant le push
4. **Push** la branche sur le remote (`git push -u origin <branch>`)
5. **Créer la PR** via `gh pr create`
6. **Vérifier** que la CI passe sur la PR
7. **Squash merge** via GitHub (PR merge) — pour un historique main propre
8. **Supprimer** la branche après merge

# Règles de Pull Requests

- **YOU MUST** nommer les PR avec le format : `type(scope): description courte`
  - Même format que les commits
  - Le titre de la PR résume l'ensemble des changements de la branche
- **YOU MUST** créer la PR sur GitHub avec `gh pr create` après le push
- **YOU MUST** vérifier que la CI passe avant de considérer la PR comme prête
- Exemples :
  - `feat(publicapi): add pagination to /users endpoint`
  - `fix(dashboard): correct chart rendering on mobile`
  - `refactor(integrations): extract Stripe client into service`
- Le body de la PR doit contenir :
  - `## Summary` — 1 à 3 bullet points décrivant les changements
  - `## Test plan` — checklist de vérification
  - `## Stability` — résultat du stability check (copier la sortie du script)
- Le scope de la PR doit correspondre au scope de la branche et des commits

# Protection contre les merges cassés

- **YOU MUST** lancer `bash scripts/stability-check.sh` AVANT de push
- **YOU MUST** vérifier que la PR n'a pas de conflits avec `main`
- **YOU MUST** re-lancer les tests après chaque rebase
- Si le stability check échoue, la PR ne doit PAS être mergée
- Après le merge de la PR, vérifier que `main` est toujours stable
