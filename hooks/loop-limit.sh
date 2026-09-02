#!/bin/bash
# Blocks al_build after 3 attempts per chat session.
LIMIT=3
STATE_DIR="${TMPDIR:-/tmp}/mb-al-loop-demo"
mkdir -p "$STATE_DIR"

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name')
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "default"')

if [ "$TOOL_NAME" != "al_build" ]; then
  echo '{"hookSpecificOutput":{"permissionDecision":"allow"}}'
  exit 0
fi

STATE_FILE="$STATE_DIR/$SESSION_ID.count"
COUNT=0
if [ -f "$STATE_FILE" ]; then
  COUNT=$(cat "$STATE_FILE")
fi
COUNT=$((COUNT + 1))
echo "$COUNT" > "$STATE_FILE"

if [ "$COUNT" -gt "$LIMIT" ]; then
  echo "{\"hookSpecificOutput\":{\"permissionDecision\":\"deny\",\"permissionDecisionReason\":\"Attempt limit ($LIMIT) reached. The loop stopped. Review the last error and fix it by hand.\"}}"
  exit 0
fi

echo "{\"hookSpecificOutput\":{\"permissionDecision\":\"allow\",\"additionalContext\":\"Attempt $COUNT of $LIMIT.\"}}"
exit 0
