#!/bin/bash
# Backup n8n workflows script

cd /home/dain/.openclaw

BACKUP_DIR="/home/dain/.openclaw/workspace/skills/n8n/backups"
DATE=$(date +%Y-%m-%d)
TIME_SLOT=$(date +%H)

export N8N_BASE_URL="${N8N_BASE_URL:-https://n8n.dainbentley.com}"
export N8N_API_KEY="${N8N_API_KEY:-$(cat /home/dain/.openclaw/env/openclaw.json | python3 -c 'import sys,json; print(json.load(sys.stdin).get("auth",{}).get("profiles",{}).get("ollama:default","").get("api_key","") or "invalid")')"

mkdir -p "$BACKUP_DIR"

# Set environment variables for the Python subprocess
export BACKUP_DIR
export N8N_BASE_URL
export N8N_API_KEY

echo "Starting backup..."
python3 -c "
import sys
import json
import os
import gzip
import urllib.request

BACKUP_DIR = os.environ.get('BACKUP_DIR', '/home/dain/.openclaw/workspace/skills/n8n/backups')

try:
    # Fetch all workflows
    url = os.environ.get('N8N_BASE_URL', 'https://n8n.dainbentley.com/api/v1/workflows')
    key = os.environ.get('N8N_API_KEY', '')
    
    req = urllib.request.Request(url, headers={'X-N8N-API-KEY': key})
    with urllib.request.urlopen(req, timeout=30) as response:
        if response.status != 200:
            print(f'Returning {response.status}', file=sys.stderr)
            print(f'Status: {response.status}', file=sys.stderr)
            print(f'Response: {response.read().decode()}')
            sys.exit(1)
        data = response.read()
        workflows = json.loads(data.decode('utf-8'))
        count = len(workflows.get('data', []))
    
    date_str = datetime.now().strftime('%Y-%m-%d_%H-%M')
    backup_dir = BACKUP_DIR
    
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
    
    print(f'Backed up {count} workflows')
    print(f'Snapshot: {snapshot_file}')
    print(f'Individual: {individual_dir}/')
    
except Exception as e:
    print(f'Error: {e}', file=sys.stderr)
    sys.exit(1)
"