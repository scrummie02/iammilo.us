#!/bin/bash
# n8n Workflow Backup Script
# Usage: run via cron or manually
# Requires: N8N_BASE_URL, N8N_API_KEY from environment or OpenClaw secrets

set -euo pipefail

# Configuration
BACKUP_DIR="${BACKUP_DIR:-/mnt/backups/cachyos/openclaw/n8n}"
DATE=$(date +%Y-%m-%d)
TIME_SLOT=$(date +%H)
API_KEY="${N8N_API_KEY:-}"
BASE_URL="${N8N_BASE_URL:-http://localhost:5678}"

# OpenClaw settings fallback
if [[ -z "$API_KEY" ]] && [[ -f /home/dain/.openclaw/openclaw.json ]]; then
    API_KEY=$(jq -r '.env.N8N_API_KEY // empty' /home/dain/.openclaw/openclaw.json 2>/dev/null || true)
fi
if [[ -z "$BASE_URL" ]] && [[ -f /home/dain/.openclaw/openclaw.json ]]; then
    BASE_URL=$(jq -r '.env.N8N_BASE_URL // empty' /home/dain/.openclaw/openclaw.json 2>/dev/null || true)
fi

# Fallback: try to read from 1password if env vars not set
if [[ -z "$API_KEY" ]] && command -v op &>/dev/null; then
    API_KEY=$(op read "op://Private/n8n-api/credential" 2>/dev/null || true)
fi

if [[ -z "$API_KEY" ]]; then
    echo "❌ N8N_API_KEY not set" >&2
    exit 1
fi

mkdir -p "$BACKUP_DIR"

# Fetch all workflows
echo "📡 Fetching workflows from $BASE_URL..."
# Diagnostic: print first/last 10 chars of API key for debugging (never log full key)
KEY_LEN=${#API_KEY}
if [[ $KEY_LEN -gt 20 ]]; then
    echo "🔑 API key length: $KEY_LEN chars"
else
    echo "⚠️ API key seems short ($KEY_LEN chars)"
fi
RESPONSE=$(curl -sf \
    "${BASE_URL}/api/v1/workflows" \
    -H "X-N8N-API-KEY: ${API_KEY}" 2>&1) || {
    echo "❌ API call failed. Response:"
    echo "$RESPONSE"
    curl -sf \
        "${BASE_URL}/api/v1/workflows" \
        -H "X-N8N-API-KEY: ${API_KEY}" \
        -w "\nHTTP_CODE: %{http_code}\n" 2>/dev/null || true
    exit 1
}

# Verify response is valid JSON with data
if ! echo "$RESPONSE" | jq empty &>/dev/null; then
    echo "❌ API response is not valid JSON. Raw response:"
    echo "$RESPONSE"
    exit 1
fi

if ! echo "$RESPONSE" | jq -e '.data' &>/dev/null; then
    echo "❌ API response missing 'data' field. Response:"
    echo "$RESPONSE"
    exit 1
fi

WORKFLOW_COUNT=$(echo "$RESPONSE" | jq '.data | length')
echo "📊 Found $WORKFLOW_COUNT workflows"

# Save full snapshot
SNAPSHOT_FILE="${BACKUP_DIR}/workflows_${DATE}_${TIME_SLOT}.json.gz"
echo "$RESPONSE" | gzip > "$SNAPSHOT_FILE"

# Save individual workflow files
INDIVIDUAL_DIR="${BACKUP_DIR}/${DATE}_${TIME_SLOT}"
mkdir -p "$INDIVIDUAL_DIR"

echo "$RESPONSE" | jq -c '.data[]' | while read -r workflow; do
    ID=$(echo "$workflow" | jq -r '.id')
    NAME=$(echo "$workflow" | jq -r '.name')
    SAFE_NAME=$(echo "$NAME" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/_/g')
    
    # Fetch full workflow details
    FULL_WF=$(curl -sf \
        "${BASE_URL}/api/v1/workflows/${ID}" \
        -H "X-N8N-API-KEY: ${API_KEY}")
    
    echo "$FULL_WF" | jq . > "${INDIVIDUAL_DIR}/${ID}_${SAFE_NAME}.json"
    echo "  💾 $NAME"
done

# Cleanup old backups (keep 14 days)
find "$BACKUP_DIR" -name "workflows_*.json.gz" -mtime +14 -delete 2>/dev/null || true
find "$BACKUP_DIR" -maxdepth 1 -type d -name "*_??" -mtime +14 -exec rm -rf {} + 2>/dev/null || true

echo "✅ Backup complete: $SNAPSHOT_FILE"
echo "   Individual files: $INDIVIDUAL_DIR"
