#!/bin/bash
# setup.sh — Script principal de bootstrap pour un nouveau projet
# Usage: bash scripts/setup.sh <chemin-du-projet-cible>
#
# Copie le setup Claude Code (skills, hooks, rules, scripts) dans un projet existant ou nouveau.

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

# [1/8] CLAUDE.md
echo "[1/8] CLAUDE.md..."
cp "$SETUP_DIR/CLAUDE.md" "$TARGET_DIR/CLAUDE.md"

# [2/8] project.md (sans écraser)
echo "[2/8] project.md (template)..."
if [ -f "$TARGET_DIR/project.md" ]; then
  echo "  -> project.md existe déjà, skip"
else
  cp "$SETUP_DIR/project.md" "$TARGET_DIR/project.md"
fi

# [3/8] .claude/ (settings, skills, hooks, rules)
echo "[3/8] .claude/ (settings, skills, hooks, rules)..."
mkdir -p "$TARGET_DIR/.claude/skills" "$TARGET_DIR/.claude/hooks" "$TARGET_DIR/.claude/rules"
cp "$SETUP_DIR/.claude/settings.json" "$TARGET_DIR/.claude/settings.json"
cp -r "$SETUP_DIR/.claude/skills/"* "$TARGET_DIR/.claude/skills/"
cp -r "$SETUP_DIR/.claude/hooks/"* "$TARGET_DIR/.claude/hooks/"
cp -r "$SETUP_DIR/.claude/rules/"* "$TARGET_DIR/.claude/rules/"
# Copier team.md et workflow.md s'ils existent (legacy)
[ -f "$SETUP_DIR/.claude/team.md" ] && cp "$SETUP_DIR/.claude/team.md" "$TARGET_DIR/.claude/team.md"
[ -f "$SETUP_DIR/.claude/workflow.md" ] && cp "$SETUP_DIR/.claude/workflow.md" "$TARGET_DIR/.claude/workflow.md"
chmod +x "$TARGET_DIR/.claude/hooks/"*.sh 2>/dev/null || true

# [4/8] Scripts
echo "[4/8] scripts/..."
mkdir -p "$TARGET_DIR/scripts"
cp "$SETUP_DIR/scripts/create-issues.sh" "$TARGET_DIR/scripts/create-issues.sh"
cp "$SETUP_DIR/scripts/stability-check.sh" "$TARGET_DIR/scripts/stability-check.sh"
cp "$SETUP_DIR/scripts/pre-merge-check.sh" "$TARGET_DIR/scripts/pre-merge-check.sh"
cp "$SETUP_DIR/scripts/check-us-eligibility.sh" "$TARGET_DIR/scripts/check-us-eligibility.sh"
cp "$SETUP_DIR/scripts/search-skills.sh" "$TARGET_DIR/scripts/search-skills.sh"
cp "$SETUP_DIR/scripts/install-skill.sh" "$TARGET_DIR/scripts/install-skill.sh"
chmod +x "$TARGET_DIR/scripts/"*.sh

# [5/8] GitHub templates et workflows
echo "[5/8] .github/ (issue templates, workflows)..."
mkdir -p "$TARGET_DIR/.github/ISSUE_TEMPLATE" "$TARGET_DIR/.github/workflows"
cp -r "$SETUP_DIR/.github/ISSUE_TEMPLATE/"* "$TARGET_DIR/.github/ISSUE_TEMPLATE/"
cp "$SETUP_DIR/.github/workflows/claude.yml" "$TARGET_DIR/.github/workflows/claude.yml"

# [6/8] .mcp.json
echo "[6/8] .mcp.json..."
if [ -f "$TARGET_DIR/.mcp.json" ]; then
  echo "  -> .mcp.json existe déjà, skip"
else
  cp "$SETUP_DIR/.mcp.json" "$TARGET_DIR/.mcp.json"
fi

# [7/8] .gitignore (append si existe)
echo "[7/8] .gitignore..."
if [ -f "$TARGET_DIR/.gitignore" ]; then
  # Ajouter les entrées manquantes
  for entry in "CLAUDE.local.md" ".env" ".env.local" ".env.production"; do
    if ! grep -qF "$entry" "$TARGET_DIR/.gitignore"; then
      echo "$entry" >> "$TARGET_DIR/.gitignore"
    fi
  done
  echo "  -> Entrées ajoutées au .gitignore existant"
else
  cp "$SETUP_DIR/.gitignore" "$TARGET_DIR/.gitignore"
fi

# [8/8] CLAUDE.local.md (template, gitignored)
echo "[8/8] CLAUDE.local.md (template local)..."
if [ -f "$TARGET_DIR/CLAUDE.local.md" ]; then
  echo "  -> CLAUDE.local.md existe déjà, skip"
else
  cp "$SETUP_DIR/CLAUDE.local.md" "$TARGET_DIR/CLAUDE.local.md"
fi

echo ""
echo "========================================="
echo "  SETUP TERMINÉ"
echo "========================================="
echo ""
echo "Fichiers installés :"
echo "  CLAUDE.md              - Instructions pour Claude Code"
echo "  project.md             - Contexte du projet (A REMPLIR)"
echo "  .claude/settings.json  - Hooks et permissions"
echo "  .claude/skills/        - 8 skills (forge, architect, developer, tester, reviewer, stabilizer, init-project, next-feature)"
echo "  .claude/hooks/         - protect-files, reinject-context"
echo "  .claude/rules/         - stability, commits, code-style"
echo "  scripts/               - create-issues, stability-check, pre-merge-check, check-us-eligibility, search-skills, install-skill"
echo "  .github/               - Issue templates, Claude CI workflow"
echo "  .mcp.json              - Config MCP servers"
echo ""
echo "Prochaines étapes :"
echo "  1. cd $TARGET_DIR"
echo "  2. Édite project.md avec le contexte de ton projet"
echo "  3. Lance Claude Code et tape : /init-project"
echo "  4. Puis tape : /forge pour dépiler les US avec le Team Lead intelligent"
echo "     (ou /next-feature pour un pipeline linéaire simple)"
echo ""
