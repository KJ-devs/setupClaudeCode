#!/bin/bash
# session-summary.sh — Stop hook: update CLAUDE.local.md with session state
# Tracks: active US, branch, modified files, decisions

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
LOCAL_MD="$PROJECT_DIR/CLAUDE.local.md"

# Get current state
BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
DATE=$(date '+%Y-%m-%d %H:%M')

# Get active US
IN_PROGRESS=""
if command -v gh &> /dev/null; then
  IN_PROGRESS=$(gh issue list --label "in-progress" --json number,title --jq '.[] | "#\(.number) \(.title)"' 2>/dev/null | head -1)
fi

# Get done US count
DONE_COUNT=""
if command -v gh &> /dev/null; then
  DONE_COUNT=$(gh issue list --state closed --label "done" --json number --jq 'length' 2>/dev/null)
fi

# Get remaining US count
REMAINING=""
if command -v gh &> /dev/null; then
  REMAINING=$(gh issue list --label "task" --json number --jq 'length' 2>/dev/null)
fi

# Get modified files in this session (last 2 hours of commits)
MODIFIED_FILES=$(git log --since="2 hours ago" --name-only --pretty=format: 2>/dev/null | sort -u | grep -v '^$' | head -20)

# Update CLAUDE.local.md if it exists
if [ -f "$LOCAL_MD" ]; then
  # Create temp file with updated content
  {
    echo "# État de session local (gitignored)"
    echo ""
    echo "> Ce fichier persiste entre les sessions Claude Code pour ce projet."
    echo "> Il est automatiquement ignoré par git."
    echo ""
    echo "## Sprint en cours"
    echo ""
    if [ -n "$IN_PROGRESS" ]; then
      echo "- **US active** : $IN_PROGRESS"
    else
      echo "- **US active** : aucune"
    fi
    echo "- **Branche** : \`$BRANCH\`"
    echo "- **Dernière mise à jour** : $DATE"
    if [ -n "$DONE_COUNT" ]; then
      echo "- **US terminées** : $DONE_COUNT"
    fi
    if [ -n "$REMAINING" ]; then
      echo "- **US restantes** : $REMAINING"
    fi
    echo ""

    # Preserve decisions and notes sections from existing file
    if grep -q "## Décisions prises" "$LOCAL_MD"; then
      sed -n '/## Décisions prises/,/^## [^D]/p' "$LOCAL_MD" | head -n -1
    else
      echo "## Décisions prises"
      echo ""
      echo "<!-- [Date] Description de la décision -->"
      echo ""
    fi

    if grep -q "## Problèmes connus" "$LOCAL_MD"; then
      sed -n '/## Problèmes connus/,/^## [^P]/p' "$LOCAL_MD" | head -n -1
    else
      echo "## Problèmes connus"
      echo ""
      echo "<!-- Description du problème → contournement -->"
      echo ""
    fi

    echo "## Notes de session"
    echo ""
    echo "### Session du $DATE"
    echo ""
    if [ -n "$MODIFIED_FILES" ]; then
      echo "**Fichiers modifiés :**"
      echo "$MODIFIED_FILES" | while read -r f; do
        [ -n "$f" ] && echo "- \`$f\`"
      done
      echo ""
    fi
    if [ -n "$IN_PROGRESS" ]; then
      echo "**US en cours** : $IN_PROGRESS"
    fi
    echo ""

  } > "${LOCAL_MD}.tmp"

  mv "${LOCAL_MD}.tmp" "$LOCAL_MD"
fi

exit 0
