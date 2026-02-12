# Règles de commits

- Commits atomiques : un commit = un changement logique
- Messages en français ou anglais (cohérent avec le projet)
- **YOU MUST** utiliser le format : `type(scope): description courte`
  - `feat(scope): description` — nouvelle feature
  - `fix(scope): description` — correction de bug
  - `refactor(scope): description` — refactoring sans changement de comportement
  - `test(scope): description` — ajout ou modification de tests
  - `docs(scope): description` — documentation
  - `chore(scope): description` — maintenance, config
- Le **scope** identifie le domaine fonctionnel concerné. Exemples :
  - `(publicapi)` — API publique
  - `(dashboard)` — Interface dashboard
  - `(integrations)` — Intégrations tierces
  - `(auth)` — Authentification
  - `(database)` — Base de données
  - `(ci)` — CI/CD
- Exemples concrets :
  - `feat(publicapi): add pagination to /users endpoint`
  - `fix(dashboard): correct chart rendering on mobile`
  - `refactor(integrations): extract Stripe client into service`
  - `test(publicapi): add e2e tests for auth flow`
- Ne jamais committer de fichiers .env, secrets, ou credentials

# Règles de branches

- **YOU MUST** nommer les branches avec le format : `type/scope/description-courte`
  - `feat/publicapi/add-pagination`
  - `fix/dashboard/chart-mobile-rendering`
  - `refactor/integrations/stripe-service`
  - `test/publicapi/auth-e2e`
- Le **scope** dans le nom de branche doit correspondre au scope des commits
- Description en kebab-case (mots séparés par des tirets)
- Pas de majuscules, pas d'espaces, pas de caractères spéciaux
