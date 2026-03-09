#!/usr/bin/env python3
"""
n8n-workflows/export.py
Exports all active n8n workflows to individual JSON files + README.md.
Run manually or automatically via backup_openclaw.sh before each backup.
"""
import json, requests, os, sys
from datetime import datetime

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
CONFIG_PATH = '/home/dain/.openclaw/openclaw.json'

with open(CONFIG_PATH) as f:
    config = json.load(f)

n8n_key = config['env']['N8N_API_KEY']
n8n_url = config['env']['N8N_BASE_URL']
headers = {'X-N8N-API-KEY': n8n_key}

r = requests.get(f'{n8n_url}/api/v1/workflows', headers=headers)
if r.status_code != 200:
    print(f"ERROR: Could not reach n8n ({r.status_code})", file=sys.stderr)
    sys.exit(1)

workflows = [w for w in r.json()['data'] if not w.get('isArchived')]
exported = datetime.now().strftime('%Y-%m-%d %H:%M')

md_lines = [
    '# N8N Workflows\n',
    f'*Last exported: {exported}*  \n',
    f'*Instance: {n8n_url}*\n\n',
    '> To restore a workflow: go to n8n → Workflows → Import → paste the JSON file below.\n\n---\n\n',
]

for wf in workflows:
    wf_id = wf['id']
    name = wf['name']
    active = wf.get('active', False)

    wr = requests.get(f'{n8n_url}/api/v1/workflows/{wf_id}', headers=headers)
    full = wr.json()

    safe_name = name.lower().replace(' ', '_').replace('/', '-').replace('(', '').replace(')', '')
    json_path = os.path.join(SCRIPT_DIR, f'{safe_name}.json')
    with open(json_path, 'w') as f:
        json.dump(full, f, indent=2)

    nodes = full.get('nodes', [])
    node_list = '\n'.join([f"  - `{n['type']}` — **{n['name']}**" for n in nodes])

    # Find schedule expression
    schedule_expr = None
    for n in nodes:
        if 'schedule' in n['type'].lower():
            interval = n.get('parameters', {}).get('rule', {}).get('interval', [{}])
            schedule_expr = interval[0].get('expression') if interval else None
            break

    md_lines.append(f"## {name}\n\n")
    md_lines.append(f"| Field | Value |\n|---|---|\n")
    md_lines.append(f"| **ID** | `{wf_id}` |\n")
    md_lines.append(f"| **Status** | {'🟢 Active' if active else '🔴 Inactive'} |\n")
    if schedule_expr:
        md_lines.append(f"| **Schedule** | `{schedule_expr}` |\n")
    md_lines.append(f"| **Backup file** | `{safe_name}.json` |\n\n")
    md_lines.append(f"**Nodes ({len(nodes)}):**\n{node_list}\n\n")
    md_lines.append(f"<details>\n<summary>Full JSON config</summary>\n\n```json\n{json.dumps(full, indent=2)}\n```\n\n</details>\n\n---\n\n")

readme_path = os.path.join(SCRIPT_DIR, 'README.md')
with open(readme_path, 'w') as f:
    f.write(''.join(md_lines))

print(f"Exported {len(workflows)} workflows:")
for wf in workflows:
    print(f"  {'✓' if wf.get('active') else '○'} {wf['name']}")
print(f"README: {readme_path}")
