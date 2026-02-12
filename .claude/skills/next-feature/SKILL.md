---
name: next-feature
description: Prends la prochaine US et exécute le workflow complet (assign team → implement → stabilize → done → clean context). Utilise ce skill pour dépiler les features une par une.
user-invocable: true
---

Tu dépiles la prochaine feature. Suis le workflow séquentiel.

## État actuel
!`gh issue list --label "task" --json number,title,labels --jq '.[] | "[#\(.number)] \(.title) [\(.labels | map(.name) | join(", "))]"' 2>/dev/null || echo "Impossible de lister les issues"`
!`gh issue list --label "in-progress" --json number,title --jq '.[] | "[#\(.number)] \(.title) — EN COURS"' 2>/dev/null || echo ""`

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

### 2. Démarrer la feature
```bash
gh issue edit <numero> --add-label "in-progress" --remove-label "task"
```

### 3. Identifier l'équipe
- Lis le body de l'issue pour trouver l'équipe assignée
- Exécute chaque agent dans l'ordre défini

### 4. Exécuter le pipeline d'agents

**Si architect assigné :**
- Analyse la US, propose un plan d'implémentation
- Liste les fichiers à créer/modifier

**developer (toujours) :**
- Implémente selon le plan
- Commits atomiques

**Si tester assigné :**
- Écris et lance les tests
- Corrige si des tests échouent

**Si reviewer assigné :**
- Revue de code
- Corrections si nécessaire

**stabilizer (toujours) :**
- Build + Tests + Lint + Type check
- Corrige jusqu'à ce que tout passe

### 5. Terminer la feature
```bash
gh issue edit <numero> --add-label "done" --remove-label "in-progress"
gh issue close <numero>
```

### 6. Résumé de la feature
Affiche un résumé structuré :
```
## US-XX — [Titre] ✓
- Fichiers modifiés : [liste]
- Tests ajoutés : [liste]
- Points d'attention : [notes]
```

### 7. Nettoyer le contexte
Utilise `/compact` avec ce résumé pour nettoyer le contexte avant la prochaine feature.
