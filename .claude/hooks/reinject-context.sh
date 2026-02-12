#!/bin/bash
# reinject-context.sh — Réinjecte le contexte critique après compaction
# Utilisé comme hook SessionStart avec matcher "compact"

if [ -f "$CLAUDE_PROJECT_DIR/project.md" ]; then
  echo "=== CONTEXTE PROJET (réinjecté après compaction) ==="
  head -50 "$CLAUDE_PROJECT_DIR/project.md"
  echo ""
  echo "=== WORKFLOW ==="
  echo "Rappel: Une feature à la fois. Stabiliser avant d'avancer. Utilise /next-feature pour continuer."
  echo ""
fi

# Afficher l'état des issues si gh est disponible
if command -v gh &> /dev/null; then
  echo "=== ÉTAT DES ISSUES ==="
  IN_PROGRESS=$(gh issue list --label "in-progress" --json number,title --jq '.[] | "#\(.number) \(.title)"' 2>/dev/null)
  if [ -n "$IN_PROGRESS" ]; then
    echo "En cours: $IN_PROGRESS"
  fi
  REMAINING=$(gh issue list --label "task" --json number --jq 'length' 2>/dev/null)
  if [ -n "$REMAINING" ]; then
    echo "Restantes: $REMAINING US"
  fi
  echo ""
fi

exit 0
