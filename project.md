# Project Context

> **Ce fichier est le point d'entrée de chaque projet.**
> Remplis chaque section avant de lancer le setup.

## Nom du projet

<!-- Remplace par le nom de ton projet -->
`mon-projet`

## Description

<!-- Décris le projet en 2-3 phrases -->
_Exemple : Application web de gestion de tâches avec authentification, dashboard et API REST._

## Stack technique

<!-- Liste les technologies utilisées -->
- **Langage** : TypeScript
- **Framework** : Next.js / Express / autre
- **Base de données** : PostgreSQL / MongoDB / autre
- **Tests** : Jest / Vitest / autre
- **Linter** : ESLint
- **CI/CD** : GitHub Actions

## Structure du repo

<!-- Décris la structure cible du projet -->
```
src/
├── app/          # Routes / Pages
├── components/   # Composants UI
├── lib/          # Logique métier
├── services/     # Services externes / API
├── types/        # Types TypeScript
└── tests/        # Tests
```

## User Stories

<!-- Liste tes US ici. Le setup les créera en issues GitHub. -->
<!-- Format : - [US-XX] Titre | Description courte | Priorité (haute/moyenne/basse) -->

- [US-01] Titre de la feature | Description courte | haute
- [US-02] Titre de la feature | Description courte | moyenne
- [US-03] Titre de la feature | Description courte | basse

## Critères de stabilité

<!-- Définit ce que "stable" signifie pour ce projet -->
- [ ] Build passe sans erreur
- [ ] Tous les tests passent
- [ ] Pas de régressions sur les features précédentes
- [ ] Lint passe sans warning
- [ ] L'app démarre correctement

## Équipe agentique par feature

<!-- Associe chaque US à une équipe d'agents (voir .claude/team.md) -->
<!-- Format : US-XX → agent1, agent2, agent3 -->

| US | Agents assignés |
|----|-----------------|
| US-01 | architect, developer, tester, stabilizer |
| US-02 | developer, tester, stabilizer |
| US-03 | developer, reviewer, stabilizer |

## Notes supplémentaires

<!-- Toute info utile pour le contexte du projet -->
_Ajoute ici des contraintes, des dépendances externes, des décisions d'architecture, etc._
