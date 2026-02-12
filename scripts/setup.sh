#!/bin/bash
# setup.sh — Script principal de bootstrap pour un nouveau projet
# Usage: bash scripts/setup.sh [nom-du-repo-cible]
#
# Ce script copie le setup Claude Code dans un nouveau projet.

set -euo pipefail

SETUP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "========================================="
echo "  SETUP CLAUDE CODE"
echo "  Template de démarrage de projet"
echo "========================================="
echo ""

# Vérifier les arguments
if [ $# -lt 1 ]; then
  echo "Usage: bash scripts/setup.sh <chemin-du-projet-cible>"
  echo ""
  echo "Exemple:"
  echo "  bash scripts/setup.sh ~/projects/mon-nouveau-projet"
  exit 1
fi

TARGET_DIR="$1"

# Vérifier que le répertoire cible existe
if [ ! -d "$TARGET_DIR" ]; then
  echo "Le répertoire $TARGET_DIR n'existe pas."
  read -p "Le créer ? (y/n) " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    mkdir -p "$TARGET_DIR"
    echo "Répertoire créé."
  else
    echo "Annulé."
    exit 1
  fi
fi

echo "Copie du setup vers : $TARGET_DIR"
echo ""

# Copier les fichiers de setup
echo "[1/5] Copie de CLAUDE.md..."
cp "$SETUP_DIR/CLAUDE.md" "$TARGET_DIR/CLAUDE.md"

echo "[2/5] Copie de project.md (template)..."
if [ -f "$TARGET_DIR/project.md" ]; then
  echo "  ⚠ project.md existe déjà, skip (pas d'écrasement)"
else
  cp "$SETUP_DIR/project.md" "$TARGET_DIR/project.md"
fi

echo "[3/5] Copie de .claude/..."
mkdir -p "$TARGET_DIR/.claude"
cp -r "$SETUP_DIR/.claude/"* "$TARGET_DIR/.claude/"

echo "[4/5] Copie des scripts/..."
mkdir -p "$TARGET_DIR/scripts"
cp "$SETUP_DIR/scripts/create-issues.sh" "$TARGET_DIR/scripts/create-issues.sh"
cp "$SETUP_DIR/scripts/stability-check.sh" "$TARGET_DIR/scripts/stability-check.sh"

echo "[5/5] Copie des templates GitHub..."
mkdir -p "$TARGET_DIR/.github/ISSUE_TEMPLATE"
cp -r "$SETUP_DIR/.github/ISSUE_TEMPLATE/"* "$TARGET_DIR/.github/ISSUE_TEMPLATE/"

echo ""
echo "========================================="
echo "  SETUP TERMINÉ ✓"
echo "========================================="
echo ""
echo "Prochaines étapes :"
echo "  1. cd $TARGET_DIR"
echo "  2. Édite project.md avec le contexte de ton projet"
echo "  3. Remplis les User Stories dans project.md"
echo "  4. Lance Claude Code et dis-lui : 'Lis CLAUDE.md et initialise le projet'"
echo ""
echo "Claude Code va alors :"
echo "  - Lire le contexte du projet"
echo "  - Créer les issues GitHub"
echo "  - Dépiler les features une par une"
echo "  - Stabiliser après chaque feature"
echo "  - Nettoyer le contexte entre chaque feature"
echo ""
