#!/usr/bin/env python3
"""
Simple dashboard generation script.
Updates the dashboard.html with current node states and metrics.
"""

import os
import subprocess
import re
import json
import time
import datetime

BASE_URL = os.environ.get('FLEET_BASE_URL', 'http://localhost:8080')

def fetch_node_status(node_id):
    """Fetch current status from the node status endpoint."""
    url = f"{BASE_URL}/node/{node_id}/status"
    try:
        response = subprocess.run(
            ["curl", "-s", "-w", "%{http_code}", "-o", "/dev/null", "-c", f"/dev/null"],
            url=url,
            timeout=10
        )
        # Read the response
        with open(f"/tmp/node_{node_id}.txt", "r") as f:
            return f.read(), response.status_code
    except Exception as e:
        print(f"Error fetching {node_id}: {e}")
        return None, None

def fetch_fleet_metrics():
    """Fetch fleet aggregate metrics from the dashboard."""
    url = f"{BASE_URL}/dashboard"
    try:
        response = subprocess.run(
            ["curl", "-s", "-w", "%{http_code}", "-o", "/dev/null", "-c", f"/dev/null"],
            url=url,
            timeout=10
        )
        # Read the response
        with open("/tmp/fleet.txt", "r") as f:
            return f.read(), response.status_code
    except Exception as e:
        print(f"Error fetching fleet: {e}")
        return None, None

