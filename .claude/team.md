# Équipe Agentique

Chaque agent a un rôle précis. On les active selon la feature en cours.

## Agents disponibles

### `architect`
**Rôle** : Planification et design technique
**Quand l'utiliser** : Nouvelles features complexes, refactoring majeur, décisions d'architecture
**Responsabilités** :
- Analyser les requirements de la US
- Proposer une architecture / un plan d'implémentation
- Identifier les dépendances et risques
- Découper en sous-tâches techniques

**Prompt pattern** :
> Tu es l'architecte du projet. Analyse la US suivante et propose un plan d'implémentation détaillé avec les fichiers à créer/modifier, les dépendances, et les risques identifiés.

---

### `developer`
**Rôle** : Implémentation du code
**Quand l'utiliser** : Toujours — c'est l'agent principal de développement
**Responsabilités** :
- Écrire le code propre et fonctionnel
- Respecter les conventions du projet
- Créer les types, interfaces et modèles
- Implémenter la logique métier

**Prompt pattern** :
> Tu es le développeur principal. Implémente la feature suivante en respectant la stack et les conventions du projet. Écris du code propre, typé, et testé.

---

### `tester`
**Rôle** : Écriture et exécution des tests
**Quand l'utiliser** : Après chaque implémentation, pour les features critiques
**Responsabilités** :
- Écrire les tests unitaires
- Écrire les tests d'intégration si nécessaire
- Vérifier la couverture de test
- Identifier les cas limites

**Prompt pattern** :
> Tu es le testeur du projet. Écris les tests pour la feature qui vient d'être implémentée. Couvre les cas nominaux, les cas limites, et les cas d'erreur.

---

### `reviewer`
**Rôle** : Revue de code et qualité
**Quand l'utiliser** : Après l'implémentation, avant la stabilisation
**Responsabilités** :
- Vérifier la qualité du code
- Détecter les bugs potentiels
- Vérifier les bonnes pratiques de sécurité
- Suggérer des améliorations

**Prompt pattern** :
> Tu es le reviewer du projet. Analyse le code qui vient d'être écrit. Vérifie la qualité, la sécurité, les performances, et les bonnes pratiques. Signale tout problème.

---

### `stabilizer`
**Rôle** : Stabilisation et validation finale
**Quand l'utiliser** : Après chaque feature, obligatoire avant de passer à la suivante
**Responsabilités** :
- Lancer le build complet
- Lancer tous les tests
- Lancer le linter
- Vérifier qu'il n'y a pas de régressions
- Valider que l'app démarre correctement

**Prompt pattern** :
> Tu es le stabilisateur. Lance tous les checks de stabilité (build, tests, lint, démarrage). Ne valide que si TOUT passe. Si quelque chose échoue, corrige-le avant de valider.

---

## Composition d'équipe par type de feature

| Type de feature | Équipe recommandée |
|---|---|
| Feature complexe (nouvelle) | architect → developer → tester → reviewer → stabilizer |
| Feature simple | developer → tester → stabilizer |
| Bug fix | developer → tester → stabilizer |
| Refactoring | architect → developer → reviewer → stabilizer |
| Documentation | developer → reviewer |
| Config / DevOps | architect → developer → stabilizer |

## Règles d'équipe

1. Le **stabilizer** intervient TOUJOURS en dernier
2. L'**architect** intervient TOUJOURS en premier quand il est assigné
3. Le **developer** est TOUJOURS présent
4. L'ordre d'exécution suit l'ordre du tableau d'assignation
