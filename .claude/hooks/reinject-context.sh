#!/bin/bash
# reinject-context.sh — Réinjecte le contexte critique après compaction
# Utilisé comme hook SessionStart avec matcher "compact"

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"

# === Contexte projet ===
if [ -f "$PROJECT_DIR/project.md" ]; then
  echo "=== CONTEXTE PROJET (réinjecté après compaction) ==="
  head -50 "$PROJECT_DIR/project.md"
  echo ""
fi

# === État de session (CLAUDE.local.md) ===
if [ -f "$PROJECT_DIR/CLAUDE.local.md" ]; then
  echo "=== ÉTAT DE SESSION ==="
  # Afficher le sprint en cours
  sed -n '/## Sprint en cours/,/^## /p' "$PROJECT_DIR/CLAUDE.local.md" | head -n -1
  echo ""
fi

# === Branche courante ===
BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
echo "=== BRANCHE COURANTE ==="
echo "  $BRANCH"
echo ""

# === État des issues ===
if command -v gh &> /dev/null; then
  echo "=== ÉTAT DES ISSUES ==="
  IN_PROGRESS=$(gh issue list --label "in-progress" --json number,title --jq '.[] | "#\(.number) \(.title)"' 2>/dev/null)
  if [ -n "$IN_PROGRESS" ]; then
    echo "En cours: $IN_PROGRESS"
  else
    echo "Aucune US en cours"
  fi
  REMAINING=$(gh issue list --label "task" --json number --jq 'length' 2>/dev/null)
  if [ -n "$REMAINING" ]; then
    echo "Restantes: $REMAINING US"
  fi
  echo ""
fi

# === Rappel des règles critiques ===
echo "=== WORKFLOW ==="
echo "Rappel: Une feature à la fois. Stabiliser avant d'avancer. Utilise /forge pour continuer."
echo "Commandes: /forge (Team Lead), /next-feature (pipeline simple), /stabilizer (checks)"
echo ""

exit 0
