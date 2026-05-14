#!/bin/bash
# backup_openclaw.sh — backs up OpenClaw workspace to NFS share
# Target: 192.168.200.224:/data/Backups/cachyOS/openclaw

WORKSPACE="/home/dain/.openclaw/workspace"
TIMESTAMP=$(date +%Y-%m-%d_%H%M)
PRIMARY="/mnt/backups/cachyos/openclaw"
SECONDARY_HOST="192.168.200.226"
SECONDARY_PATH="/data/Backups/cachyOS/openclaw"

# Export n8n workflows to markdown + JSON before backup
echo "Exporting n8n workflows..."
python3 "$WORKSPACE/n8n-workflows/export.py" 2>/dev/null && echo "✓ n8n workflows exported" || echo "⚠ n8n export skipped"

# Check mount, fall back to secondary if primary unavailable
if mountpoint -q /mnt/backups && touch "$PRIMARY/.write_test" 2>/dev/null; then
  rm -f "$PRIMARY/.write_test"
  DEST="$PRIMARY"
  echo "Using primary backup: $DEST"
else
  echo "Primary unavailable, falling back to secondary ($SECONDARY_HOST)..."
  DEST="$WORKSPACE/.backup_tmp_$$"
  mkdir -p "$DEST"
  USE_SECONDARY=1
fi

# Sync workspace
rsync -a --delete \
  "$WORKSPACE/" \
  "$DEST/workspace/" \
  --exclude=".git" \
  --exclude="__pycache__" \
  --exclude="*.pyc" \
  --exclude="target/" \
  --exclude="node_modules/" \
  --exclude=".venv/" \
  --exclude="venv/" \
  --exclude="*.tar" \
  --exclude="*.tar.gz" \
  --exclude="*.zip"

# Back up session logs (chat history)
rsync -a \
  "/home/dain/.openclaw/agents/main/sessions/" \
  "$DEST/sessions/" \
  --include="*.jsonl" --exclude="*"

# Back up cron config
openclaw cron list --json > "$DEST/cron_backup_${TIMESTAMP}.json" 2>/dev/null

# If using secondary, rsync to remote host
if [ "${USE_SECONDARY:-0}" = "1" ]; then
  rsync -av --delete "$DEST/" "${SECONDARY_HOST}:${SECONDARY_PATH}/" 2>&1
  rm -rf "$DEST"
  echo "✓ Backup complete (secondary): $TIMESTAMP"
else
  echo "✓ Backup complete (primary): $TIMESTAMP"
fi
