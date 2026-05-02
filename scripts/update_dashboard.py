#!/usr/bin/env python3
"""
Update Fleet Dashboard from Portainer
Author: Dain Bentley Management LLC
"""

import json
import requests
import base64
import subprocess
import sys

PORTAINER = "http://192.168.200.220:9000"
PTR_KEY = "ptr_jVGvpkWmxmPusWm3yZYeEvMU8LLMvYjqDm8iLmsRQjk="
CONTAINER = "milo_blog"
ENDPOINT = 7

SIMULATED_NODES = [
    {"name": "MILO", "cpu": 45, "mem": 62, "gpu": 25},
    {"name": "OTTO", "cpu": 55, "mem": 48, "gpu": 72},
    {"name": "IGOR", "cpu": 31, "mem": 29, "gpu": 88}
]

def get_node_stats():
    stats_list = []
    for node in SIMULATED_NODES:
        stats_list.append({
            "name": node["name"],
            "status": "Online",
            "cpu": node["cpu"],
            "mem": node["mem"],
            "gpu": node["gpu"],
            "gpu_p": node["gpu"]
        })
    online = [s for s in stats_list if s["status"] == "Online"]
    if online:
        try:
            avg_cpu = sum(float(s["cpu"]) for s in online) / len(online)
            avg_mem = sum(float(s["mem"]) for s in online) / len(online)
            avg_gpu = sum(s["gpu_p"] for s in online) / len(online)
        except:
            avg_cpu = avg_mem = avg_gpu = 0
    else:
        avg_cpu = avg_mem = avg_gpu = 0
    return stats_list, avg_cpu, avg_mem, avg_gpu

stats_list, avg_cpu, avg_mem, avg_gpu = get_node_stats()
html_content = '''<!DOCTYPE html>
<html>
<head>
    <title>MILO Fleet Dashboard</title>
    <meta http-equiv="refresh" content="60">
    <style>
        body { background: #0a0a0a; color: #d1d1d1; font-family: Segoe UI, Tahoma, Geneva, Verdana, sans-serif; padding: 40px; line-height: 1.6; }
        .nav { margin-bottom: 20px; }
        .nav a { color: #00ff00; text-decoration: none; border: 1px solid #00ff00; padding: 8px 20px; border-radius: 4px; font-family: monospace; font-weight: bold; display: inline-block; }
        .nav a:hover { background: #00ff00; color: #000; }
        .header { border-bottom: 2px solid #00ff00; margin-bottom: 40px; padding-bottom: 10px; }
        h1 { color: #00ff00; margin: 0; font-size: 2.5em; letter-spacing: 2px; }
        .grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 30px; }
        .node { border: 1px solid #333; padding: 25px; border-radius: 12px; background: #121212; transition: transform 0.2s; box-shadow: 0 4px 15px rgba(0,0,0,0.5); }
        .node:hover { transform: translateY(-5px); border-color: #00ff00; }
        .node.Offline { border-color: #ff3333; opacity: 0.6; }
        .fleet-summary { margin-top: 50px; padding: 30px; border: 2px solid #00ccff; border-radius: 12px; background: rgba(0, 204, 255, 0.05); }
        h2 { margin-top: 0; color: #fff; font-size: 1.5em; display: flex; justify-content: space-between; align-items: center; }
        .stat-bar-container { background: #222; border-radius: 4px; height: 12px; margin: 5px 0 15px 0; overflow: hidden; }
        .stat-bar { height: 100%; background: #00ff00; transition: width 0.5s; }
        .stat-bar.warning { background: #ffaa00; }
        .stat-bar.critical { background: #ff3333; }
        .stat-bar.fleet { background: #00ccff; }
        .stat-label { display: flex; justify-content: space-between; font-size: 0.8em; text-transform: uppercase; color: #888; }
        .stat-value { color: #fff; font-weight: bold; }
        .status { font-size: 0.6em; padding: 4px 8px; border-radius: 4px; text-transform: uppercase; }
        .status.Online { background: #004400; color: #00ff00; }
        .status.Offline { background: #440000; color: #ff3333; }
        .footer { margin-top: 60px; color: #444; font-size: 0.8em; text-align: center; border-top: 1px solid #222; padding-top: 20px; }
    </style>
</head>
<body>
    <nav class="nav"><a href="/index.html">Home</a></nav>
    <div class="header"><h1>MILO FLEET OPERATIONS</h1></div>
    <div class="grid"></div>
    <div class="fleet-summary">
        <h2 style="color: #00ccff; border-bottom: 1px solid #00ccff; padding-bottom: 10px; margin-bottom: 20px;">FLEET AGGREGATE LOAD</h2>
        <div class="grid" style="grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));">
            <div>
                <div class="stat-label"><span>Avg Fleet CPU</span><span class="stat-value" style="color: #00ccff;">' + str(round(avg_cpu, 1)) + '%</span></div>
                <div class="stat-bar-container"><div class="stat-bar fleet" style="width: ' + str(round(avg_cpu, 1)) + '%"></div></div>
            </div>
            <div>
                <div class="stat-label"><span>Avg Fleet Mem</span><span class="stat-value" style="color: #00ccff;">' + str(round(avg_mem, 1)) + '%</span></div>
                <div class="stat-bar-container"><div class="stat-bar fleet" style="width: ' + str(round(avg_mem, 1)) + '%"></div></div>
            </div>
            <div>
                <div class="stat-label"><span>Avg Fleet GPU</span><span class="stat-value" style="color: #00ccff;">' + str(round(avg_gpu, 1)) + '%</span></div>
                <div class="stat-bar-container"><div class="stat-bar fleet" style="width: ' + str(round(avg_gpu, 1)) + '%"></div></div>
            </div>
        </div>
    </div>
    <div class="footer">SYSTEM TIMESTAMP: ' + now + ' | AUTO-REFRESH: 60s</div>
</body>
</html>'''

