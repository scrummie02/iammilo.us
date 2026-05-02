import os
import json
import requests

def fix_workflow(workflow_id):
    url = f"https://n8n.dainbentley.com/api/v1/workflows/{workflow_id}"
    headers = {"X-N8N-API-KEY": os.environ["N8N_API_KEY"]}
    r = requests.get(url, headers=headers)
    wf = r.json()

    for node in wf.get("nodes", []):
        if node["name"] == "Check DB":
            node["parameters"]["jsCode"] = """const message = $input.first().json.message;

// Pure JS simple string hash to avoid the 'crypto' module restriction in n8n code nodes
function simpleHash(str) {
  let hash = 0;
  for (let i = 0; i < str.length; i++) {
    const char = str.charCodeAt(i);
    hash = ((hash << 5) - hash) + char;
    hash = hash & hash;
  }
  return Math.abs(hash).toString(16);
}

const hash = simpleHash(message);

const staticData = $getWorkflowStaticData('global');
if (!staticData.sentHashes) staticData.sentHashes = [];

const found = staticData.sentHashes.includes(hash);
return [{ json: { id: found ? hash : '', hash: hash, message: message } }];"""

    payload = {
        "name": wf.get("name"),
        "nodes": wf.get("nodes"),
        "connections": wf.get("connections"),
        "settings": wf.get("settings", {})
    }

    r = requests.put(url, headers=headers, json=payload)
    print(f"Fixed {workflow_id}: {r.status_code}")

fix_workflow("m7EMbjBDyv2MMCBo") # Dad Joke
fix_workflow("AjAjjxb9j94iE0JK") # Daily Fact