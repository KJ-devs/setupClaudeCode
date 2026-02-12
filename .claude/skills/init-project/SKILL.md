---
name: init-project
description: Initialise un nouveau projet. Lit project.md, crée les issues GitHub avec leurs dépendances, configure les labels. Lance ce skill au démarrage de chaque projet.
user-invocable: true
allowed-tools: Read, Glob, Grep, Bash(gh *), Bash(bash scripts/*)
---

Tu initialises le projet. Suis ces étapes dans l'ordre :

## Contexte du projet
!`cat project.md 2>/dev/null || echo "ERREUR: project.md manquant. Crée-le d'abord."`

## Étapes d'initialisation

### 1. Valider project.md
- Vérifie que toutes les sections sont remplies (pas de placeholders)
- Vérifie que les US sont au bon format : `- [US-XX] Titre | Description | Priorité` ou `- [US-XX] Titre | Description | Priorité | Dépendances`
- Si des sections sont incomplètes, demande à l'utilisateur de les remplir

### 2. Analyser les dépendances entre US

**Avant de créer les issues, construis la carte des dépendances :**

1. Parse chaque US pour détecter les dépendances explicites (`après:US-XX`, `partage:US-XX`, `enrichit:US-XX`)
2. Analyse aussi les dépendances **implicites** :
   - Même scope dans l'équipe agentique → risque de fichiers partagés
   - US dont la description mentionne une autre US
   - US de priorité basse qui étend une US de priorité haute
3. Construis un graphe de dépendances et vérifie qu'il n'y a pas de **cycle** (US-01 → US-02 → US-01)
4. Détermine l'**ordre d'exécution optimal** :
   - D'abord les US sans dépendances (racines du graphe)
   - Puis les US dont toutes les dépendances sont satisfaites
   - Respecte la priorité (haute → moyenne → basse) à dépendances égales

Types de relations :
| Relation | Signification | Impact sur l'ordonnancement |
|----------|---------------|----------------------------|
| `après:US-XX` | Dépendance stricte | US-XX doit être Done avant de commencer |
| `partage:US-XX` | Mêmes fichiers/scope | Ne pas travailler en parallèle, traiter séquentiellement |
| `enrichit:US-XX` | Étend une feature | Si US-XX est en cours, peut commencer sur sa branche ; sinon attendre |

### 3. Créer les labels GitHub
```bash
gh label create "task" --description "US pas encore commencée" --color "0075ca" --force
gh label create "in-progress" --description "US en cours" --color "e4e669" --force
gh label create "done" --description "US terminée et stabilisée" --color "0e8a16" --force
gh label create "bug" --description "Bug détecté" --color "d73a4a" --force
gh label create "blocked" --description "US bloquée par une dépendance" --color "b60205" --force
gh label create "haute" --description "Priorité haute" --color "d93f0b" --force
gh label create "moyenne" --description "Priorité moyenne" --color "fbca04" --force
gh label create "basse" --description "Priorité basse" --color "c5def5" --force
```

### 4. Créer les issues GitHub

Pour chaque US dans project.md, crée une issue avec :
- Titre : `[US-XX] Titre`
- Labels : `task` + label de priorité
- Body structuré incluant les dépendances :

```markdown
## Description

[Description de la US]

## Dépendances

<!-- Si pas de dépendances : "Aucune — peut démarrer immédiatement" -->
- **Bloquée par** : #<numero-issue-US-YY> ([US-YY] Titre) — type: après
- **Partage le scope avec** : #<numero-issue-US-ZZ> ([US-ZZ] Titre) — type: partage
- **Enrichit** : #<numero-issue-US-WW> ([US-WW] Titre) — type: enrichit

## Ordre d'exécution

Position dans le graphe : X / N (peut démarrer après : US-YY, US-ZZ)

## Équipe agentique assignée

[agents]

## Priorité

[priorité]
```

**Important** : Crée les issues dans l'ordre topologique (les US sans dépendances d'abord) pour pouvoir référencer les numéros d'issues dans les dépendances.

### 5. Confirmer l'initialisation

Liste toutes les issues créées avec `gh issue list`.

Affiche un résumé structuré :
```
## Initialisation terminée

### US créées : X
- Haute priorité : X
- Moyenne priorité : X
- Basse priorité : X

### Graphe de dépendances
US-01 ──→ US-02 ──→ US-04
US-03 (indépendante)
US-05 ──→ US-06

### Ordre d'exécution recommandé
1. US-01 (haute, aucune dépendance)
2. US-03 (moyenne, aucune dépendance) — peut être parallélisée avec US-01
3. US-02 (haute, après US-01)
4. US-05 (moyenne, aucune dépendance)
5. US-04 (basse, après US-02)
6. US-06 (basse, après US-05)

### Prochaine US à traiter : US-01
```
