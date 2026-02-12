# Workflow de travail

## Vue d'ensemble

```
[Initialisation] → [Feature Loop] → [Finalisation]
                        ↓
              ┌─────────────────────┐
              │  1. Pick next US    │
              │  2. Assign team     │
              │  3. Move → In Prog  │
              │  4. Implement       │
              │  5. Stabilize       │
              │  6. Move → Done     │
              │  7. Clean context   │
              └─────────┬───────────┘
                        ↓
                  [Next US or End]
```

## Détail de chaque étape

### 1. Pick next US

- Prends la prochaine US par priorité (haute → moyenne → basse)
- Lis la description complète de l'issue GitHub
- Comprends le scope et les critères d'acceptance

### 2. Assign team

- Consulte `project.md` > Équipe agentique par feature
- Charge les prompt patterns des agents depuis `team.md`
- L'ordre d'exécution des agents est important

### 3. Move → In Progress

```bash
# Via GitHub CLI
gh issue edit <numero> --add-label "in-progress" --remove-label "task"
```

### 4. Implement

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

**Si tester est assigné :**
- Écrit les tests après l'implémentation
- Lance les tests pour vérifier
- Corrige si des tests échouent

**Si reviewer est assigné :**
- Revue du code produit
- Signale les problèmes
- Le developer corrige si nécessaire

### 5. Stabilize

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

### 6. Move → Done

```bash
gh issue edit <numero> --add-label "done" --remove-label "in-progress"
gh issue close <numero>
```

### 7. Clean context

Entre chaque feature, nettoie le contexte :

1. **Résumé** — Écris un résumé de ce qui a été fait pour cette US
2. **Purge** — Libère le contexte des détails d'implémentation
3. **Vérification** — Confirme que le contexte est clean pour la prochaine US

Format du résumé :
```
## US-XX — [Titre]
- **Fichiers modifiés** : liste des fichiers
- **Tests ajoutés** : liste des tests
- **Points d'attention** : tout ce qu'il faut retenir
- **Status** : Done ✓
```

## Gestion des labels GitHub

| Label | Signification |
|-------|--------------|
| `task` | US créée, pas encore commencée |
| `in-progress` | US en cours de développement |
| `done` | US terminée et stabilisée |
| `bug` | Bug détecté pendant le développement |
| `blocked` | US bloquée par une dépendance |

## Gestion des erreurs

- **Build échoue** → Le stabilizer doit corriger avant de continuer
- **Test échoue** → Le tester analyse et corrige
- **Régression détectée** → Stop tout, corrige la régression d'abord
- **US bloquée** → Crée une issue de type `blocked`, passe à la suivante, reviens plus tard
