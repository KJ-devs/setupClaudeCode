# Project Context

> **Ce fichier est le point d'entrée du projet.**
> Remplis les sections ci-dessous, puis lance `/init-project`.
> L'init analysera ton projet, enrichira les US, générera les agents et les règles.

## Nom du projet

<!-- Remplace par le nom de ton projet -->
`mon-projet`

## Description

<!-- Décris le projet en 2-5 phrases. Sois précis sur ce que l'app fait. -->
_Exemple : Application web de gestion de tâches avec authentification, dashboard et API REST. Les utilisateurs peuvent créer des projets, ajouter des tâches, assigner des membres, et voir un dashboard avec des stats de progression._

## Stack technique

<!-- Liste les technologies utilisées. Plus c'est précis, mieux c'est. -->
- **Langage** : TypeScript
- **Framework** : Next.js / Express / autre
- **Base de données** : PostgreSQL / MongoDB / autre
- **ORM** : Prisma / Drizzle / Mongoose / autre
- **Tests** : Jest / Vitest / Playwright / autre
- **Linter** : ESLint / Biome
- **UI** : Tailwind / Shadcn / MUI / autre
- **Auth** : NextAuth / Auth0 / Clerk / autre
- **CI/CD** : GitHub Actions

## Structure du repo

<!-- Décris la structure cible ou laisse /init-project la proposer -->
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

<!--
Décris tes features à haut niveau. Pas besoin d'être ultra-précis —
/init-project va brainstormer et enrichir chaque US avec :
  - Critères d'acceptance détaillés
  - Sous-tâches techniques
  - Dépendances détectées automatiquement

Format : - [US-XX] Titre | Description | Priorité (haute/moyenne/basse) | Dépendances (optionnel)

Les dépendances sont optionnelles. Si tu ne les mets pas, /init-project les détectera.
Types de dépendances :
  - après:US-XX    → dépendance stricte (ne peut pas commencer sans)
  - partage:US-XX  → mêmes fichiers (traiter séquentiellement)
  - enrichit:US-XX → étend une feature existante
-->

- [US-01] Titre de la feature | Description courte | haute
- [US-02] Titre de la feature | Description courte | moyenne | après:US-01
- [US-03] Titre de la feature | Description courte | basse

## Notes supplémentaires

<!-- Toute info utile : contraintes, décisions d'architecture, intégrations externes, etc. -->
_Ajoute ici des contraintes, des dépendances externes, des décisions d'architecture, etc._

---

<!-- ═══════════════════════════════════════════════════════════════
  LES SECTIONS CI-DESSOUS SONT AUTO-GÉNÉRÉES PAR /init-project
  Ne les remplis pas manuellement.
═══════════════════════════════════════════════════════════════ -->

## Carte des dépendances

<!-- Auto-générée par /init-project -->

## Équipe agentique par feature

<!-- Auto-générée par /init-project -->
