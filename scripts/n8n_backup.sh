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

# Fallback: try to read from 1password if env vars not set
if [[ -z "$API_KEY" ]] && command -v op &>/dev/null; then
    API_KEY=$(op read "op://Private/n8n-api/credential" 2>/dev/null || true)
fi

if [[ -z "$API_KEY" ]]; then
    echo "❌ N8N_API_KEY not set and could not read from 1Password" >&2
    exit 1
fi

mkdir -p "$BACKUP_DIR"

# Fetch all workflows
echo "📡 Fetching workflows from $BASE_URL..."
RESPONSE=$(curl -sf \
    "${BASE_URL}/api/v1/workflows" \
    -H "X-N8N-API-KEY: ${API_KEY}")

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
