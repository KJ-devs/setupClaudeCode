# Workflow de travail

## Vue d'ensemble

```
[Initialisation] → [Feature Loop] → [Finalisation]
                        ↓
              ┌───────────────────────────┐
              │  1. Pick next US          │
              │  2. Assign team           │
              │  3. Create branch         │
              │  4. Move → In Prog        │
              │  5. Implement             │
              │  6. Stabilize             │
              │  7. Rebase + Push + PR    │
              │  8. Move → Done           │
              │  9. Clean context         │
              └───────────┬───────────────┘
                          ↓
                    [Next US or End]
```

## Stratégie Git : Rebase Only

**Règle fondamentale** : on utilise TOUJOURS `rebase` — JAMAIS `merge` pour intégrer les changements de `main` dans une branche feature.

Cela garantit :
- Un historique **linéaire et lisible**
- Des PR **propres** sans commits de merge parasites
- Un `git log` **compréhensible**
- Des **conflits détectés tôt** (au rebase, pas au merge)

## Détail de chaque étape

### 1. Pick next US

- Prends la prochaine US par priorité (haute → moyenne → basse)
- Lis la description complète de l'issue GitHub
- Comprends le scope et les critères d'acceptance

### 2. Assign team

- Consulte `project.md` > Équipe agentique par feature
- Charge les prompt patterns des agents depuis `team.md`
- L'ordre d'exécution des agents est important

### 3. Create branch

**Créer la branche feature depuis main à jour :**

```bash
# S'assurer que main est à jour
git checkout main
git pull --rebase origin main

# Créer et basculer sur la branche feature
git checkout -b type/scope/description-courte

# Push immédiat pour créer la branche sur le remote
git push -u origin type/scope/description-courte
```

**Important** : La branche DOIT exister sur GitHub dès le début pour que les autres puissent suivre l'avancement.

### 4. Move → In Progress

```bash
# Via GitHub CLI
gh issue edit <numero> --add-label "in-progress" --remove-label "task"
```

### 5. Implement

Chaque agent intervient dans l'ordre :

**Si architect est assigné :**
- Analyse la US
- Propose un plan d'implémentation
- Liste les fichiers à créer/modifier
- Identifie les risques

