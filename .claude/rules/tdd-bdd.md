---
paths:
  - "src/**/*.{ts,tsx,js,jsx}"
  - "tests/**/*.{ts,tsx,js,jsx}"
  - "**/*.spec.{ts,tsx}"
  - "**/*.test.{ts,tsx}"
  - "**/*.e2e.{ts,tsx}"
---

# Règles TDD / BDD

## Principe fondamental : Red → Green → Refactor

**YOU MUST** suivre le cycle TDD sans exception :

1. **RED** — Écrire un test qui échoue (le comportement n'existe pas encore)
2. **GREEN** — Écrire le minimum de code pour faire passer le test
3. **REFACTOR** — Améliorer le code sans casser les tests

**YOU MUST NOT** écrire du code de production sans un test qui l'exige.

---

## Frontend : TDD avec Playwright

### Quand utiliser Playwright

Playwright est utilisé pour les tests E2E et composants sur le frontend.
**Tu écris les tests Playwright AVANT d'implémenter les pages/composants.**

### Structure des tests Playwright (BDD style)

```typescript
// tests/e2e/feature-name.spec.ts
import { test, expect } from '@playwright/test'

test.describe('Feature : [Nom de la feature]', () => {

  test.describe('Scenario : [Cas nominal]', () => {
    test('Given [contexte], When [action], Then [résultat attendu]', async ({ page }) => {
      // Given — setup du contexte
      await page.goto('/url')

      // When — action utilisateur
      await page.getByRole('button', { name: 'Submit' }).click()

      // Then — assertion
      await expect(page.getByText('Success')).toBeVisible()
    })
  })

  test.describe('Scenario : [Cas d\'erreur]', () => {
    test('Given [mauvais input], When [submit], Then [message d\'erreur visible]', async ({ page }) => {
      // ...
    })
  })
})
```

### Règles Playwright

- Nommage : `Given [contexte], When [action], Then [résultat]`
- Utilise les **locators sémantiques** : `getByRole`, `getByLabel`, `getByText` — pas de sélecteurs CSS fragiles
- Pas de `page.waitForTimeout()` — utilise `waitFor` ou les assertions auto-retry de Playwright
- Un test = un comportement utilisateur observable
- Place les tests dans `tests/e2e/` ou `e2e/` selon la convention du projet
- Les tests doivent passer en mode headless en CI

---

## Backend : TDD + BDD

### Structure des tests backend (BDD style)

```typescript
// src/feature/__tests__/feature.service.test.ts
describe('FeatureService', () => {

  describe('methodName', () => {

    describe('Given [contexte positif]', () => {
      it('should [comportement attendu] when [condition]', async () => {
        // Arrange (Given)
        const input = { ... }

        // Act (When)
        const result = await service.method(input)

        // Assert (Then)
        expect(result).toEqual(expected)
      })
    })

    describe('Given [contexte d\'erreur]', () => {
      it('should throw [type d\'erreur] when [condition invalide]', async () => {
        // ...
      })
    })

  })
})
```

### Ordre TDD strict pour le backend

1. Écrire le test (classe/fonction inexistante → erreur de compilation OK)
2. Créer le minimum de structure (interface/classe vide) pour que le test compile
3. Le test échoue (RED) — c'est attendu
4. Implémenter le code pour le faire passer (GREEN)
5. Refactoriser si nécessaire

### Règles de test backend

- **Granularité** :
  - Tests **unitaires** : logique métier pure (services, utils, validators)
  - Tests **d'intégration** : interactions DB, API endpoints
- **Mocks** : mocker les dépendances externes (DB, API tier), pas la logique métier interne
- **Nommage** : `should [verb] [object] when [condition]`
- Un `describe` par méthode/fonction, un `it` par comportement observable
- **Couvrir** : cas nominal, cas limites (vide, null, max), cas d'erreur (invalid input, timeout, DB error)

---

## Pipeline TDD dans le workflow

L'ordre d'exécution est **inversé** par rapport au workflow classique :

```
[architect]    → Plan + design des interfaces (contrats)
[tester RED]   → Écrire les tests qui ÉCHOUENT (feature non implémentée)
[developer]    → Implémenter pour faire passer les tests (GREEN)
[tester]       → Vérifier que tous les tests passent + refactor si besoin
[reviewer]     → Revue qualité/sécurité
[stabilizer]   → Quality gate finale
```

**YOU MUST NOT** appeler `[developer]` sans que `[tester RED]` ait d'abord écrit les tests.

---

## BDD : Nommage Given-When-Then

Tout test (frontend ou backend) DOIT utiliser le vocabulaire BDD :

| Terme | Signification | Correspondance code |
|-------|---------------|---------------------|
| **Given** | Contexte initial | `beforeEach`, `arrange`, `setup` |
| **When** | Action déclenchée | `act`, appel de fonction |
| **Then** | Résultat attendu | `expect`, assertion |

Exemples de nommage valides :
- `Given a logged-in user, When they submit the form, Then the data is saved`
- `should return 401 when token is missing`
- `should throw ValidationError when email is invalid`

---

## Anti-patterns interdits

- **YOU MUST NOT** écrire le code AVANT les tests
- **YOU MUST NOT** committer du code sans test correspondant (sauf config/boilerplate)
- **YOU MUST NOT** utiliser `test.skip` ou `xit` pour contourner un test rouge
- **YOU MUST NOT** mocker la logique métier interne — teste le vrai comportement
- **YOU MUST NOT** écrire des assertions vides (`expect(true).toBe(true)`)
- **YOU MUST NOT** utiliser `page.waitForTimeout()` dans Playwright
