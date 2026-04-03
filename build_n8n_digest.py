#!/usr/bin/env python3
import json, requests

with open('/home/dain/.openclaw/openclaw.json') as f:
    config = json.load(f)

gemini_key = config['skills']['entries']['nano-banana-pro']['apiKey']
tg_token = config['channels']['telegram']['botToken']
n8n_key = config['env']['N8N_API_KEY']
n8n_url = config['env']['N8N_BASE_URL']

prompt = (
    "You are an email digest assistant. Categorize the emails below into sections:\n"
    "🔴 VIP: from julie.a.siegel84@gmail.com or jabentley9@gmail.com ONLY\n"
    "🚨 Important: urgent, financial, medical, school-related\n"
    "🟡 Medium: receipts, notifications, newsletters worth knowing\n"
    "🗑️ Spam: marketing, promotions, job alerts\n\n"
    "CRITICAL: ONLY report emails that appear in the data below. Do NOT invent or hallucinate any emails.\n"
    "Format as a clean readable digest. List sender and subject for each.\n\n"
    "Emails:\n{{ $json.stdout }}"
)

workflow = {
    "name": "Email Digest - Personal",
    "nodes": [
        {
            "id": "node-schedule",
            "name": "Schedule 7AM & 4PM",
            "type": "n8n-nodes-base.scheduleTrigger",
            "typeVersion": 1.2,
            "position": [0, 0],
            "parameters": {
                "rule": {
                    "interval": [
                        {"field": "cronExpression", "expression": "0 7 * * *"},
                        {"field": "cronExpression", "expression": "0 16 * * *"}
                    ]
                }
            }
        },
        {
            "id": "node-fetch",
            "name": "Fetch Emails",
            "type": "n8n-nodes-base.executeCommand",
            "typeVersion": 1,
            "position": [240, 0],
            "parameters": {
                "command": "GOG_KEYRING_PASSWORD=milo-gog-keyring /home/linuxbrew/.linuxbrew/bin/gog gmail search \"in:inbox newer_than:1d\" --account=dain.bentley@gmail.com --max 50 --plain 2>/dev/null"
            }
        },
        {
            "id": "node-ai",
            "name": "Categorize with Gemini",
            "type": "n8n-nodes-base.httpRequest",
            "typeVersion": 4.2,
            "position": [480, 0],
            "parameters": {
                "method": "POST",
                "url": f"https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key={gemini_key}",
                "sendHeaders": True,
                "headerParameters": {
                    "parameters": [{"name": "Content-Type", "value": "application/json"}]
                },
                "sendBody": True,
                "contentType": "raw",
                "rawContentType": "application/json",
                "body": json.dumps({
                    "contents": [{"parts": [{"text": prompt}]}]
                })
            }
        },
        {
            "id": "node-extract",
            "name": "Extract Text",
            "type": "n8n-nodes-base.code",
            "typeVersion": 2,
            "position": [720, 0],
            "parameters": {
                "jsCode": (
                    "const resp = $input.first().json;\n"
                    "const text = resp?.candidates?.[0]?.content?.parts?.[0]?.text || 'No digest available';\n"
                    "const time = new Date().getHours() < 12 ? 'Morning' : 'Afternoon';\n"
                    "return [{json: {message: `📬 *Email Digest — ${time}*\\n\\n${text}`}}];"
                )
            }
        },
        {
            "id": "node-telegram",
            "name": "Send to Telegram",
            "type": "n8n-nodes-base.httpRequest",
            "typeVersion": 4.2,
            "position": [960, 0],
            "parameters": {
                "method": "POST",
                "url": f"https://api.telegram.org/bot{tg_token}/sendMessage",
                "sendBody": True,
                "contentType": "json",
                "body": json.dumps({
                    "chat_id": "8305133249",
                    "text": "={{ $json.message }}",
                    "parse_mode": "Markdown"
                })
            }
        }
    ],
    "connections": {
        "Schedule 7AM & 4PM": {
            "main": [[{"node": "Fetch Emails", "type": "main", "index": 0}]]
        },
        "Fetch Emails": {
            "main": [[{"node": "Categorize with Gemini", "type": "main", "index": 0}]]
        },
        "Categorize with Gemini": {
            "main": [[{"node": "Extract Text", "type": "main", "index": 0}]]
        },
        "Extract Text": {
            "main": [[{"node": "Send to Telegram", "type": "main", "index": 0}]]
        }
    },
    "settings": {"executionOrder": "v1"}
}

headers = {
    "X-N8N-API-KEY": n8n_key,
    "Content-Type": "application/json"
}

r = requests.post(f"{n8n_url}/api/v1/workflows", headers=headers, json=workflow)
if r.status_code in (200, 201):
    wf = r.json()
    print(f"✓ Workflow created: {wf.get('name')} (id: {wf.get('id')})")
else:
    print(f"ERROR {r.status_code}: {r.text[:300]}")
