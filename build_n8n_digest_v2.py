#!/usr/bin/env python3
"""
Option 2: Webhook-based email digest
- OpenClaw fetches emails, POSTs to N8N webhook
- N8N handles AI categorization + Telegram delivery
"""
import json, requests

with open('/home/dain/.openclaw/openclaw.json') as f:
    config = json.load(f)

gemini_key = config['skills']['entries']['nano-banana-pro']['apiKey']
tg_token = config['channels']['telegram']['botToken']
n8n_key = config['env']['N8N_API_KEY']
n8n_url = config['env']['N8N_BASE_URL']

prompt = (
    "You are an email digest assistant. Categorize the emails below into sections:\n"
    "🔴 VIP: ONLY from julie.a.siegel84@gmail.com or jabentley9@gmail.com\n"
    "🚨 Important: urgent, financial, medical, school-related\n"
    "🟡 Medium: receipts, notifications worth knowing\n"
    "🗑️ Spam: marketing, promotions, job alerts (just list senders, no detail)\n\n"
    "CRITICAL: ONLY report emails that appear in the data below. Do NOT invent emails.\n"
    "Format as a clean readable Telegram message. Include sender + subject for each.\n\n"
    "Emails:\n{{ $json.body.emails }}"
)

workflow = {
    "name": "Email Digest - Webhook",
    "nodes": [
        {
            "id": "node-webhook",
            "name": "Email Webhook",
            "type": "n8n-nodes-base.webhook",
            "typeVersion": 2,
            "position": [0, 0],
            "parameters": {
                "httpMethod": "POST",
                "path": "email-digest",
                "responseMode": "onReceived",
                "responseData": "firstEntryJson"
            },
            "webhookId": "email-digest"
        },
        {
            "id": "node-ai",
            "name": "Categorize with Gemini",
            "type": "n8n-nodes-base.httpRequest",
            "typeVersion": 4.2,
            "position": [240, 0],
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
            "position": [480, 0],
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
            "position": [720, 0],
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
        "Email Webhook": {
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

headers = {"X-N8N-API-KEY": n8n_key, "Content-Type": "application/json"}

# Delete old workflow first
r = requests.delete(f"{n8n_url}/api/v1/workflows/4zpjRR63Fo3JzVe5", headers=headers)
print(f"Deleted old workflow: {r.status_code}")

# Create new one
r = requests.post(f"{n8n_url}/api/v1/workflows", headers=headers, json=workflow)
if r.status_code in (200, 201):
    wf = r.json()
    wf_id = wf.get('id')
    print(f"✓ Workflow created: {wf.get('name')} (id: {wf_id})")

    # Activate it
    r2 = requests.patch(f"{n8n_url}/api/v1/workflows/{wf_id}", headers=headers, json={"active": True})
    if r2.status_code == 200:
        print("✓ Workflow activated")
        webhook_url = f"{n8n_url}/webhook/email-digest"
        print(f"✓ Webhook URL: {webhook_url}")
    else:
        print(f"Activation error: {r2.text[:200]}")
else:
    print(f"ERROR {r.status_code}: {r.text[:300]}")
