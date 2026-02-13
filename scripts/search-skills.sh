#!/bin/bash
# search-skills.sh — Cherche des skills sur SkillsMP pour le projet
# Usage: bash scripts/search-skills.sh <query> [limit]
# Nécessite: SKILLSMP_API_KEY en variable d'environnement
#
# Exemples:
#   bash scripts/search-skills.sh "nextjs testing"
#   bash scripts/search-skills.sh "express middleware" 5
#   bash scripts/search-skills.sh --stack   # Cherche automatiquement basé sur project.md

set -uo pipefail

LIMIT="${2:-5}"

# ============================================================
# Mode --stack : lecture automatique depuis project.md
# ============================================================
if [ "${1:-}" = "--stack" ]; then
  if [ ! -f "project.md" ]; then
    echo "ERREUR: project.md non trouvé."
    exit 1
  fi

  # Extraire la stack technique de project.md
  stack_section=$(sed -n '/## Stack technique/,/^## /p' project.md | head -20)

  # Extraire les mots-clés de la stack
  keywords=""

  # Détecter les technologies
  for tech in "TypeScript" "JavaScript" "Python" "Rust" "Go" "Java" \
              "Next.js" "React" "Vue" "Angular" "Svelte" "Express" "Fastify" "NestJS" "Hono" \
              "PostgreSQL" "MongoDB" "MySQL" "Redis" "SQLite" "Prisma" "Drizzle" "Mongoose" \
              "Jest" "Vitest" "Playwright" "Cypress" "Mocha" \
              "ESLint" "Biome" "Prettier" \
              "Tailwind" "Sass" "CSS" \
              "Docker" "Kubernetes" \
              "GitHub Actions" "GitLab CI" \
              "Stripe" "Auth0" "NextAuth" "Supabase" "Firebase"; do
    if echo "$stack_section" | grep -qi "$tech"; then
      keywords="$keywords $tech"
    fi
  done

  if [ -z "$keywords" ]; then
    echo "Aucune technologie détectée dans project.md."
    exit 0
  fi

  echo "Technologies détectées :$keywords"
  echo ""

  # Chercher pour chaque technologie
  for tech in $keywords; do
    echo "--- Recherche: $tech ---"
    bash "$0" "$tech" 3
    echo ""
  done

  exit 0
fi

# ============================================================
# Mode normal : recherche par query
# ============================================================
QUERY="${1:-}"

if [ -z "$QUERY" ]; then
  echo "Usage:"
  echo "  bash scripts/search-skills.sh <query> [limit]"
  echo "  bash scripts/search-skills.sh --stack   # Auto-detect from project.md"
  exit 1
fi

# Vérifier si SKILLSMP_API_KEY est défini
API_KEY="${SKILLSMP_API_KEY:-}"

if [ -z "$API_KEY" ]; then
  # Fallback : recherche GitHub
  echo "[GitHub Search] Recherche de skills pour: $QUERY"
  echo ""

  # Chercher des repos GitHub avec "claude skill" + la techno
  results=$(gh search repos "claude skill $QUERY" --limit "$LIMIT" --json fullName,description,stargazersCount,url --jq '.[] | "  ★ \(.stargazersCount) | \(.fullName)\n    \(.description // "Pas de description")\n    \(.url)\n"' 2>/dev/null)

  if [ -z "$results" ]; then
    # Essayer aussi avec "agent skill"
    results=$(gh search repos "agent skill SKILL.md $QUERY" --limit "$LIMIT" --json fullName,description,stargazersCount,url --jq '.[] | "  ★ \(.stargazersCount) | \(.fullName)\n    \(.description // "Pas de description")\n    \(.url)\n"' 2>/dev/null)
  fi

  if [ -z "$results" ]; then
    echo "  Aucun résultat trouvé."
  else
    echo -e "$results"
  fi
else
  # SkillsMP API
  echo "[SkillsMP] Recherche de skills pour: $QUERY"
  echo ""

  encoded_query=$(echo "$QUERY" | sed 's/ /+/g')

  response=$(curl -s -X GET \
    "https://skillsmp.com/api/v1/skills/search?q=${encoded_query}&limit=${LIMIT}" \
    -H "Authorization: Bearer $API_KEY" \
    -H "Accept: application/json" \
    2>/dev/null)

  if [ $? -ne 0 ] || [ -z "$response" ]; then
    echo "  Erreur de connexion à SkillsMP. Fallback GitHub..."
    API_KEY="" bash "$0" "$QUERY" "$LIMIT"
    exit $?
  fi

  # Vérifier si c'est une erreur
  if echo "$response" | jq -e '.error' >/dev/null 2>&1; then
    error_msg=$(echo "$response" | jq -r '.error // .message // "Erreur inconnue"')
    echo "  Erreur SkillsMP: $error_msg"
    echo "  Fallback GitHub..."
    API_KEY="" bash "$0" "$QUERY" "$LIMIT"
    exit $?
  fi

  # Parser les résultats
  echo "$response" | jq -r '.data[]? // .skills[]? // .[]? | "  ★ \(.stars // .stargazersCount // 0) | \(.name // .fullName // "?")\n    \(.description // "Pas de description")\n    \(.url // .html_url // .repo_url // "")\n"' 2>/dev/null

  if [ $? -ne 0 ]; then
    echo "  Format de réponse inattendu. Résultat brut :"
    echo "$response" | jq '.' 2>/dev/null || echo "$response"
  fi
fi
