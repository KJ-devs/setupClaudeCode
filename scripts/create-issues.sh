#!/bin/bash
# create-issues.sh — Crée les issues GitHub depuis project.md avec support des dépendances
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

# Tableaux associatifs pour stocker les numéros d'issues créées
declare -A issue_numbers
declare -A us_titles
declare -A us_descs
declare -A us_priorities
declare -A us_deps
us_order=()

count=0

# Premier pass : parser toutes les US et leurs dépendances
while IFS= read -r line; do
  # Match lines with optional dependencies: - [US-XX] Titre | Description | Priorité | Deps
  if [[ "$line" =~ ^-\ \[US-([0-9]+)\]\ (.+)\ \|\ (.+)\ \|\ ([^|]+)(\|\ (.+))?$ ]]; then
    us_num="${BASH_REMATCH[1]}"
    us_title=$(echo "${BASH_REMATCH[2]}" | xargs)
    us_desc=$(echo "${BASH_REMATCH[3]}" | xargs)
    us_priority=$(echo "${BASH_REMATCH[4]}" | xargs)
    us_dep=$(echo "${BASH_REMATCH[6]:-}" | xargs)

    us_titles["$us_num"]="$us_title"
    us_descs["$us_num"]="$us_desc"
    us_priorities["$us_num"]="$us_priority"
    us_deps["$us_num"]="$us_dep"
    us_order+=("$us_num")
    count=$((count + 1))
  fi
done < "$PROJECT_FILE"

if [ "$count" -eq 0 ]; then
  echo "Aucune US trouvée dans $PROJECT_FILE."
  echo "Format attendu:"
  echo "  - [US-XX] Titre | Description | Priorité"
  echo "  - [US-XX] Titre | Description | Priorité | après:US-YY"
  exit 0
fi

echo "Trouvé $count US. Création des issues..."
echo ""

# Deuxième pass : créer les issues dans l'ordre
for us_num in "${us_order[@]}"; do
  us_title="${us_titles[$us_num]}"
  us_desc="${us_descs[$us_num]}"
  us_priority="${us_priorities[$us_num]}"
  us_dep="${us_deps[$us_num]:-}"

  echo "Création de l'issue: [US-$us_num] $us_title"

  # Lire l'équipe assignée depuis le tableau dans project.md
  team_line=$(grep -E "^\| US-0?$us_num " "$PROJECT_FILE" || echo "")
  agents=""
  if [ -n "$team_line" ]; then
    agents=$(echo "$team_line" | sed 's/.*| //' | sed 's/ |$//' | xargs)
  fi

  # Construire la section dépendances
  dep_section="Aucune — peut démarrer immédiatement"
  if [ -n "$us_dep" ]; then
    dep_section=""
    # Parser les dépendances (format: après:US-XX, partage:US-YY, enrichit:US-ZZ)
    IFS=',' read -ra dep_items <<< "$us_dep"
    for dep_item in "${dep_items[@]}"; do
      dep_item=$(echo "$dep_item" | xargs)
      dep_type=$(echo "$dep_item" | cut -d: -f1)
      dep_target=$(echo "$dep_item" | cut -d: -f2 | sed 's/US-//' | xargs)

      # Récupérer le numéro d'issue GitHub si déjà créé
      dep_issue_ref=""
      if [ -n "${issue_numbers[$dep_target]:-}" ]; then
        dep_issue_ref="#${issue_numbers[$dep_target]}"
      else
        dep_issue_ref="[US-$dep_target]"
      fi

      dep_title="${us_titles[$dep_target]:-Inconnue}"

      case "$dep_type" in
        "après")
          dep_section="${dep_section}- **Bloquée par** : $dep_issue_ref ([US-$dep_target] $dep_title) — type: après
"
          ;;
        "partage")
          dep_section="${dep_section}- **Partage le scope avec** : $dep_issue_ref ([US-$dep_target] $dep_title) — type: partage
"
          ;;
        "enrichit")
          dep_section="${dep_section}- **Enrichit** : $dep_issue_ref ([US-$dep_target] $dep_title) — type: enrichit
"
          ;;
        *)
          dep_section="${dep_section}- **Lié à** : $dep_issue_ref ([US-$dep_target] $dep_title) — type: $dep_type
"
          ;;
      esac
    done
  fi

  # Construire le body de l'issue
  body="## Description

$us_desc

## Dépendances

$dep_section

## Équipe agentique assignée

$agents

## Priorité

$us_priority"

  # Créer l'issue
  issue_url=$(gh issue create \
    --title "[US-$us_num] $us_title" \
    --body "$body" \
    --label "task" \
    --label "$us_priority" \
    2>/dev/null || echo "")

  if [ -n "$issue_url" ]; then
    # Extraire le numéro d'issue depuis l'URL
    issue_num=$(echo "$issue_url" | grep -oE '[0-9]+$')
    issue_numbers["$us_num"]="$issue_num"
    echo "  → Issue #$issue_num créée"
  else
    echo "  → Erreur lors de la création"
  fi
done

echo ""
echo "$count issue(s) créée(s)."

# Afficher le graphe de dépendances
echo ""
echo "========================================="
echo "  GRAPHE DE DÉPENDANCES"
echo "========================================="
has_deps=false
for us_num in "${us_order[@]}"; do
  us_dep="${us_deps[$us_num]:-}"
  issue_ref="${issue_numbers[$us_num]:-?}"
  if [ -n "$us_dep" ]; then
    has_deps=true
    dep_sources=$(echo "$us_dep" | grep -oE 'US-[0-9]+' | tr '\n' ', ' | sed 's/,$//')
    echo "  $dep_sources ──→ US-$us_num (#$issue_ref)"
  else
    echo "  US-$us_num (#$issue_ref) — indépendante"
  fi
done

if [ "$has_deps" = false ]; then
  echo "  Aucune dépendance déclarée — toutes les US sont indépendantes"
fi
echo "========================================="

echo ""
echo "Voir les issues: gh issue list"
