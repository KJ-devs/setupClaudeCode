#!/bin/bash
# pre-merge-check.sh — Vérifie qu'une branche est prête à être mergée
# Usage: bash scripts/pre-merge-check.sh [branch-name]
# Si pas de branch-name, utilise la branche courante

set -uo pipefail

BRANCH="${1:-$(git branch --show-current)}"
BASE_BRANCH="main"

echo "========================================="
echo "  PRE-MERGE CHECK"
echo "  Branche : $BRANCH"
echo "  Base    : $BASE_BRANCH"
echo "========================================="
echo ""

errors=0

# 1. Vérifier qu'on n'est pas sur main
echo "[1/6] Vérification de la branche..."
if [ "$BRANCH" = "main" ] || [ "$BRANCH" = "master" ]; then
  echo "  ✗ ERREUR : Tu es sur $BRANCH. Basculer sur la branche feature."
  exit 1
fi
echo "  ✓ Branche feature : $BRANCH"
echo ""

# 2. Vérifier que la branche est à jour avec main (rebasée)
echo "[2/6] Vérification du rebase sur $BASE_BRANCH..."
git fetch origin "$BASE_BRANCH" --quiet 2>/dev/null

# Vérifier si la branche est rebasée sur main
MERGE_BASE=$(git merge-base "$BRANCH" "origin/$BASE_BRANCH" 2>/dev/null)
MAIN_HEAD=$(git rev-parse "origin/$BASE_BRANCH" 2>/dev/null)

if [ "$MERGE_BASE" != "$MAIN_HEAD" ]; then
  echo "  ✗ La branche n'est PAS rebasée sur $BASE_BRANCH"
  echo "    → Exécute : git fetch origin $BASE_BRANCH && git rebase origin/$BASE_BRANCH"
  errors=$((errors + 1))
else
  echo "  ✓ Branche rebasée sur $BASE_BRANCH"
fi
echo ""

# 3. Vérifier qu'il n'y a pas de changements non commités
echo "[3/6] Vérification des changements non commités..."
if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
  echo "  ✗ Des changements non commités existent"
  echo "    → Commite ou stash tes changements avant le merge"
  errors=$((errors + 1))
else
  echo "  ✓ Working directory propre"
fi
echo ""

# 4. Vérifier que la branche existe sur le remote
echo "[4/6] Vérification de la branche sur le remote..."
if git ls-remote --heads origin "$BRANCH" | grep -q "$BRANCH"; then
  echo "  ✓ Branche existe sur le remote"
else
  echo "  ✗ La branche n'existe PAS sur le remote"
  echo "    → Exécute : git push -u origin $BRANCH"
  errors=$((errors + 1))
fi
echo ""

# 5. Stability check
echo "[5/6] Stability check..."
if bash scripts/stability-check.sh; then
  echo "  ✓ Stability check OK"
else
  echo "  ✗ Stability check FAILED"
  errors=$((errors + 1))
fi
echo ""

# 6. Vérifier qu'une PR existe
echo "[6/6] Vérification de la PR..."
PR_NUMBER=$(gh pr list --head "$BRANCH" --json number --jq '.[0].number' 2>/dev/null)
if [ -n "$PR_NUMBER" ] && [ "$PR_NUMBER" != "null" ]; then
  echo "  ✓ PR #$PR_NUMBER existe"

  # Vérifier la mergeabilité
  MERGEABLE=$(gh pr view "$PR_NUMBER" --json mergeable --jq '.mergeable' 2>/dev/null)
  if [ "$MERGEABLE" = "MERGEABLE" ]; then
    echo "  ✓ PR est mergeable (pas de conflits)"
  elif [ "$MERGEABLE" = "CONFLICTING" ]; then
    echo "  ✗ PR a des conflits avec $BASE_BRANCH"
    echo "    → Rebase sur $BASE_BRANCH et push à nouveau"
    errors=$((errors + 1))
  else
    echo "  ⚠ Statut de mergeabilité inconnu : $MERGEABLE"
  fi

  # Vérifier les checks CI
  CHECKS_STATUS=$(gh pr checks "$PR_NUMBER" --json state --jq '[.[].state] | if all(. == "SUCCESS") then "pass" elif any(. == "FAILURE") then "fail" else "pending" end' 2>/dev/null)
  if [ "$CHECKS_STATUS" = "pass" ]; then
    echo "  ✓ CI checks passent"
  elif [ "$CHECKS_STATUS" = "fail" ]; then
    echo "  ✗ CI checks en échec"
    errors=$((errors + 1))
  elif [ "$CHECKS_STATUS" = "pending" ]; then
    echo "  ⚠ CI checks en cours..."
  else
    echo "  ⚠ Pas de CI checks configurés"
  fi
else
  echo "  ✗ Pas de PR pour cette branche"
  echo "    → Crée une PR : gh pr create --base $BASE_BRANCH"
  errors=$((errors + 1))
fi
echo ""

echo "========================================="
if [ "$errors" -eq 0 ]; then
  echo "  RÉSULTAT: PRÊT À MERGER ✓"
  echo "  Tous les checks passent."
  echo "========================================="
  exit 0
else
  echo "  RÉSULTAT: PAS PRÊT ✗"
  echo "  $errors vérification(s) en échec."
  echo "  Corrige les problèmes avant de merger."
  echo "========================================="
  exit 1
fi
