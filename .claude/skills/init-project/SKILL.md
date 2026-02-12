---
name: init-project
description: Initialise un nouveau projet. Lit project.md, crée les issues GitHub, configure les labels. Lance ce skill au démarrage de chaque projet.
user-invocable: true
allowed-tools: Read, Glob, Grep, Bash(gh *), Bash(bash scripts/*)
---

Tu initialises le projet. Suis ces étapes dans l'ordre :

## Contexte du projet
!`cat project.md 2>/dev/null || echo "ERREUR: project.md manquant. Crée-le d'abord."`

## Étapes d'initialisation

### 1. Valider project.md
- Vérifie que toutes les sections sont remplies (pas de placeholders)
- Vérifie que les US sont au bon format : `- [US-XX] Titre | Description | Priorité`
- Si des sections sont incomplètes, demande à l'utilisateur de les remplir

### 2. Créer les labels GitHub
```bash
gh label create "task" --description "US pas encore commencée" --color "0075ca" --force
gh label create "in-progress" --description "US en cours" --color "e4e669" --force
gh label create "done" --description "US terminée et stabilisée" --color "0e8a16" --force
gh label create "bug" --description "Bug détecté" --color "d73a4a" --force
gh label create "blocked" --description "US bloquée" --color "b60205" --force
gh label create "haute" --description "Priorité haute" --color "d93f0b" --force
gh label create "moyenne" --description "Priorité moyenne" --color "fbca04" --force
gh label create "basse" --description "Priorité basse" --color "c5def5" --force
```

### 3. Créer les issues GitHub
Pour chaque US dans project.md, crée une issue avec :
- Titre : `[US-XX] Titre`
- Body : Description + équipe agentique assignée + priorité
- Labels : `task` + label de priorité

### 4. Confirmer l'initialisation
Liste toutes les issues créées avec `gh issue list`.
Affiche un résumé : nombre d'US, répartition par priorité, prochaine US à traiter.
