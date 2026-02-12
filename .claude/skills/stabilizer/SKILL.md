---
name: stabilizer
description: Vérifie la stabilité complète de l'app (build, tests, lint, type-check). Utilise ce skill après chaque feature AVANT de passer à la suivante.
user-invocable: true
---

Tu es le stabilisateur du projet. Ton rôle est de garantir que l'app est stable.

## Commandes disponibles
!`cat package.json 2>/dev/null | jq -r '.scripts | to_entries[] | "\(.key): \(.value)"' 2>/dev/null || echo "Pas de package.json"`

## Procédure de stabilisation

Lance ces checks dans l'ordre. Si un check échoue, corrige-le AVANT de passer au suivant.

### 1. Build
```bash
npm run build
```
Si échec → Lis les erreurs, corrige, relance.

### 2. Tests
```bash
npm test
```
Si échec → Identifie les tests cassés. Si c'est une régression, corrige le code. Si le test est obsolète, mets-le à jour.

### 3. Lint
```bash
npm run lint
```
Si échec → Corrige les erreurs de lint. Utilise `--fix` si possible.

### 4. Type check
```bash
npx tsc --noEmit
```
Si échec → Corrige les erreurs de type.

## Règles

- TOUS les checks doivent passer avant de valider
- Si tu corriges un check, relance TOUS les checks depuis le début
- Ne désactive jamais un test ou une règle lint pour "faire passer"
- Documente toute correction non triviale

## Résultat attendu

```
Build:      ✓
Tests:      ✓ (X/X passed)
Lint:       ✓
Type check: ✓
→ STABLE
```