**developer (toujours) :**
- Implémente selon le plan (ou directement si pas d'architect)
- Commits atomiques avec messages clairs
- Respecte les conventions du projet
- **Rebase régulier** sur `main` pendant le développement :
  ```bash
  git fetch origin main
  git rebase origin/main
  ```
- Si le rebase produit des conflits, les résoudre puis `git rebase --continue`

**Si tester est assigné :**
- Écrit les tests après l'implémentation
- Lance les tests pour vérifier
- Corrige si des tests échouent

**Si reviewer est assigné :**
- Revue du code produit
- Signale les problèmes
- Le developer corrige si nécessaire

### 6. Stabilize

**stabilizer (toujours en dernier) :**

```bash
# Script de stabilité
bash scripts/stability-check.sh
```

Checks obligatoires :
- `npm run build` — Pas d'erreur de build
- `npm test` — Tous les tests passent
- `npm run lint` — Pas de warning lint
- Démarrage de l'app — Pas de crash

**Si un check échoue :**
1. Identifie le problème
2. Corrige
3. Relance TOUS les checks
4. Répète jusqu'à ce que tout passe

### 7. Rebase + Push + PR

**Après stabilisation, avant de créer/mettre à jour la PR :**

```bash
# 1. Rebase final sur main
git fetch origin main
git rebase origin/main

# 2. Re-lancer le stability check après rebase (obligatoire)
bash scripts/stability-check.sh

# 3. Push (force-with-lease car on a rebasé)
git push --force-with-lease origin type/scope/description-courte

# 4. Créer la PR (ou la mettre à jour si elle existe déjà)
gh pr create \
  --title "type(scope): description courte" \
  --body "## Summary
- Point 1
- Point 2

## Test plan
- [ ] Tests unitaires passent
- [ ] Tests d'intégration passent
- [ ] Stability check passe

## Stability
\`\`\`
Build:      ✓
Tests:      ✓
Lint:       ✓
Type check: ✓
→ STABLE
\`\`\`" \
  --base main
```

**Vérifications avant merge de la PR :**
- Le stability check passe
- Pas de conflits avec `main`
- La CI GitHub passe (si configurée)
- Le reviewer a approuvé (si assigné)

### 8. Move → Done

```bash
gh issue edit <numero> --add-label "done" --remove-label "in-progress"
gh issue close <numero>
```

### 9. Clean context

Entre chaque feature, nettoie le contexte :

1. **Résumé** — Écris un résumé de ce qui a été fait pour cette US
2. **Purge** — Libère le contexte des détails d'implémentation
3. **Vérification** — Confirme que le contexte est clean pour la prochaine US
4. **Retour sur main** — Se repositionner sur main à jour pour la prochaine feature

```bash
# Retour sur main à jour
git checkout main
git pull --rebase origin main
```

Format du résumé :
```
## US-XX — [Titre]
- **Branche** : type/scope/description
- **PR** : #numero (lien)
- **Fichiers modifiés** : liste des fichiers
- **Tests ajoutés** : liste des tests
- **Stability** : STABLE ✓
- **Points d'attention** : tout ce qu'il faut retenir
- **Status** : Done ✓
```

## Optimisation multi-US : Pipeline parallèle

Quand plusieurs US sont indépendantes (pas de dépendances entre elles), on peut optimiser le pipeline en parallélisant certaines étapes :

### Règles de parallélisation

```
US-01 (haute) ──[implement]──[stabilize]──[PR ready]──
                                                       ↘
US-02 (haute) ──────────[implement]──[stabilize]──[PR ready]──
                                                              ↘
US-03 (moyenne) ──────────────[implement]──[stabilize]──[PR ready]──
```

1. **Une seule US en implémentation active** — le developer travaille sur une US à la fois
2. **Les PR des US précédentes peuvent être en review** pendant que la suivante est en cours
3. **Le rebase se fait dans l'ordre** — chaque branche rebase sur main après que la PR précédente est mergée

### Quand paralléliser

- **OUI** : US indépendantes (scopes différents, pas de fichiers partagés)
- **NON** : US avec dépendances (US-02 dépend de US-01)
- **ATTENTION** : Si deux US modifient les mêmes fichiers, les traiter séquentiellement

### Gestion des dépendances inter-US

```bash
# Vérifier si la branche US-02 dépend de US-01 :
# Si oui, US-02 doit attendre que US-01 soit mergée dans main
# Si non, US-02 peut démarrer en parallèle sur sa propre branche
```

### Stratégie de rebase en cascade

Si plusieurs branches sont en cours :

```bash
# Après le merge de US-01 dans main :
git checkout main
git pull --rebase origin main

# Rebase US-02 sur le nouveau main
git checkout feat/scope/us-02
git rebase origin/main
bash scripts/stability-check.sh  # Re-vérifier la stabilité !
git push --force-with-lease origin feat/scope/us-02
```

## Gestion des labels GitHub

| Label | Signification |
|-------|--------------|
| `task` | US créée, pas encore commencée |
| `in-progress` | US en cours de développement |
| `done` | US terminée et stabilisée |
| `bug` | Bug détecté pendant le développement |
| `blocked` | US bloquée par une dépendance |

## Protection contre les merges cassés

### Avant tout merge de PR

1. **Rebase sur main** — la branche doit être à jour
2. **Stability check** — `bash scripts/stability-check.sh` doit passer
3. **Pas de conflits** — `gh pr view <numero> --json mergeable` doit retourner `MERGEABLE`
4. **CI verte** — si un workflow GitHub Actions est configuré
5. **Review approuvée** — si un reviewer est assigné

### Après un merge de PR

```bash
# Vérifier que main est toujours stable
git checkout main
git pull --rebase origin main
bash scripts/stability-check.sh
```

Si main est cassé après un merge → **priorité absolue** : corriger main avant toute autre US.

### Script de vérification pré-merge

```bash
bash scripts/pre-merge-check.sh <branch-name>
```

Ce script vérifie automatiquement toutes les conditions avant de valider un merge.

## Gestion des erreurs

- **Build échoue** → Le stabilizer doit corriger avant de continuer
- **Test échoue** → Le tester analyse et corrige
- **Régression détectée** → Stop tout, corrige la régression d'abord
- **US bloquée** → Crée une issue de type `blocked`, passe à la suivante, reviens plus tard
- **Conflit de rebase complexe** → `git rebase --abort`, demander à l'utilisateur, puis retenter
- **Main cassé après merge** → Priorité absolue, hotfix sur main immédiatement
