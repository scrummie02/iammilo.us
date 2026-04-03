#!/usr/bin/env bash
# Syncs MILO brain files to Google Drive AI/MILO folder
# Runs nightly at 2:30 AM

CORE_ID="1fERHnBTJlZa614S_vGTQLrLMh-1AKk8X"
MEMORY_ID="1hwbC_tGHiy9nXueyCJz37wqSQFLvzyUO"
WS="/home/dain/.openclaw/workspace"
GOG="gog"
ERRORS=0
UPLOADED=0

upload() {
  local file="$1"
  local parent="$2"
  local name=$(basename "$file")
  if [ -f "$file" ]; then
    # Check if file exists on Drive and delete it first (overwrite)
    EXISTING=$($GOG drive search "name = '$name' and '$parent' in parents" --json 2>/dev/null | python3 -c "import sys,json; files=json.load(sys.stdin).get('files',[]); print(files[0]['id'] if files else '')" 2>/dev/null)
    [ -n "$EXISTING" ] && $GOG drive rm "$EXISTING" --force --json > /dev/null 2>&1
    $GOG drive upload "$file" --parent "$parent" --json > /dev/null 2>&1 && UPLOADED=$((UPLOADED+1)) || ERRORS=$((ERRORS+1))
  fi
}

# Core files
for f in SOUL.md IDENTITY.md USER.md MEMORY.md AGENTS.md TOOLS.md ROUTING.md HEARTBEAT.md; do
  upload "$WS/$f" "$CORE_ID"
done

# Memory files
for f in "$WS/memory/"*.md; do
  upload "$f" "$MEMORY_ID"
done

echo "Drive brain sync complete: $UPLOADED uploaded, $ERRORS errors"
