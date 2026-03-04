#!/bin/bash
# auto-format.sh — PostToolUse hook on Edit|Write: auto-format files after editing
# Detects the formatter available and applies it to the modified file

INPUT=$(cat)
TOOL=$(echo "$INPUT" | jq -r '.tool_name')

# Only run after Write or Edit operations
if [[ "$TOOL" != "Write" && "$TOOL" != "Edit" ]]; then
  exit 0
fi

FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // empty')

if [[ -z "$FILE" || "$FILE" == "null" || ! -f "$FILE" ]]; then
  exit 0
fi

# Get file extension
EXT="${FILE##*.}"

case "$EXT" in
  js|jsx|ts|tsx|json|css|scss|md|html|vue|svelte)
    # Format with Prettier if available in project
    if [[ -f "node_modules/.bin/prettier" ]]; then
      npx prettier --write "$FILE" 2>/dev/null
    fi
    ;;
  py)
    if command -v black &> /dev/null; then
      black --quiet "$FILE" 2>/dev/null
    elif command -v ruff &> /dev/null; then
      ruff format "$FILE" 2>/dev/null
    fi
    ;;
  go)
    if command -v gofmt &> /dev/null; then
      gofmt -w "$FILE" 2>/dev/null
    fi
    ;;
  rs)
    if command -v rustfmt &> /dev/null; then
      rustfmt "$FILE" 2>/dev/null
    fi
    ;;
esac

exit 0
