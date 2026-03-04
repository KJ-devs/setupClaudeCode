---
name: next-feature
description: Prends la prochaine US et exécute le workflow complet (branch → assign team → implement → stabilize → PR → done → clean context). Utilise ce skill pour dépiler les features une par une.
user-invocable: true
---

Tu dépiles la prochaine feature. Suis le workflow séquentiel.

## État actuel
!`gh issue list --label "in-progress" --json number,title --jq '.[] | "[#\(.number)] \(.title) — EN COURS"' 2>/dev/null || echo "Aucune US en cours"`
!`bash scripts/check-us-eligibility.sh --list 2>/dev/null || echo "Script check-us-eligibility.sh non trouvé"`
!`git branch --show-current 2>/dev/null`

## Équipe agentique
@.claude/skills/architect/SKILL.md
@.claude/skills/developer/SKILL.md
@.claude/skills/tester/SKILL.md
@.claude/skills/reviewer/SKILL.md
@.claude/skills/stabilizer/SKILL.md

## Workflow pour la prochaine feature

### 1. Sélectionner la prochaine US (sélection intelligente)

**Reprendre une US en cours :**
- S'il y a une issue `in-progress`, reprends-la d'abord

**Sinon, choisir la prochaine US éligible :**

**YOU MUST** lancer le script de vérification AVANT de prendre une US :

```bash
# Lister les US éligibles (triées par priorité, dépendances vérifiées automatiquement)
bash scripts/check-us-eligibility.sh --list
```

Le script vérifie automatiquement :
- `après:US-XX` → US-XX doit avoir le label `done`
- `partage:US-XX` → US-XX ne doit PAS être `in-progress`
- `enrichit:US-XX` → US-XX doit être au moins `in-progress`

Prends la **première US recommandée** par le script. Si le script dit "Aucune US disponible" → demande à l'utilisateur.

**Avant de démarrer, confirmer l'éligibilité de l'US choisie :**

```bash
# Vérification individuelle (exit code 0 = OK, 1 = bloquée)
bash scripts/check-us-eligibility.sh <numero-issue>
```

**YOU MUST NOT** démarrer une US si ce script retourne un code d'erreur (exit 1).

**Si une US est bloquée :**
```bash
# Marquer comme bloquée
gh issue edit <numero> --add-label "blocked"
# La reprendre automatiquement quand ses dépendances seront Done
```

### 2. Créer la branche feature

**YOU MUST créer la branche et la pousser sur le remote immédiatement :**

```bash
# S'assurer que main est à jour
git checkout main
git pull --rebase origin main

# Créer la branche feature (format: type/scope/description-courte)
git checkout -b type/scope/description-courte

# Pousser la branche sur le remote pour qu'elle existe sur GitHub
git push -u origin type/scope/description-courte
```

### 3. Démarrer la feature
```bash
gh issue edit <numero> --add-label "in-progress" --remove-label "task"
```

### 4. Identifier l'équipe
- Lis le body de l'issue pour trouver l'équipe assignée
- Exécute chaque agent dans l'ordre défini

### 5. Exécuter le pipeline d'agents

**Si architect assigné :**
- Analyse la US, propose un plan d'implémentation
- Liste les fichiers à créer/modifier

**developer (toujours) :**
- Implémente selon le plan
- Commits atomiques
- **Rebase régulier** sur main pendant le développement :
  ```bash
  git fetch origin main
  git rebase origin/main
  ```

**Si tester assigné :**
- Écris et lance les tests
- Corrige si des tests échouent

**Si reviewer assigné :**
- Revue de code
- Corrections si nécessaire

**stabilizer (toujours) :**
- Build + Tests + Lint + Type check
- Corrige jusqu'à ce que tout passe

### 6. Rebase final + Push + Créer la PR

**Après stabilisation, préparer la PR :**

```bash
# 1. Rebase final sur main
git fetch origin main
git rebase origin/main

# 2. Re-vérifier la stabilité après rebase
bash scripts/stability-check.sh

# 3. Push (force-with-lease car rebase)
git push --force-with-lease origin type/scope/description-courte

# 4. Créer la PR
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
Build:      ✓
Tests:      ✓
Lint:       ✓
Type check: ✓
→ STABLE

Closes #<numero>" \
  --base main
```

**Vérifier que la PR est propre :**
```bash
# Vérifier le statut de la PR
gh pr view --json title,state,mergeable,statusCheckRollup
```

### 7. Terminer la feature
```bash
gh issue edit <numero> --add-label "done" --remove-label "in-progress"
gh issue close <numero>
```

### 8. Résumé de la feature
Affiche un résumé structuré :
```
## US-XX — [Titre] ✓
- Branche : type/scope/description
- PR : #numero
- Fichiers modifiés : [liste]
- Tests ajoutés : [liste]
- Stability : STABLE ✓
- Points d'attention : [notes]
```

### 9. Nettoyer le contexte

```bash
# Retour sur main à jour
git checkout main
git pull --rebase origin main
```

Utilise `/compact` avec ce résumé pour nettoyer le contexte avant la prochaine feature.

## Gestion intelligente des US liées

### Comprendre les relations entre US

Avant de commencer une US, **lis toujours la section Dépendances** de l'issue GitHub. Les relations déterminent l'ordre de travail :

| Relation | Ce que ça veut dire | Quand commencer |
|----------|---------------------|-----------------|
| `après:US-XX` | Cette US a besoin du code de US-XX | Quand US-XX est **Done** (label `done`) |
| `partage:US-XX` | Mêmes fichiers modifiés | Quand US-XX n'est **PAS** en cours (`in-progress`) |
| `enrichit:US-XX` | Ajoute des fonctionnalités à US-XX | Quand US-XX est **Done** ou **en cours** |

### Sélection automatique : algorithme

```
POUR chaque US avec label "task" (triées par priorité puis par numéro) :
  LIRE le body de l'issue
  SI section "Dépendances" contient "Aucune" :
    → US éligible ✓
  SINON :
    POUR chaque dépendance :
      SI type = "après" ET US-dépendance n'a PAS label "done" :
        → US non éligible ✗ (skip)
      SI type = "partage" ET US-dépendance a label "in-progress" :
        → US non éligible ✗ (skip)
      SI type = "enrichit" ET US-dépendance a label "task" :
        → US non éligible ✗ (skip)
  PRENDRE la première US éligible
```

### Optimisation du pipeline multi-US

Quand plusieurs US indépendantes se suivent :

1. **La PR de US-N peut être en attente de review** pendant que US-N+1 est en cours
2. **Après le merge de US-N**, rebase US-N+1 sur main et re-vérifier la stabilité
3. **Si deux US ont `partage:` entre elles** → les traiter strictement en séquence
4. **Débloquer les US en cascade** : quand US-N passe en `done`, les US qui dépendent d'elle deviennent éligibles
5. **Toujours vérifier main après un merge** :
   ```bash
   git checkout main
   git pull --rebase origin main
   bash scripts/stability-check.sh
   ```

### Contexte partagé entre US liées

Quand une US `enrichit` ou est `après` une autre US :
- **Lis le résumé de l'US précédente** (dans le body de l'issue fermée ou dans CLAUDE.local.md)
- **Comprends ce qui a été construit** : quels fichiers, quelles interfaces, quelles conventions
- **Construis dessus** au lieu de réinventer — utilise les types, services et patterns déjà en place
- **Vérifie que les tests de l'US précédente passent toujours** après ton implémentation
