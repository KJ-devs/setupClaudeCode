#!/bin/bash
# protect-files.sh — Bloque l'édition de fichiers sensibles
# Utilisé comme hook PreToolUse sur Edit/Write

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

PROTECTED_PATTERNS=(".env" ".env.local" ".env.production" "package-lock.json" "yarn.lock" "pnpm-lock.yaml" ".git/")

for pattern in "${PROTECTED_PATTERNS[@]}"; do
  if [[ "$FILE_PATH" == *"$pattern"* ]]; then
    echo "Bloqué: $FILE_PATH correspond au pattern protégé '$pattern'. Modifie ce fichier manuellement." >&2
    exit 2
  fi
done

exit 0
