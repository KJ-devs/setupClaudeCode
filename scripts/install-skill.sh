#!/bin/bash
# install-skill.sh — Installe un skill depuis un repo GitHub
# Usage: bash scripts/install-skill.sh <github-owner/repo> [skill-folder-name]
#
# Exemples:
#   bash scripts/install-skill.sh anthropics/skills              # Installe tout le repo
#   bash scripts/install-skill.sh owner/repo my-skill            # Installe un dossier spécifique
#   bash scripts/install-skill.sh owner/repo skills/nextjs       # Chemin dans le repo

set -uo pipefail

REPO="${1:-}"
SKILL_PATH="${2:-}"

if [ -z "$REPO" ]; then
  echo "Usage: bash scripts/install-skill.sh <github-owner/repo> [skill-folder-name]"
  echo ""
  echo "Exemples:"
  echo "  bash scripts/install-skill.sh anthropics/skills"
  echo "  bash scripts/install-skill.sh owner/repo nextjs-testing"
  exit 1
fi

SKILLS_DIR=".claude/skills"
TEMP_DIR=$(mktemp -d)

echo "Installation du skill depuis $REPO..."

# Cloner le repo (shallow)
if ! git clone --depth 1 "https://github.com/$REPO.git" "$TEMP_DIR/repo" 2>/dev/null; then
  echo "✗ Impossible de cloner https://github.com/$REPO"
  rm -rf "$TEMP_DIR"
  exit 1
fi

# Trouver les SKILL.md dans le repo
if [ -n "$SKILL_PATH" ]; then
  # Chemin spécifique
  SEARCH_PATH="$TEMP_DIR/repo/$SKILL_PATH"
  if [ ! -d "$SEARCH_PATH" ]; then
    # Essayer comme nom de dossier dans skills/
    SEARCH_PATH="$TEMP_DIR/repo/skills/$SKILL_PATH"
  fi
  if [ ! -d "$SEARCH_PATH" ]; then
    # Chercher le dossier par nom
    SEARCH_PATH=$(find "$TEMP_DIR/repo" -type d -name "$SKILL_PATH" -maxdepth 3 | head -1)
  fi

  if [ -z "$SEARCH_PATH" ] || [ ! -d "$SEARCH_PATH" ]; then
    echo "✗ Dossier '$SKILL_PATH' non trouvé dans le repo."
    echo "  Dossiers disponibles :"
    find "$TEMP_DIR/repo" -name "SKILL.md" -maxdepth 4 -exec dirname {} \; | sed "s|$TEMP_DIR/repo/||" | sort
    rm -rf "$TEMP_DIR"
    exit 1
  fi

  # Vérifier qu'il y a un SKILL.md
  if [ ! -f "$SEARCH_PATH/SKILL.md" ]; then
    echo "✗ Pas de SKILL.md trouvé dans $SKILL_PATH"
    rm -rf "$TEMP_DIR"
    exit 1
  fi

  SKILL_NAME=$(basename "$SEARCH_PATH")
  mkdir -p "$SKILLS_DIR/$SKILL_NAME"
  cp -r "$SEARCH_PATH/"* "$SKILLS_DIR/$SKILL_NAME/"
  echo "✓ Skill '$SKILL_NAME' installé dans $SKILLS_DIR/$SKILL_NAME/"

else
  # Installer tous les skills trouvés
  installed=0
  while IFS= read -r skill_md; do
    skill_dir=$(dirname "$skill_md")
    skill_name=$(basename "$skill_dir")

    # Skip les dossiers de config
    if [[ "$skill_name" == "." ]] || [[ "$skill_name" == "template" ]] || [[ "$skill_name" == "spec" ]]; then
      continue
    fi

    mkdir -p "$SKILLS_DIR/$skill_name"
    cp -r "$skill_dir/"* "$SKILLS_DIR/$skill_name/"
    echo "  ✓ $skill_name"
    installed=$((installed + 1))
  done < <(find "$TEMP_DIR/repo" -name "SKILL.md" -maxdepth 4 | sort)

  if [ "$installed" -eq 0 ]; then
    echo "✗ Aucun skill (SKILL.md) trouvé dans le repo."
    rm -rf "$TEMP_DIR"
    exit 1
  fi

  echo ""
  echo "✓ $installed skill(s) installé(s) dans $SKILLS_DIR/"
fi

# Cleanup
rm -rf "$TEMP_DIR"

echo ""
echo "Les skills seront automatiquement détectés par Claude Code."
