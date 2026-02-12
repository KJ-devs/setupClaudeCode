---
name: next-feature
description: Prends la prochaine US et exécute le workflow complet (branch → assign team → implement → stabilize → PR → done → clean context). Utilise ce skill pour dépiler les features une par une.
user-invocable: true
---

Tu dépiles la prochaine feature. Suis le workflow séquentiel.

## État actuel
!`gh issue list --label "task" --json number,title,labels --jq '.[] | "[#\(.number)] \(.title) [\(.labels | map(.name) | join(", "))]"' 2>/dev/null || echo "Impossible de lister les issues"`
!`gh issue list --label "in-progress" --json number,title --jq '.[] | "[#\(.number)] \(.title) — EN COURS"' 2>/dev/null || echo ""`
!`git branch --show-current 2>/dev/null`

## Équipe agentique
@.claude/skills/architect/SKILL.md
@.claude/skills/developer/SKILL.md
@.claude/skills/tester/SKILL.md
@.claude/skills/reviewer/SKILL.md
@.claude/skills/stabilizer/SKILL.md

## Workflow pour la prochaine feature

### 1. Sélectionner la prochaine US
- Prends la première issue avec le label `task` (priorité haute d'abord)
- S'il y a une issue `in-progress`, reprends-la d'abord
- Vérifie les dépendances : si l'US dépend d'une autre US non terminée, prends la suivante

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

## Gestion multi-US : Optimisation du pipeline

Quand plusieurs US indépendantes se suivent :

1. **La PR de US-N peut être en attente de review** pendant que US-N+1 est en cours
2. **Après le merge de US-N**, rebase US-N+1 sur main et re-vérifier la stabilité
3. **Si deux US touchent les mêmes fichiers** → les traiter strictement en séquence
4. **Toujours vérifier main après un merge** :
   ```bash
   git checkout main
   git pull --rebase origin main
   bash scripts/stability-check.sh
   ```