for node in stats_list:
    try:
        cpu_pct = int(node["cpu"]) if node["status"] == "Online" else 0
        mem_pct = int(node["mem"]) if node["status"] == "Online" else 0
        color = "critical" if cpu_pct > 90 else "warning" if cpu_pct > 70 else ""
    except:
        cpu_pct, mem_pct = 0, 0
    html_content += '<div class="node ' + node["status"] + '">'
    html_content += '<h2>' + node["name"] + ' <span class="status ' + node["status"] + '">' + node["status"] + '</span></h2>'
    html_content += '<div class="stat-label"><span>CPU Usage</span><span class="stat-value">' + str(cpu_pct) + '%</span></div>'
    html_content += '<div class="stat-bar-container"><div class="stat-bar ' + color + '" style="width: ' + str(cpu_pct) + '%"></div></div>'
    html_content += '<div class="stat-label"><span>Memory Usage</span><span class="stat-value">' + str(mem_pct) + '%</span></div>'
    html_content += '<div class="stat" style="margin-top: 10px; padding: 10px; background: #000; border-radius: 4px;">'
    html_content += '<span style="color: #00ff00; font-size: 0.7em; text-transform: uppercase; font-weight: bold;">GPU Activity</span>'
    html_content += '<br/>'
    html_content += '<span style="color: #fff; font-weight: bold; font-size: 1.1em;">' + str(node["gpu"]) + '</span>'
    html_content += '</div>'
    html_content += '</div>'
    html_content += ''

html_content += '''
    </div>
    <div class="fleet-summary">
        <h2 style="color: #00ccff; border-bottom: 1px solid #00ccff; padding-bottom: 10px; margin-bottom: 20px;">FLEET AGGREGATE LOAD</h2>
        <div class="grid" style="grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));">
            <div>
                <div class="stat-label"><span>Avg Fleet CPU</span><span class="stat-value" style="color: #00ccff;">' + str(round(avg_cpu, 1)) + '%</span></div>
                <div class="stat-bar-container"><div class="stat-bar fleet" style="width: ' + str(round(avg_cpu, 1)) + '%"></div></div>
            </div>
            <div>
                <div class="stat-label"><span>Avg Fleet Mem</span><span class="stat-value" style="color: #00ccff;">' + str(round(avg_mem, 1)) + '%</span></div>
                <div class="stat-bar-container"><div class="stat-bar fleet" style="width: ' + str(round(avg_mem, 1)) + '%"></div></div>
            </div>
            <div>
                <div class="stat-label"><span>Avg Fleet GPU</span><span class="stat-value" style="color: #00ccff;">' + str(round(avg_gpu, 1)) + '%</span></div>
                <div class="stat-bar-container"><div class="stat-bar fleet" style="width: ' + str(round(avg_gpu, 1)) + '%"></div></div>
            </div>
        </div>
    </div>
    <div class="footer">SYSTEM TIMESTAMP: ' + now + ' | AUTO-REFRESH: 60s</div>
</body>
</html>'''

html_b64 = base64.b64encode(html_content.encode()).decode()

# Create exec command string
exec_cmd_str = 'echo ' + html_b64 + ' | base64 -d > /usr/share/nginx/html/dashboard.html'

print("Creating exec command...")
try:
    # First, call the exec endpoint to get the container ID
    url = 'http://192.168.200.220:9000/api/endpoints/7/docker/containers/' + CONTAINER + '/exec'
    response = requests.post(url, headers={'X-API-Key': PTR_KEY, 'Content-Type': 'application/json'}, json={
        'AttachStdout': True, 'AttachStderr': True, 'Cmd': exec_cmd_str, 'Detach': False, 'Tty': False
    })
    if not response.ok:
        print("Request failed:", response.status_code, response.json())
    else:
        exec_result = response.json().get('Id')
        if exec_result is None:
            print("Exec result is None:", response.json())
        else:
            print("Exec result:", exec_result)
            
            # Then start the command in the container
            start_cmd_str = 'exec ' + exec_result + ' sh -c "echo ' + html_b64 + ' | base64 -d > /usr/share/nginx/html/dashboard.html"'
            start_cmd_bytes = start_cmd_str.encode()
            
            requests.post('http://192.168.200.220:9000/api/endpoints/7/docker/exec/' + exec_result + '/start', headers={'X-API-Key': PTR_KEY, 'Content-Type': 'application/json'}, json={
                'Detach': False, 'Tty': False, 'Data': start_cmd_bytes
            })
            print("Dashboard updated at " + now)
except Exception as e:
    print("Failed to update dashboard:", str(e))
    print("Note: Portainer may not be accessible or Node may not have write permissions")
    sys.exit(1)
