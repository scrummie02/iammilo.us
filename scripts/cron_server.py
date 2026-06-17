#!/usr/bin/env python3
"""
MILO Cron Manager - Lightweight web UI for managing OpenClaw cron jobs.
Serves cron-manager.html and proxies API calls to the OpenClaw gateway.

Usage:
    python3 cron_server.py          # Runs on port 8765 by default
    python3 cron_server.py 8080     # Runs on custom port

Requires: OPENCLAW_GATEWAY_URL and OPENCLAW_GATEWAY_TOKEN env vars,
          or reads from ~/.openclaw/config.json
"""

import os
import sys
import json
import http.client
import urllib.parse
from http.server import HTTPServer, BaseHTTPRequestHandler

# ---------------------------------------------------------------------------
# Config discovery
# ---------------------------------------------------------------------------

def load_config():
    """Try to find gateway URL + token from env or config file."""
    url = os.environ.get("OPENCLAW_GATEWAY_URL")
    token = os.environ.get("OPENCLAW_GATEWAY_TOKEN")
    if url and token:
        return url, token
    cfg_path = os.path.expanduser("~/.openclaw/config.json")
    if os.path.exists(cfg_path):
        try:
            with open(cfg_path, "r") as f:
                data = json.load(f)
            url = url or data.get("gatewayUrl")
            token = token or data.get("gatewayToken")
        except Exception:
            pass
    return url, token

GATEWAY_URL, GATEWAY_TOKEN = load_config()

# ---------------------------------------------------------------------------
# HTML UI (embedded so it's one file)
# ---------------------------------------------------------------------------

