#!/bin/bash
# check-us-eligibility.sh — Vérifie si une US est éligible (dépendances satisfaites)
# Usage: bash scripts/check-us-eligibility.sh <issue-number>
# Exit code 0 = éligible, 1 = bloquée
#
# Peut aussi lister les US éligibles :
#   bash scripts/check-us-eligibility.sh --list

set -uo pipefail

# ============================================================
# Mode --list : affiche toutes les US éligibles triées par priorité
# ============================================================
if [ "${1:-}" = "--list" ]; then
  echo "========================================="
  echo "  US ÉLIGIBLES"
  echo "========================================="
  echo ""

  # Récupérer toutes les issues avec label "task"
  task_issues=$(gh issue list --label "task" --json number,title,labels,body --jq '.[] | @json' 2>/dev/null)

  if [ -z "$task_issues" ]; then
    echo "Aucune US avec le label 'task'."
    exit 0
  fi

  eligible_haute=()
  eligible_moyenne=()
  eligible_basse=()
  blocked=()

  while IFS= read -r issue_json; do
    number=$(echo "$issue_json" | jq -r '.number')
    title=$(echo "$issue_json" | jq -r '.title')
    body=$(echo "$issue_json" | jq -r '.body')
    labels=$(echo "$issue_json" | jq -r '.labels[].name' | tr '\n' ',')

    # Déterminer la priorité
    priority="basse"
    if echo "$labels" | grep -q "haute"; then
      priority="haute"
    elif echo "$labels" | grep -q "moyenne"; then
      priority="moyenne"
    fi

    # Vérifier les dépendances
    is_eligible=true
    block_reason=""

    # Chercher les dépendances "après" (Bloquée par)
    while IFS= read -r dep_line; do
      if [ -z "$dep_line" ]; then continue; fi

      # Extraire le numéro d'issue de la dépendance
      dep_num=$(echo "$dep_line" | grep -oE '#[0-9]+' | head -1 | tr -d '#')
      if [ -z "$dep_num" ]; then continue; fi

      # Vérifier le type de dépendance
      if echo "$dep_line" | grep -qi "bloquée par\|type: après"; then
        # Vérifier si la dépendance a le label "done"
        dep_labels=$(gh issue view "$dep_num" --json labels --jq '.labels[].name' 2>/dev/null | tr '\n' ',')
        if ! echo "$dep_labels" | grep -q "done"; then
          is_eligible=false
          block_reason="${block_reason}#$dep_num (après, pas done) "
        fi
      elif echo "$dep_line" | grep -qi "partage le scope\|type: partage"; then
        # Vérifier si la dépendance est in-progress
        dep_labels=$(gh issue view "$dep_num" --json labels --jq '.labels[].name' 2>/dev/null | tr '\n' ',')
        if echo "$dep_labels" | grep -q "in-progress"; then
          is_eligible=false
          block_reason="${block_reason}#$dep_num (partage, in-progress) "
        fi
      elif echo "$dep_line" | grep -qi "enrichit\|type: enrichit"; then
        # Vérifier si la dépendance est au moins in-progress
        dep_labels=$(gh issue view "$dep_num" --json labels --jq '.labels[].name' 2>/dev/null | tr '\n' ',')
        if echo "$dep_labels" | grep -q "task"; then
          if ! echo "$dep_labels" | grep -qE "done|in-progress"; then
            is_eligible=false
            block_reason="${block_reason}#$dep_num (enrichit, encore en task) "
          fi
        fi
      fi
    done <<< "$(echo "$body" | grep -iE '(bloquée par|partage le scope|enrichit|type:)')"

    # Vérifier si "Aucune" est mentionné dans les dépendances
    if echo "$body" | grep -q "Aucune — peut démarrer immédiatement"; then
      is_eligible=true
      block_reason=""
    fi

    if [ "$is_eligible" = true ]; then
      case "$priority" in
        "haute")   eligible_haute+=("#$number $title") ;;
        "moyenne") eligible_moyenne+=("#$number $title") ;;
        "basse")   eligible_basse+=("#$number $title") ;;
      esac
    else
      blocked+=("#$number $title → bloquée par: $block_reason")
    fi
  done <<< "$task_issues"

  # Afficher les résultats par priorité
  if [ ${#eligible_haute[@]} -gt 0 ] || [ ${#eligible_moyenne[@]} -gt 0 ] || [ ${#eligible_basse[@]} -gt 0 ]; then
    echo "Prêtes à démarrer :"
    echo ""
    for item in "${eligible_haute[@]:-}"; do
      [ -n "$item" ] && echo "  [HAUTE]   $item"
    done
    for item in "${eligible_moyenne[@]:-}"; do
      [ -n "$item" ] && echo "  [MOYENNE] $item"
    done
    for item in "${eligible_basse[@]:-}"; do
      [ -n "$item" ] && echo "  [BASSE]   $item"
    done
  else
    echo "Aucune US éligible."
  fi

  if [ ${#blocked[@]} -gt 0 ]; then
    echo ""
    echo "Bloquées :"
    for item in "${blocked[@]}"; do
      echo "  ✗ $item"
    done
  fi

  echo ""
  echo "========================================="

  # Afficher la recommandation
  if [ ${#eligible_haute[@]} -gt 0 ]; then
    echo "  → Prochaine US recommandée : ${eligible_haute[0]}"
  elif [ ${#eligible_moyenne[@]} -gt 0 ]; then
    echo "  → Prochaine US recommandée : ${eligible_moyenne[0]}"
  elif [ ${#eligible_basse[@]} -gt 0 ]; then
    echo "  → Prochaine US recommandée : ${eligible_basse[0]}"
  else
    echo "  → Aucune US disponible. Toutes sont bloquées."
  fi
  echo "========================================="
  exit 0
fi

# ============================================================
# Mode normal : vérifier une issue spécifique
# ============================================================
ISSUE_NUMBER="${1:-}"

if [ -z "$ISSUE_NUMBER" ]; then
  echo "Usage:"
  echo "  bash scripts/check-us-eligibility.sh <issue-number>  # Vérifier une US"
  echo "  bash scripts/check-us-eligibility.sh --list           # Lister les US éligibles"
  exit 1
fi

echo "Vérification de l'éligibilité de l'issue #$ISSUE_NUMBER..."
echo ""

# Récupérer le body de l'issue
body=$(gh issue view "$ISSUE_NUMBER" --json body,title,labels --jq '.' 2>/dev/null)

if [ -z "$body" ] || [ "$body" = "null" ]; then
  echo "✗ Issue #$ISSUE_NUMBER introuvable."
  exit 1
fi

title=$(echo "$body" | jq -r '.title')
labels=$(echo "$body" | jq -r '.labels[].name' | tr '\n' ',')
issue_body=$(echo "$body" | jq -r '.body')

echo "Issue : $title"
echo "Labels : $labels"
echo ""

# Vérifier que c'est une issue avec le label "task"
if ! echo "$labels" | grep -q "task"; then
  if echo "$labels" | grep -q "in-progress"; then
    echo "⚠ Cette US est déjà en cours (in-progress)."
    exit 0
  elif echo "$labels" | grep -q "done"; then
    echo "⚠ Cette US est déjà terminée (done)."
    exit 0
  else
    echo "⚠ Cette US n'a pas le label 'task'."
    exit 1
  fi
fi

# Vérifier si aucune dépendance
if echo "$issue_body" | grep -q "Aucune — peut démarrer immédiatement"; then
  echo "✓ Aucune dépendance — US éligible."
  echo ""
  echo "========================================="
  echo "  RÉSULTAT: ÉLIGIBLE ✓"
  echo "========================================="
  exit 0
fi

# Vérifier chaque dépendance
errors=0
checks=0

while IFS= read -r dep_line; do
  if [ -z "$dep_line" ]; then continue; fi

  dep_num=$(echo "$dep_line" | grep -oE '#[0-9]+' | head -1 | tr -d '#')
  if [ -z "$dep_num" ]; then continue; fi

  checks=$((checks + 1))
  dep_title=$(gh issue view "$dep_num" --json title --jq '.title' 2>/dev/null)
  dep_labels=$(gh issue view "$dep_num" --json labels --jq '.labels[].name' 2>/dev/null | tr '\n' ',')

  if echo "$dep_line" | grep -qi "bloquée par\|type: après"; then
    if echo "$dep_labels" | grep -q "done"; then
      echo "✓ Dépendance #$dep_num ($dep_title) — Done"
    else
      echo "✗ Dépendance #$dep_num ($dep_title) — PAS Done (labels: $dep_labels)"
      echo "  → Cette US ne peut pas démarrer tant que #$dep_num n'est pas terminée."
      errors=$((errors + 1))
    fi
  elif echo "$dep_line" | grep -qi "partage le scope\|type: partage"; then
    if echo "$dep_labels" | grep -q "in-progress"; then
      echo "✗ Scope partagé #$dep_num ($dep_title) — EN COURS"
      echo "  → Attendre que #$dep_num soit terminée pour éviter les conflits."
      errors=$((errors + 1))
    else
      echo "✓ Scope partagé #$dep_num ($dep_title) — pas en cours"
    fi
  elif echo "$dep_line" | grep -qi "enrichit\|type: enrichit"; then
    if echo "$dep_labels" | grep -qE "done|in-progress"; then
      echo "✓ Enrichit #$dep_num ($dep_title) — en cours ou Done"
    elif echo "$dep_labels" | grep -q "task"; then
      echo "✗ Enrichit #$dep_num ($dep_title) — pas encore commencée"
      echo "  → Attendre que #$dep_num soit au moins en cours."
      errors=$((errors + 1))
    fi
  fi
done <<< "$(echo "$issue_body" | grep -iE '(bloquée par|partage le scope|enrichit|type:)')"

echo ""
echo "========================================="
if [ "$errors" -eq 0 ]; then
  if [ "$checks" -eq 0 ]; then
    echo "  RÉSULTAT: ÉLIGIBLE ✓ (pas de dépendances détectées)"
  else
    echo "  RÉSULTAT: ÉLIGIBLE ✓ ($checks dépendance(s) satisfaite(s))"
  fi
  echo "========================================="
  exit 0
else
  echo "  RÉSULTAT: BLOQUÉE ✗"
  echo "  $errors dépendance(s) non satisfaite(s)."
  echo "========================================="
  exit 1
fi