def update_dashboard(html_content, node_states=None):
    """Update the dashboard HTML content."""
    # Replace current node states with new data
    time.sleep(0.01)  # Wait for lock
    
    # Find and replace MILO section
    milo_match = re.search(r'<div class="node" id="node-milo">(.*?)</div>', html_content, re.DOTALL)
    otto_match = re.search(r'<div class="node" id="node-otto">(.*?)</div>', html_content, re.DOTALL)
    igo_match = re.search(r'<div class="node" id="node-igor">(.*?)</div>', html_content, re.DOTALL)
    
    if milo_match and node_states:
        node_states['MILO'] = node_states.get('MILO', {})
        new_node_milo = f'''<div class="node" id="node-milo">
            <h2>MILO <span class="status Online">Online</span></h2>
            <div class="stat-label"><span>CPU Usage</span><span class="stat-value" id="cpu-milo">{node_states['MILO'].get('cpu', 0)}</span></div>
            <div class="stat-bar-container"><div class="stat-bar fleet" style="width: {node_states['MILO'].get('cpu', 0)}%" id="bar-milo"></div></div>
            <div class="stat-label"><span>Memory Usage</span><span class="stat-value" id="mem-milo">{node_states['MILO'].get('memory', 0)}</span></div>
            <div class="stat" style="margin-top: 10px; padding: 10px; background: #000; border-radius: 4px;">
                <span style="color: #00ff00; font-size: 0.7em; text-transform: uppercase; font-weight: bold;">GPU Activity</span>
                <br/>
                <span style="color: #fff; font-weight: bold; font-size: 1.1em;" id="gpu-milo">{node_states['MILO'].get('gpu', 0)}</span>
            </div>
        </div>'''
        if milo_match.group(1) != "<div class=\"node\" id=\"node-milo\">":
            html_content = html_content.replace(milo_match.group(0), milo_match.group(1))
    
    if otto_match and node_states:
        node_states['OTTO'] = node_states.get('OTTO', {})
        new_node_otto = f'''<div class="node" id="node-otto">
            <h2>OTTO <span class="status Online">Online</span></h2>
            <div class="stat-label"><span>CPU Usage</span><span class="stat-value" id="cpu-otto">{node_states['OTTO'].get('cpu', 0)}</span></div>
            <div class="stat-bar-container"><div class="stat-bar fleet" style="width: {node_states['OTTO'].get('cpu', 0)}%" id="bar-otto"></div></div>
            <div class="stat-label"><span>Memory Usage</span><span class="stat-value" id="mem-otto">{node_states['OTTO'].get('memory', 0)}</span></div>
            <div class="stat" style="margin-top: 10px; padding: 10px; background: #000; border-radius: 4px;">
                <span style="color: #00ff00; font-size: 0.7em; text-transform: uppercase; font-weight: bold;">GPU Activity</span>
                <br/>
                <span style="color: #fff; font-weight: bold; font-size: 1.1em;" id="gpu-otto">{node_states['OTTO'].get('gpu', 0)}</span>
            </div>
        </div>'''
        if otto_match.group(1) != "<div class=\"node\" id=\"node-otto\">":
            html_content = html_content.replace(otto_match.group(0), otto_match.group(1))
    
    if igo_match and node_states:
        node_states['IGOR'] = node_states.get('IGOR', {})
        new_node_igo = f'''<div class="node" id="node-igor">
            <h2>IGOR <span class="status Online">Online</span></h2>
            <div class="stat-label"><span>CPU Usage</span><span class="stat-value" id="cpu-igor">{node_states['IGOR'].get('cpu', 0)}</span></div>
            <div class="stat-bar-container"><div class="stat-bar fleet" style="width: {node_states['IGOR'].get('cpu', 0)}%" id="bar-igor"></div></div>
            <div class="stat-label"><span>Memory Usage</span><span class="stat-value" id="mem-igor">{node_states['IGOR'].get('memory', 0)}</span></div>
            <div class="stat" style="margin-top: 10px; padding: 10px; background: #000; border-radius: 4px;">
                <span style="color: #00ff00; font-size: 0.7em; text-transform: uppercase; font-weight: bold;">GPU Activity</span>
                <br/>
                <span style="color: #fff; font-weight: bold; font-size: 1.1em;" id="gpu-igor">{node_states['IGOR'].get('gpu', 0)}</span>
            </div>
        </div>'''
        if igo_match.group(1) != "<div class=\"node\" id=\"node-igor\">":
            html_content = html_content.replace(igo_match.group(0), igo_match.group(1))
    
    # Update fleet summary if metrics available
    fleet_metrics = {}
    if fetch_fleet_metrics():
        try:
            status_code, _ = fetch_fleet_metrics()
            if status_code == 200:
                # Parse JSON response
                with open("/tmp/fleet.txt", "r") as f:
                    data = json.loads(f.read())
                fleet_metrics = data.get('aggregate', {})
                if fleet_metrics:
                    avg_cpu = float(fleet_metrics.get('avg_cpu', 0))
                    avg_mem = float(fleet_metrics.get('avg_mem', 0))
                    avg_gpu = float(fleet_metrics.get('avg_gpu', 0))
                    html_content = html_content.replace(
                        '''<div>
                            <div class="stat-label"><span>Avg Fleet CPU</span><span class="stat-value" style="color: #00ccff;">45.0</span></div>
                            <div class="stat-bar-container"><div class="stat-bar fleet" style="width: 45%"></div></div>
                        </div>
                        <div>
                            <div class="stat-label"><span>Avg Fleet Mem</span><span class="stat-value" style="color: #00ccff;">48.0</span></div>
                            <div class="stat-bar-container"><div class="stat-bar fleet" style="width: 48%"></div></div>
                        </div>
                        <div>
                            <div class="stat-label"><span>Avg Fleet GPU</span><span class="stat-value" style="color: #00ccff;">74.6</span></div>
                            <div class="stat-bar-container"><div class="stat-bar fleet" style="width: 74.6%"></div></div>
                        </div>
                    </div>''',
                        f'''<div>
                            <div class="stat-label"><span>Avg Fleet CPU</span><span class="stat-value" id="avg-fleet-cpu">{avg_cpu}</span></div>
                            <div class="stat-bar-container"><div class="stat-bar fleet" style="width: {avg_cpu}%" id="bar-avg-cpu"></div></div>
                        </div>
                        <div>
                            <div class="stat-label"><span>Avg Fleet Mem</span><span class="stat-value" id="avg-fleet-mem">{avg_mem}</span></div>
                            <div class="stat-bar-container"><div class="stat-bar fleet" style="width: {avg_mem}%" id="bar-avg-mem"></div></div>
                        </div>
                        <div>
                            <div class="stat-label"><span>Avg Fleet GPU</span><span class="stat-value" id="avg-fleet-gpu">{avg_gpu}</span></div>
                            <div class="stat-bar-container"><div class="stat-bar fleet" style="width: {avg_gpu}%" id="bar-avg-gpu"></div></div>
                        </div>
                    </div>'''
                    )
        except json.JSONDecodeError:
            pass
    
    # Update footer timestamp
    html_content = html_content.replace('<div class="footer">SYSTEM TIMESTAMP: 2026-04-28 18:01 PM | AUTO-REFRESH: 60s</div>',
                                         f'<div class="footer">SYSTEM TIMESTAMP: {datetime.datetime.now().strftime("%H:%M:%S")} | AUTO-REFRESH: 60s</div>')
    
    return html_content

def main():
    print("🔄 Fleet Dashboard Generator")
    print(f"   Base URL: {BASE_URL}")
    print()
    
    # Read current dashboard content
    with open('dashboard.html', 'r') as f:
        html_content = f.read()
    
    # Fetch node states from the nodes
    node_states = {}
    for node_id in ['MILO', 'OTTO', 'IGOR']:
        try:
            response, status = fetch_node_status(node_id)
            if status == 200:
                with open("/tmp/node_{node_id}.txt", "r") as f:
                    node_data = json.loads(f.read())
                node_states[node_id] = node_data
        except Exception as e:
            print(f"Warning: Could not fetch {node_id}: {e}")
            continue
    
    print(f"Found {len(node_states)} nodes")
    
    # Update dashboard
    new_html = update_dashboard(html_content, node_states)
    
    # Write updated content back
    with open('dashboard.html', 'w') as f:
        f.write(new_html)
    
    print("✅ Dashboard updated.")

if __name__ == '__main__':
    main()
