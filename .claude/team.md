# Équipe Agentique

> Ce fichier est **auto-généré** par `/init-project` en Phase 5.
> Il documente les agents du projet. Ne le modifie pas manuellement.

## Agents core (toujours présents)

### `forge`
**Rôle** : Team Lead — orchestre les agents, décompose les US, gère les feedback loops
**Toujours présent** : oui (c'est l'orchestrateur principal)

### `stabilizer`
**Rôle** : Quality gate — build, tests, lint, type-check
**Toujours présent** : oui (toujours en dernier dans le pipeline)
**Responsabilités** :
- Lancer les checks de stabilité (`bash scripts/stability-check.sh`)
- Corriger les problèmes simples directement
- Renvoyer les problèmes complexes à l'agent dev concerné

### `reviewer`
**Rôle** : Revue de code qualité + sécurité
**Quand l'utiliser** : US de priorité haute ou touchant un domaine critique (auth, payment)
**Responsabilités** :
- Vérifier le respect des règles du projet (`.claude/rules/`)
- Détecter les vulnérabilités (OWASP Top 10)
- Produire un rapport structuré : critiques + suggestions

---

## Agents spécialisés (générés par /init-project)

> Les agents ci-dessous sont créés automatiquement en fonction de la stack et des US du projet.
> Chaque agent est un expert de son domaine dans la stack spécifique du projet.

<!-- /init-project remplacera cette section avec les agents générés -->

_Pas encore initialisé. Lance `/init-project` pour générer les agents spécialisés._

---

## Règles d'équipe

1. Le **stabilizer** intervient TOUJOURS en dernier
2. Les agents de planification (architect, db-architect) interviennent TOUJOURS en premier
3. Au moins un agent de développement (*-dev) est TOUJOURS présent
4. L'ordre d'exécution suit l'ordre défini dans le body de l'issue GitHub
5. Le **forge** évalue le résultat de chaque agent avant de passer au suivant

## Types d'agents

| Catégorie | Pattern de nom | Rôle |
|-----------|---------------|------|
| Planification | `*-architect`, `architect` | Analyse et plan avant implémentation |
| Développement | `*-dev`, `fullstack-dev` | Implémentation du code |
| Test | `*-tester`, `unit-tester`, `e2e-tester` | Écriture et exécution des tests |
| Qualité | `reviewer` | Revue de code |
| Validation | `stabilizer` | Quality gate finale |

## Orchestration : `/forge` vs `/next-feature`

| | `/next-feature` | `/forge` |
|---|---|---|
| **Modèle** | Pipeline linéaire | Team Lead avec feedback loops |
| **Agents** | Agents génériques | Agents spécialisés du projet |
| **Feedback** | Aucun | Boucles dev↔test, dev↔reviewer, stabilizer retry |
| **Décision** | Ordre fixe | Team Lead adapte selon les résultats |
| **Usage** | Features simples | Recommandé par défaut |
