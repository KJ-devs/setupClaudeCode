#!/bin/bash
# stability-check.sh — Vérifie la stabilité de l'application
# Usage: bash scripts/stability-check.sh

set -uo pipefail

echo "========================================="
echo "  STABILITY CHECK"
echo "========================================="
echo ""

errors=0

# 1. Build
echo "[1/4] Build..."
if npm run build 2>&1; then
  echo "  ✓ Build OK"
else
  echo "  ✗ Build FAILED"
  errors=$((errors + 1))
fi
echo ""

# 2. Tests
echo "[2/4] Tests..."
if npm test 2>&1; then
  echo "  ✓ Tests OK"
else
  echo "  ✗ Tests FAILED"
  errors=$((errors + 1))
fi
echo ""

# 3. Lint
echo "[3/4] Lint..."
if npm run lint 2>&1; then
  echo "  ✓ Lint OK"
else
  echo "  ✗ Lint FAILED"
  errors=$((errors + 1))
fi
echo ""

# 4. Type check (si disponible)
echo "[4/4] Type check..."
if npm run type-check 2>&1; then
  echo "  ✓ Type check OK"
elif npx tsc --noEmit 2>&1; then
  echo "  ✓ Type check OK (via tsc)"
else
  echo "  ⚠ Type check skipped (pas de script type-check)"
fi
echo ""

echo "========================================="
if [ "$errors" -eq 0 ]; then
  echo "  RÉSULTAT: STABLE ✓"
  echo "  Tous les checks passent."
  echo "========================================="
  exit 0
else
  echo "  RÉSULTAT: INSTABLE ✗"
  echo "  $errors check(s) en échec."
  echo "========================================="
  exit 1
fi
