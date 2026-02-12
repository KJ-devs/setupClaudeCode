# Règles de branches

- **YOU MUST** nommer les branches avec le format : `type/scope/description-courte`
  - `feat/publicapi/add-pagination`
  - `fix/dashboard/chart-mobile-rendering`
  - `refactor/integrations/stripe-service`
  - `test/publicapi/auth-e2e`
- Le **scope** dans le nom de branche doit correspondre au scope des commits
- Description en kebab-case (mots séparés par des tirets)
- Pas de majuscules, pas d'espaces, pas de caractères spéciaux

# Règles de Pull Requests

- **YOU MUST** nommer les PR avec le format : `type(scope): description courte`
  - Même format que les commits
  - Le titre de la PR résume l'ensemble des changements de la branche
- Exemples :
  - `feat(publicapi): add pagination to /users endpoint`
  - `fix(dashboard): correct chart rendering on mobile`
  - `refactor(integrations): extract Stripe client into service`
- Le body de la PR doit contenir :
  - `## Summary` — 1 à 3 bullet points décrivant les changements
  - `## Test plan` — checklist de vérification
- Le scope de la PR doit correspondre au scope de la branche et des commits