HTML_PAGE = '''<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>MILO Cron Manager</title>
<style>
  *, *::before, *::after { box-sizing: border-box; }
  :root {
    --bg: #0a0a0a;
    --surface: #121212;
    --border: #333;
    --green: #33ff00;
    --cyan: #00ccff;
    --orange: #ffaa00;
    --red: #ff3333;
    --text: #d1d1d1;
    --muted: #888;
  }
  body {
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    background: var(--bg);
    color: var(--text);
    margin: 0;
    padding: 2rem;
    line-height: 1.6;
  }
  h1 {
    color: var(--green);
    border-bottom: 2px solid var(--green);
    padding-bottom: 0.5rem;
    font-size: 1.8rem;
    letter-spacing: 1px;
    margin-top: 0;
  }
  h2 { color: #fff; font-size: 1.3rem; margin-top: 2rem; }
  nav { margin-bottom: 2rem; }
  nav a {
    color: var(--green);
    text-decoration: none;
    border: 1px solid var(--green);
    padding: 8px 20px;
    border-radius: 4px;
    font-family: monospace;
    font-weight: bold;
    display: inline-block;
  }
  nav a:hover { background: var(--green); color: #000; }

  /* Job list */
  .job-list { display: flex; flex-direction: column; gap: 1rem; margin-top: 1rem; }
  .job-card {
    background: var(--surface);
    border: 1px solid var(--border);
    border-radius: 12px;
    padding: 1.25rem;
    transition: border-color 0.2s, transform 0.2s;
  }
  .job-card:hover { border-color: var(--green); transform: translateY(-2px); }
  .job-card.disabled { opacity: 0.6; border-color: #444; }
  .job-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    flex-wrap: wrap;
    gap: 0.5rem;
    margin-bottom: 0.75rem;
  }
  .job-name { color: #fff; font-weight: bold; font-size: 1.1rem; }
  .job-id { font-family: monospace; font-size: 0.75rem; color: var(--muted); }
  .badge {
    font-size: 0.7rem;
    text-transform: uppercase;
    padding: 4px 10px;
    border-radius: 4px;
    font-weight: bold;
    font-family: monospace;
  }
  .badge.enabled { background: #004400; color: var(--green); }
  .badge.disabled { background: #444; color: #aaa; }
  .badge.ok { background: #004400; color: var(--green); }
  .badge.error { background: #440000; color: var(--red); }
  .badge.running { background: #004444; color: var(--cyan); }
  .job-meta {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
    gap: 0.5rem;
    font-size: 0.85rem;
    color: var(--muted);
  }
  .job-meta span strong { color: var(--text); }
  .job-actions { margin-top: 1rem; display: flex; gap: 0.5rem; flex-wrap: wrap; }
  .btn {
    border: 1px solid var(--border);
    background: transparent;
    color: var(--text);
    padding: 6px 14px;
    border-radius: 4px;
    cursor: pointer;
    font-family: monospace;
    font-size: 0.8rem;
    transition: all 0.15s;
  }
  .btn:hover { background: #222; }
  .btn.run { border-color: var(--green); color: var(--green); }
  .btn.run:hover { background: var(--green); color: #000; }
  .btn.delete { border-color: var(--red); color: var(--red); }
  .btn.delete:hover { background: var(--red); color: #000; }
  .btn.toggle { border-color: var(--orange); color: var(--orange); }
  .btn.toggle:hover { background: var(--orange); color: #000; }
  .btn.primary {
    background: var(--green);
    color: #000;
    border-color: var(--green);
    font-weight: bold;
    padding: 10px 24px;
  }
  .btn.primary:hover { background: #2ee800; }

  /* Form */
  .form-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
    gap: 1rem;
    margin-top: 1rem;
  }
  .field { display: flex; flex-direction: column; gap: 0.35rem; }
  .field label { font-size: 0.8rem; color: var(--muted); text-transform: uppercase; font-weight: bold; }
  input, select, textarea {
    background: #1a1a1a;
    border: 1px solid var(--border);
    color: #fff;
    padding: 10px 12px;
    border-radius: 6px;
    font-family: monospace;
    font-size: 0.9rem;
  }
  input:focus, select:focus, textarea:focus { outline: none; border-color: var(--green); }
  textarea { min-height: 80px; resize: vertical; }
  .field-hint { font-size: 0.75rem; color: #555; }

  /* Toast / status */
  #toast {
    position: fixed;
    bottom: 2rem;
    right: 2rem;
    padding: 1rem 1.5rem;
    border-radius: 8px;
    font-family: monospace;
    font-weight: bold;
    opacity: 0;
    transform: translateY(20px);
    transition: all 0.3s;
    z-index: 100;
    max-width: 400px;
  }
  #toast.show { opacity: 1; transform: translateY(0); }
  #toast.success { background: #004400; color: var(--green); border: 1px solid var(--green); }
  #toast.error { background: #440000; color: var(--red); border: 1px solid var(--red); }
  #toast.info { background: #001a33; color: var(--cyan); border: 1px solid var(--cyan); }

  .empty-state { text-align: center; padding: 3rem; color: var(--muted); }
  .spinner { display: inline-block; width: 14px; height: 14px; border: 2px solid var(--green); border-top-color: transparent; border-radius: 50%; animation: spin 0.8s linear infinite; margin-right: 6px; vertical-align: middle; }
  @keyframes spin { to { transform: rotate(360deg); } }
  .hidden { display: none !important; }
</style>
</head>
<body>
<nav><a href="/index.html">Home</a></nav>
<h1>MILO CRON MANAGER</h1>
<p style="color:var(--muted);margin-top:-0.5rem;">View, create, and manage OpenClaw cron jobs.</p>

<section>
  <h2>&gt; Active_Jobs <span class="spinner hidden" id="listSpinner"></span></h2>
  <div id="jobList" class="job-list">
    <div class="empty-state">Loading jobs...</div>
  </div>
</section>

<section>
  <h2>&gt; Create_Job</h2>
  <form id="createForm" class="form-grid">
    <div class="field">
      <label for="jName">Name</label>
      <input type="text" id="jName" placeholder="e.g. Morning Weather Check" required>
    </div>
    <div class="field">
      <label for="jScheduleKind">Schedule Type</label>
      <select id="jScheduleKind">
        <option value="every">Interval (every N minutes)</option>
        <option value="cron">Cron Expression</option>
        <option value="at">One-shot (at specific time)</option>
      </select>
    </div>
    <div class="field" id="fEvery">
      <label for="jEvery">Interval (minutes)</label>
      <input type="number" id="jEvery" value="60" min="1">
      <span class="field-hint">Runs every N minutes from creation time.</span>
    </div>
    <div class="field hidden" id="fCron">
      <label for="jCronExpr">Cron Expression</label>
      <input type="text" id="jCronExpr" placeholder="0 9 * * *">
      <span class="field-hint">Standard 5-field cron. Optional timezone below.</span>
    </div>
    <div class="field hidden" id="fCronTz">
      <label for="jCronTz">Timezone (optional)</label>
      <input type="text" id="jCronTz" placeholder="America/New_York">
    </div>
    <div class="field hidden" id="fAt">
      <label for="jAt">Run At (ISO 8601)</label>
      <input type="text" id="jAt" placeholder="2026-06-15T09:00:00">
      <span class="field-hint">Use local time with offset, or UTC.</span>
    </div>
    <div class="field">
      <label for="jPayloadKind">Payload Type</label>
      <select id="jPayloadKind">
        <option value="agentTurn">Agent Turn (runs a prompt)</option>
        <option value="systemEvent">System Event (injects text)</option>
      </select>
    </div>
    <div class="field" style="grid-column: 1 / -1;">
      <label for="jMessage">Message / Prompt</label>
      <textarea id="jMessage" placeholder="What should the agent do? e.g. Check the weather for Alexandria VA and report to Dain." required></textarea>
    </div>
    <div class="field">
      <label for="jSessionTarget">Session Target</label>
      <select id="jSessionTarget">
        <option value="isolated">isolated (default — clean background run)</option>
        <option value="current">current (bind to this session)</option>
        <option value="main">main (main session — requires systemEvent)</option>
      </select>
      <span class="field-hint">"main" only works with systemEvent payload.</span>
    </div>
    <div class="field">
      <label for="jDelivery">Delivery Mode</label>
      <select id="jDelivery">
        <option value="none">none (silent)</option>
        <option value="announce">announce (send to chat)</option>
      </select>
    </div>
    <div class="field">
      <label for="jChannel">Channel</label>
      <input type="text" id="jChannel" placeholder="telegram">
    </div>
    <div class="field">
      <label for="jTo">To / Recipient</label>
      <input type="text" id="jTo" placeholder="8305133249">
    </div>
    <div class="field" style="grid-column: 1 / -1;">
      <label>
        <input type="checkbox" id="jEnabled" checked> Enabled
      </label>
    </div>
    <div class="field" style="grid-column: 1 / -1;">
      <button type="submit" class="btn primary">Create Job</button>
      <span class="spinner hidden" id="createSpinner"></span>
    </div>
  </form>
</section>

<div id="toast"></div>

<script>
// ---------------------------------------------------------------------------
// API helpers
// ---------------------------------------------------------------------------
async function api(action, body = null) {
  const opts = { method: body ? 'POST' : 'GET', headers: { 'Content-Type': 'application/json' } };
  if (body) opts.body = JSON.stringify({ ...body, action });
  const res = await fetch('/api/cron', opts);
  if (!res.ok) throw new Error(`HTTP ${res.status}`);
  return res.json();
}

function showToast(msg, type = 'info') {
  const t = document.getElementById('toast');
  t.textContent = msg;
  t.className = type + ' show';
  setTimeout(() => t.className = '', 3000);
}

function fmtDate(ts) {
  if (!ts) return 'never';
  const d = new Date(ts);
  return d.toLocaleString();
}

function fmtDuration(ms) {
  if (!ms) return '-';
  if (ms < 1000) return ms + 'ms';
  return (ms / 1000).toFixed(1) + 's';
}

function fmtSchedule(s) {
  if (!s) return 'unknown';
  if (s.kind === 'every') return `Every ${s.everyMs / 60000} min`;
  if (s.kind === 'cron') return `Cron: ${s.expr}${s.tz ? ' (' + s.tz + ')' : ''}`;
  if (s.kind === 'at') return `At ${fmtDate(s.at)}`;
  return JSON.stringify(s);
}

// ---------------------------------------------------------------------------
// Render jobs
// ---------------------------------------------------------------------------
async function loadJobs() {
  const spinner = document.getElementById('listSpinner');
  spinner.classList.remove('hidden');
  try {
    const data = await api('list');
    const container = document.getElementById('jobList');
    if (!data.jobs || data.jobs.length === 0) {
      container.innerHTML = '<div class="empty-state">No jobs found. Create one below.</div>';
      return;
    }
    container.innerHTML = data.jobs.map(j => {
      const st = j.state || {};
      const statusBadge = st.runningAtMs ? 'running' : (st.lastRunStatus === 'ok' ? 'ok' : (st.lastRunStatus || 'unknown'));
      const statusClass = statusBadge === 'ok' ? 'ok' : (statusBadge === 'error' ? 'error' : (statusBadge === 'running' ? 'running' : ''));
      const enabledClass = j.enabled ? 'enabled' : 'disabled';
      return `
        <div class="job-card ${j.enabled ? '' : 'disabled'}">
          <div class="job-header">
            <div>
              <div class="job-name">${escapeHtml(j.name)}</div>
              <div class="job-id">${j.id}</div>
            </div>
            <div style="display:flex;gap:6px;flex-wrap:wrap;">
              <span class="badge ${enabledClass}">${j.enabled ? 'enabled' : 'disabled'}</span>
              <span class="badge ${statusClass}">${statusBadge}</span>
            </div>
          </div>
          <div class="job-meta">
            <span><strong>Schedule:</strong> ${escapeHtml(fmtSchedule(j.schedule))}</span>
            <span><strong>Payload:</strong> ${j.payload?.kind || '-'}</span>
            <span><strong>Target:</strong> ${j.sessionTarget || '-'}</span>
            <span><strong>Next run:</strong> ${fmtDate(st.nextRunAtMs)}</span>
            <span><strong>Last run:</strong> ${fmtDate(st.lastRunAtMs)}</span>
            <span><strong>Duration:</strong> ${fmtDuration(st.lastDurationMs)}</span>
            <span><strong>Errors:</strong> ${st.consecutiveErrors || 0}</span>
            <span><strong>Skipped:</strong> ${st.consecutiveSkipped || 0}</span>
          </div>
          <div class="job-actions">
            <button class="btn run" onclick="runJob('${j.id}')">Run Now</button>
            <button class="btn toggle" onclick="toggleJob('${j.id}', ${!j.enabled})">${j.enabled ? 'Disable' : 'Enable'}</button>
            <button class="btn delete" onclick="deleteJob('${j.id}')">Delete</button>
          </div>
        </div>
      `;
    }).join('');
  } catch (e) {
    showToast('Failed to load jobs: ' + e.message, 'error');
  } finally {
    spinner.classList.add('hidden');
  }
}

function escapeHtml(s) {
  const d = document.createElement('div');
  d.textContent = s;
  return d.innerHTML;
}

// ---------------------------------------------------------------------------
// Actions
// ---------------------------------------------------------------------------
async function runJob(id) {
  try {
    await api('run', { jobId: id });
    showToast('Job triggered', 'success');
    setTimeout(loadJobs, 1000);
  } catch (e) {
    showToast('Run failed: ' + e.message, 'error');
  }
}

async function toggleJob(id, enable) {
  try {
    await api('update', { jobId: id, patch: { enabled: enable } });
    showToast(enable ? 'Job enabled' : 'Job disabled', 'success');
    loadJobs();
  } catch (e) {
    showToast('Toggle failed: ' + e.message, 'error');
  }
}

async function deleteJob(id) {
  if (!confirm('Delete this job? This cannot be undone.')) return;
  try {
    await api('remove', { jobId: id });
    showToast('Job deleted', 'success');
    loadJobs();
  } catch (e) {
    showToast('Delete failed: ' + e.message, 'error');
  }
}

// ---------------------------------------------------------------------------
// Form handling
// ---------------------------------------------------------------------------
document.getElementById('jScheduleKind').addEventListener('change', e => {
  const kind = e.target.value;
  document.getElementById('fEvery').classList.toggle('hidden', kind !== 'every');
  document.getElementById('fCron').classList.toggle('hidden', kind !== 'cron');
  document.getElementById('fCronTz').classList.toggle('hidden', kind !== 'cron');
  document.getElementById('fAt').classList.toggle('hidden', kind !== 'at');
});

document.getElementById('jPayloadKind').addEventListener('change', e => {
  const kind = e.target.value;
  const st = document.getElementById('jSessionTarget');
  // main requires systemEvent
  if (kind === 'systemEvent') {
    if (!Array.from(st.options).some(o => o.value === 'main')) {
      const opt = document.createElement('option');
      opt.value = 'main'; opt.textContent = 'main (main session)';
      st.appendChild(opt);
    }
  } else {
    Array.from(st.options).forEach(o => { if (o.value === 'main') o.remove(); });
    if (st.value === 'main') st.value = 'isolated';
  }
});

document.getElementById('createForm').addEventListener('submit', async e => {
  e.preventDefault();
  const spinner = document.getElementById('createSpinner');
  spinner.classList.remove('hidden');

  const kind = document.getElementById('jScheduleKind').value;
  let schedule;
  if (kind === 'every') {
    const mins = parseInt(document.getElementById('jEvery').value, 10);
    schedule = { kind: 'every', everyMs: mins * 60000 };
  } else if (kind === 'cron') {
    schedule = { kind: 'cron', expr: document.getElementById('jCronExpr').value };
    const tz = document.getElementById('jCronTz').value.trim();
    if (tz) schedule.tz = tz;
  } else if (kind === 'at') {
    schedule = { kind: 'at', at: document.getElementById('jAt').value };
  }

  const payloadKind = document.getElementById('jPayloadKind').value;
  const payload = payloadKind === 'agentTurn'
    ? { kind: 'agentTurn', message: document.getElementById('jMessage').value }
    : { kind: 'systemEvent', text: document.getElementById('jMessage').value };

  const deliveryMode = document.getElementById('jDelivery').value;
  const delivery = { mode: deliveryMode };
  const ch = document.getElementById('jChannel').value.trim();
  const to = document.getElementById('jTo').value.trim();
  if (ch) delivery.channel = ch;
  if (to) delivery.to = to;

  const job = {
    name: document.getElementById('jName').value,
    schedule,
    payload,
    sessionTarget: document.getElementById('jSessionTarget').value,
    delivery,
    enabled: document.getElementById('jEnabled').checked
  };

  try {
    await api('add', { job });
    showToast('Job created successfully', 'success');
    e.target.reset();
    document.getElementById('jScheduleKind').value = 'every';
    document.getElementById('jScheduleKind').dispatchEvent(new Event('change'));
    loadJobs();
  } catch (err) {
    showToast('Create failed: ' + err.message, 'error');
  } finally {
    spinner.classList.add('hidden');
  }
});

// Init
loadJobs();
setInterval(loadJobs, 30000); // auto-refresh every 30s
</script>
</body>
</html>
'''

