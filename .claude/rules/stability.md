---
paths:
  - "src/**/*.{ts,tsx,js,jsx}"
  - "lib/**/*.{ts,tsx,js,jsx}"
---

# Règles de stabilité

- IMPORTANT : Après toute modification de code, lance /stabilizer ou vérifie manuellement build + tests + lint
- Ne désactive jamais un test existant pour "faire passer" une feature
- Ne supprime jamais une règle ESLint sans justification documentée
- Chaque feature doit être stable AVANT de passer à la suivante
