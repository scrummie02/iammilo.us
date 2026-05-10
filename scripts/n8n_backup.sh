#!/bin/bash
# n8n Workflow Backup Script
# Usage: run via cron or manually
# Exports: N8N_BASE_URL, N8N_API_KEY

BACKUP_DIR="/home/dain/.openclaw/workspace/skills/n8n/backups"
DATE=$(date +%Y-%m-%d)
TIME_SLOT=$(date +%H)
BACKUP_FILE="${BACKUP_DIR}/workflows_${DATE}.json.gz"

mkdir -p "$BACKUP_DIR"

# Fetch all workflows and process
curl -sf "${N8N_BASE_URL}/api/v1/workflows" \
  -H "X-N8N-API-KEY: $N8N_API_KEY" | python3 -c "
import sys, json, os, gzip
from datetime import datetime

data = json.load(sys.stdin)
workflows = data.get('data', [])
count = len(workflows)
date_str = datetime.now().strftime('%Y-%m-%d_%H-%M')
backup_dir = os.environ.get('BACKUP_DIR', '/home/dain/.openclaw/workspace/skills/n8n/backups')

# Save full snapshot as compressed JSON
snapshot_file = os.path.join(backup_dir, f'workflows_{date_str}.json.gz')
with gzip.open(snapshot_file, 'wt', encoding='utf-8') as f:
    json.dump(workflows, f, indent=2)

# Also save individual workflow files
individual_dir = os.path.join(backup_dir, date_str.split('_')[0])
os.makedirs(individual_dir, exist_ok=True)
for wf in workflows:
    name = wf.get('name', f'workflow_{wf.get(\"id\", \"unknown\")}')
    safe_name = ''.join(c if c.isalnum() or c in '-_ ' else '_' for c in name)
    fname = os.path.join(individual_dir, f'{safe_name}.json')
    with open(fname, 'w', encoding='utf-8') as f:
        json.dump(wf, f, indent=2)

print(f'✅ Backed up {count} workflows')
print(f'   Snapshot: {snapshot_file}')
print(f'   Individual: {individual_dir}/')
" 2>&1
