#!/bin/bash
# create-issues.sh — Crée les issues GitHub depuis project.md
# Usage: bash scripts/create-issues.sh

set -euo pipefail

PROJECT_FILE="project.md"

if [ ! -f "$PROJECT_FILE" ]; then
  echo "Erreur: $PROJECT_FILE introuvable. Lance ce script depuis la racine du projet."
  exit 1
fi

# Vérifier que gh est installé et authentifié
if ! command -v gh &> /dev/null; then
  echo "Erreur: GitHub CLI (gh) n'est pas installé."
  echo "Installe-le : https://cli.github.com/"
  exit 1
fi

if ! gh auth status &> /dev/null; then
  echo "Erreur: Tu n'es pas authentifié avec gh. Lance 'gh auth login'."
  exit 1
fi

# Créer les labels s'ils n'existent pas
echo "Création des labels..."
gh label create "task" --description "US créée, pas encore commencée" --color "0075ca" --force 2>/dev/null || true
gh label create "in-progress" --description "US en cours de développement" --color "e4e669" --force 2>/dev/null || true
gh label create "done" --description "US terminée et stabilisée" --color "0e8a16" --force 2>/dev/null || true
gh label create "bug" --description "Bug détecté" --color "d73a4a" --force 2>/dev/null || true
gh label create "blocked" --description "US bloquée par une dépendance" --color "b60205" --force 2>/dev/null || true
gh label create "haute" --description "Priorité haute" --color "d93f0b" --force 2>/dev/null || true
gh label create "moyenne" --description "Priorité moyenne" --color "fbca04" --force 2>/dev/null || true
gh label create "basse" --description "Priorité basse" --color "c5def5" --force 2>/dev/null || true

echo "Labels créés."

# Parser les US depuis project.md
echo ""
echo "Lecture des User Stories depuis $PROJECT_FILE..."
echo ""

count=0

while IFS= read -r line; do
  # Match lines like: - [US-XX] Titre | Description | Priorité
  if [[ "$line" =~ ^-\ \[US-([0-9]+)\]\ (.+)\ \|\ (.+)\ \|\ (.+)$ ]]; then
    us_num="${BASH_REMATCH[1]}"
    us_title="${BASH_REMATCH[2]}"
    us_desc="${BASH_REMATCH[3]}"
    us_priority="${BASH_REMATCH[4]}"

    # Trim whitespace
    us_title=$(echo "$us_title" | xargs)
    us_desc=$(echo "$us_desc" | xargs)
    us_priority=$(echo "$us_priority" | xargs)

    echo "Création de l'issue: [US-$us_num] $us_title"

    # Lire l'équipe assignée depuis le tableau dans project.md
    team_line=$(grep -E "^\| US-0?$us_num " "$PROJECT_FILE" || echo "")
    agents=""
    if [ -n "$team_line" ]; then
      agents=$(echo "$team_line" | sed 's/.*| //' | sed 's/ |$//' | xargs)
    fi

    # Construire le body de l'issue
    body="## Description

$us_desc

## Équipe agentique assignée

$agents

## Priorité

$us_priority"

    # Créer l'issue
    gh issue create \
      --title "[US-$us_num] $us_title" \
      --body "$body" \
      --label "task" \
      --label "$us_priority" \
      2>/dev/null && echo "  → Issue créée" || echo "  → Erreur lors de la création"

    count=$((count + 1))
  fi
done < "$PROJECT_FILE"

if [ "$count" -eq 0 ]; then
  echo "Aucune US trouvée dans $PROJECT_FILE."
  echo "Format attendu: - [US-XX] Titre | Description | Priorité"
else
  echo ""
  echo "$count issue(s) créée(s)."
fi

echo ""
echo "Voir les issues: gh issue list"
