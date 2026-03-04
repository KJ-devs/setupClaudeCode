#!/bin/bash
# git-safety.sh — PreToolUse hook on Bash: enforce git rules automatically
# Blocks: git merge, git push --force, force push to main, bad branch/commit names
# Also detects secrets in commands

INPUT=$(cat)
TOOL=$(echo "$INPUT" | jq -r '.tool_name')

if [[ "$TOOL" != "Bash" ]]; then
  exit 0
fi

COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command')

# ============================================================
# 1. Block git merge (except merge-base)
# ============================================================
if echo "$COMMAND" | grep -qE "git\s+merge\s+" && ! echo "$COMMAND" | grep -q "merge-base"; then
  echo "BLOQUÉ: 'git merge' interdit. Utilise 'git rebase' pour intégrer les changements." >&2
  exit 2
fi

# ============================================================
# 2. Block git push --force (allow --force-with-lease)
# ============================================================
if echo "$COMMAND" | grep -qE "git\s+push\s+.*--force" && ! echo "$COMMAND" | grep -q "\-\-force-with-lease"; then
  echo "BLOQUÉ: 'git push --force' interdit. Utilise '--force-with-lease'." >&2
  exit 2
fi

# ============================================================
# 3. Block push directly to main/master
# ============================================================
if echo "$COMMAND" | grep -qE "git\s+push\s+.*\s+(main|master)\s*$"; then
  echo "BLOQUÉ: push direct vers main/master interdit. Crée une branche et une PR." >&2
  exit 2
fi

# ============================================================
# 4. Block destructive operations
# ============================================================
DESTRUCTIVE_PATTERNS=(
  "rm -rf /"
  "rm -rf ~"
  "rm -rf \."
  "dd if="
  "mkfs\."
  ":(){ :|:& };:"
  "> /dev/sd"
  "chmod -R 777 /"
  "git clean -fdx"
)

for PATTERN in "${DESTRUCTIVE_PATTERNS[@]}"; do
  if echo "$COMMAND" | grep -qF "$PATTERN"; then
    echo "BLOQUÉ: Commande destructive détectée: '$PATTERN'" >&2
    exit 2
  fi
done

# ============================================================
# 5. Detect secrets in commands
# ============================================================
SECRET_PATTERNS=(
  "password="
  "PASSWORD="
  "secret="
  "SECRET="
  "api_key="
  "API_KEY="
  "apikey="
  "PRIVATE_KEY="
  "aws_access_key"
  "AWS_ACCESS_KEY"
  "aws_secret"
  "AWS_SECRET"
)

for PATTERN in "${SECRET_PATTERNS[@]}"; do
  if echo "$COMMAND" | grep -qi "$PATTERN"; then
    echo "BLOQUÉ: Secret potentiel détecté dans la commande: '$PATTERN'" >&2
    exit 2
  fi
done

# Detect hardcoded API keys (sk-..., pk_..., long hex strings)
if echo "$COMMAND" | grep -qE "(sk-[a-zA-Z0-9]{20,}|pk_[a-zA-Z0-9]{20,}|ghp_[a-zA-Z0-9]{20,})"; then
  echo "BLOQUÉ: Clé API potentielle détectée dans la commande." >&2
  exit 2
fi

# ============================================================
# 6. Block npm/yarn publish without confirmation
# ============================================================
if echo "$COMMAND" | grep -qE "(npm|yarn|pnpm)\s+publish"; then
  echo "BLOQUÉ: Publication de package détectée. Confirmez manuellement." >&2
  exit 2
fi

# All checks passed
exit 0
