#!/bin/bash
# Blocks al_build after 3 attempts per chat session.
# Runs as a PreToolUse hook from the al-build-loop agent's frontmatter.
# Reads the hook input with sed, so jq is not required.
LIMIT=3
STATE_DIR="${TMPDIR:-/tmp}/mb-al-loop-demo"
mkdir -p "$STATE_DIR"

INPUT=$(cat)
field() {
  printf '%s' "$INPUT" | sed -n "s/.*\"$1\"[[:space:]]*:[[:space:]]*\"\([^\"]*\)\".*/\1/p" | head -n 1
}
TOOL_NAME=$(field tool_name)
# The session ID becomes a file name, so keep only safe characters.
SESSION_ID=$(field session_id | tr -cd 'A-Za-z0-9._-')
SESSION_ID=${SESSION_ID:-default}

# Other tools: return no decision, so the normal approval flow applies.
case "$TOOL_NAME" in
  al_build|*/al_build) ;;
  *) exit 0 ;;
esac

STATE_FILE="$STATE_DIR/$SESSION_ID.count"
COUNT=0
if [ -f "$STATE_FILE" ]; then
  COUNT=$(cat "$STATE_FILE")
fi
COUNT=$((COUNT + 1))
echo "$COUNT" > "$STATE_FILE"

if [ "$COUNT" -gt "$LIMIT" ]; then
  echo "{\"hookSpecificOutput\":{\"hookEventName\":\"PreToolUse\",\"permissionDecision\":\"deny\",\"permissionDecisionReason\":\"Attempt limit ($LIMIT) reached. The loop stopped. Review the last error and fix it by hand.\"}}"
  exit 0
fi

echo "{\"hookSpecificOutput\":{\"hookEventName\":\"PreToolUse\",\"additionalContext\":\"Attempt $COUNT of $LIMIT.\"}}"
exit 0