# ---------------------------------------------------------------------------
# HTTP Handler
# ---------------------------------------------------------------------------

class Handler(BaseHTTPRequestHandler):
    def log_message(self, fmt, *args):
        # quieter logs
        pass

    def _send_json(self, status, data):
        body = json.dumps(data).encode('utf-8')
        self.send_response(status)
        self.send_header('Content-Type', 'application/json')
        self.send_header('Content-Length', len(body))
        self.send_header('Access-Control-Allow-Origin', '*')
        self.end_headers()
        self.wfile.write(body)

    def _proxy_to_gateway(self, body_obj):
        # Try env vars first, then config file
        gateway_url = GATEWAY_URL
        gateway_token = GATEWAY_TOKEN
        if not gateway_url or not gateway_token:
            try:
                cfg_path = os.path.expanduser("~/.openclaw/openclaw.json")
                with open(cfg_path, "r") as f:
                    data = json.load(f)
                gateway_port = data.get("gateway", {}).get("port", 18789)
                gateway_token = data.get("gateway", {}).get("auth", {}).get("token")
                gateway_url = f"http://127.0.0.1:{gateway_port}"
            except Exception:
                pass
        if not gateway_url or not gateway_token:
            return {"error": "Gateway URL or token not configured."}

        parsed = urllib.parse.urlparse(gateway_url)
        host = parsed.hostname
        port = parsed.port or (443 if parsed.scheme == 'https' else 80)
        # OpenClaw admin HTTP RPC is on /api/v1/admin/rpc
        path = (parsed.path or '') + '/api/v1/admin/rpc'

        # Build JSON-RPC request
        rpc_body = {
            "jsonrpc": "2.0",
            "id": "cron-manager-ui",
            "method": body_obj.get("_rpc_method", "cron.list"),
            "params": body_obj.get("_rpc_params", {})
        }

        body = json.dumps(rpc_body).encode('utf-8')
        headers = {
            "Content-Type": "application/json",
            "Authorization": f"Bearer {gateway_token}",
            "Content-Length": str(len(body))
        }

        try:
            if parsed.scheme == 'https':
                conn = http.client.HTTPSConnection(host, port, timeout=30)
            else:
                conn = http.client.HTTPConnection(host, port, timeout=30)
            conn.request("POST", path, body=body, headers=headers)
            resp = conn.getresponse()
            resp_body = resp.read()
            conn.close()
            try:
                rpc_resp = json.loads(resp_body.decode('utf-8'))
                # Unwrap JSON-RPC envelope for client
                if rpc_resp.get("ok"):
                    return rpc_resp.get("payload", rpc_resp)
                elif "error" in rpc_resp:
                    return {"error": rpc_resp["error"].get("message", str(rpc_resp["error"]))}
                else:
                    return rpc_resp
            except Exception:
                return {"error": "Non-JSON gateway response", "raw": resp_body.decode('utf-8', errors='replace')[:500]}
        except Exception as e:
            return {"error": str(e)}

    def do_GET(self):
        if self.path == '/' or self.path == '/cron-manager.html':
            body = HTML_PAGE.encode('utf-8')
            self.send_response(200)
            self.send_header('Content-Type', 'text/html; charset=utf-8')
            self.send_header('Content-Length', len(body))
            self.end_headers()
            self.wfile.write(body)
        else:
            self.send_response(404)
            self.end_headers()

    def do_POST(self):
        if self.path == '/api/cron':
            length = int(self.headers.get('Content-Length', 0))
            raw = self.rfile.read(length).decode('utf-8')
            try:
                req = json.loads(raw)
            except Exception:
                self._send_json(400, {"error": "Invalid JSON"})
                return
            action = req.get("action", "list")
            # Map our simple API actions to JSON-RPC methods
            if action == "list":
                rpc_params = {"agentId": req.get("agentId", "main")}
                result = self._proxy_to_gateway({"_rpc_method": "cron.list", "_rpc_params": rpc_params})
            elif action == "get":
                rpc_params = {"jobId": req.get("jobId")}
                result = self._proxy_to_gateway({"_rpc_method": "cron.get", "_rpc_params": rpc_params})
            elif action == "runs":
                rpc_params = {"jobId": req.get("jobId")}
                result = self._proxy_to_gateway({"_rpc_method": "cron.runs", "_rpc_params": rpc_params})
            elif action == "add":
                rpc_params = {"job": req.get("job")}
                result = self._proxy_to_gateway({"_rpc_method": "cron.add", "_rpc_params": rpc_params})
            elif action == "update":
                rpc_params = {"jobId": req.get("jobId"), "patch": req.get("patch", {})}
                result = self._proxy_to_gateway({"_rpc_method": "cron.update", "_rpc_params": rpc_params})
            elif action == "remove":
                rpc_params = {"jobId": req.get("jobId")}
                result = self._proxy_to_gateway({"_rpc_method": "cron.remove", "_rpc_params": rpc_params})
            elif action == "run":
                rpc_params = {"jobId": req.get("jobId")}
                result = self._proxy_to_gateway({"_rpc_method": "cron.run", "_rpc_params": rpc_params})
            elif action == "status":
                result = self._proxy_to_gateway({"_rpc_method": "cron.status", "_rpc_params": {}})
            else:
                result = {"error": f"Unknown action: {action}"}
            self._send_json(200 if "error" not in result else 502, result)
        else:
            self.send_response(404)
            self.end_headers()

    def do_OPTIONS(self):
        self.send_response(204)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        self.end_headers()

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

if __name__ == '__main__':
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 8765
    if not GATEWAY_URL or not GATEWAY_TOKEN:
        print("[warn] Gateway credentials not found. Set OPENCLAW_GATEWAY_URL and OPENCLAW_GATEWAY_TOKEN.")
        print("[warn] Or add gatewayUrl / gatewayToken to ~/.openclaw/config.json")
    server = HTTPServer(('0.0.0.0', port), Handler)
    print(f"[cron-server] Running at http://0.0.0.0:{port}/")
    print(f"[cron-server] Gateway: {GATEWAY_URL or 'NOT CONFIGURED'}")
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\n[cron-server] Stopping.")
