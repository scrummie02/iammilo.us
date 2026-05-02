#!/usr/bin/env python3
"""
Refresh Fleet Dashboard - Live data from MILO and OTTO
"""
import os
import re
import subprocess
import time
from datetime import datetime

NODES = {
    "MILO": {"host": "localhost", "ssh": False, "gpu": False},
    "OTTO": {"host": "dain@192.168.200.241", "ssh": True, "gpu": False},
    "IGOR": {"host": "localhost", "ssh": False, "gpu": False, "notes": "Gemma4 container"},
}


def get_local_cpu():
    try:
        with open("/proc/stat", "r") as f:
            line = f.readline()
        fields = list(map(int, line.split()[1:]))
        idle = fields[3]
        total = sum(fields)
        # Return loadavg-based approximation since we can't diff without prior sample
        load = os.getloadavg()[0]
        nproc = os.cpu_count() or 1
        pct = min(int((load / nproc) * 100), 100)
        return pct
    except Exception:
        return 0


def get_local_mem():
    try:
        with open("/proc/meminfo", "r") as f:
            data = f.read()
        total = int(re.search(r"MemTotal:\s+(\d+)", data).group(1))
        avail = int(re.search(r"MemAvailable:\s+(\d+)", data).group(1))
        return min(int((1 - avail / total) * 100), 100)
    except Exception:
        return 0


def get_local_gpu():
    try:
        out = subprocess.run(
            ["nvidia-smi", "--query-gpu=utilization.gpu", "--format=csv,noheader,nounits"],
            capture_output=True, text=True, timeout=5
        )
        val = out.stdout.strip()
        return int(float(val)) if val else 0
    except Exception:
        return None


def ssh_cmd(host, cmd, timeout=10):
    try:
        result = subprocess.run(
            ["ssh", "-o", "ConnectTimeout=5", "-o", "BatchMode=yes", host, cmd],
            capture_output=True, text=True, timeout=timeout
        )
        return result.stdout.strip()
    except Exception as e:
        return f"ERR: {e}"


def get_remote_cpu(host):
    out = ssh_cmd(host, "cat /proc/loadavg | awk '{print $1}'")
    try:
        load = float(out)
        # Assume 4 cores for OTTO (CachyOS x86_64 VM)
        nproc = 4
        return min(int((load / nproc) * 100), 100)
    except Exception:
        return 0


def get_remote_mem(host):
    out = ssh_cmd(host, "free | grep Mem | awk '{print $3, $2}'")
    try:
        used, total = map(int, out.split())
        return min(int((used / total) * 100), 100)
    except Exception:
        return 0


def get_node_status(name, cfg):
    if cfg.get("ssh"):
        out = ssh_cmd(cfg["host"], "uptime 2>/dev/null")
        if out.startswith("ERR"):
            return {"status": "Offline", "cpu": 0, "mem": 0, "gpu": None}
        cpu = get_remote_cpu(cfg["host"])
        mem = get_remote_mem(cfg["host"])
        gpu = None
    else:
        cpu = get_local_cpu()
        mem = get_local_mem()
        gpu = get_local_gpu() if cfg.get("gpu") else None

    return {"status": "Online", "cpu": cpu, "mem": mem, "gpu": gpu}


def build_html(nodes_data, timestamp):
    nodes_html = ""
    cpus = []
    mems = []
    gpus = []

    for name, data in nodes_data.items():
        cpus.append(data["cpu"])
        mems.append(data["mem"])
        if data["gpu"] is not None:
            gpus.append(data["gpu"])

        status_cls = data["status"]
        gpu_display = str(data["gpu"]) if data["gpu"] is not None else "N/A"

        bar_cls = "fleet"
        if data["cpu"] >= 80:
            bar_cls = "critical"
        elif data["cpu"] >= 60:
            bar_cls = "warning"

        nodes_html += f"""        <div class="node {status_cls}">
            <h2>{name} <span class="status {status_cls}">{status_cls}</span></h2>
            <div class="stat-label"><span>CPU Usage</span><span class="stat-value">{data["cpu"]}</span></div>
            <div class="stat-bar-container"><div class="stat-bar {bar_cls}" style="width: {data["cpu"]}%"></div></div>
            <div class="stat-label"><span>Memory Usage</span><span class="stat-value">{data["mem"]}</span></div>
            <div class="stat" style="margin-top: 10px; padding: 10px; background: #000; border-radius: 4px;">
                <span style="color: #00ff00; font-size: 0.7em; text-transform: uppercase; font-weight: bold;">GPU Activity</span>
                <br/>
                <span style="color: #fff; font-weight: bold; font-size: 1.1em;">{gpu_display}</span>
            </div>
        </div>
"""

    avg_cpu = round(sum(cpus) / len(cpus), 1) if cpus else 0
    avg_mem = round(sum(mems) / len(mems), 1) if mems else 0
    avg_gpu = round(sum(gpus) / len(gpus), 1) if gpus else 0.0

    return f"""\u003c!DOCTYPE html\u003e
\u003chtml\u003e
\u003chead\u003e
    \u003ctitle\u003eMILO Fleet Dashboard\u003c/title\u003e
    \u003cmeta http-equiv="refresh" content="60"\u003e
    \u003cstyle\u003ebody {{ background: #0a0a0a; color: #d1d1d1; font-family: Segoe UI, Tahoma, Geneva, Verdana, sans-serif; padding: 40px; line-height: 1.6; }} .nav {{ margin-bottom: 20px; }} .nav a {{ color: #00ff00; text-decoration: none; border: 1px solid #00ff00; padding: 8px 20px; border-radius: 4px; font-family: monospace; font-weight: bold; display: inline-block; }} .nav a:hover {{ background: #00ff00; color: #000; }} .header {{ border-bottom: 2px solid #00ff00; margin-bottom: 40px; padding-bottom: 10px; }} h1 {{ color: #00ff00; margin: 0; font-size: 2.5em; letter-spacing: 2px; }} .grid {{ display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 30px; }} .node {{ border: 1px solid #333; padding: 25px; border-radius: 12px; background: #121212; transition: transform 0.2s; box-shadow: 0 4px 15px rgba(0,0,0,0.5); }} .node:hover {{ transform: translateY(-5px); border-color: #00ff00; }} .node.Offline {{ border-color: #ff3333; opacity: 0.6; }} .fleet-summary {{ margin-top: 50px; padding: 30px; border: 2px solid #00ccff; border-radius: 12px; background: rgba(0, 204, 255, 0.05); }} h2 {{ margin-top: 0; color: #fff; font-size: 1.5em; display: flex; justify-content: space-between; align-items: center; }} .stat-bar-container {{ background: #222; border-radius: 4px; height: 12px; margin: 5px 0 15px 0; overflow: hidden; }} .stat-bar {{ height: 100%; background: #00ff00; transition: width 0.5s; }} .stat-bar.warning {{ background: #ffaa00; }} .stat-bar.critical {{ background: #ff3333; }} .stat-bar.fleet {{ background: #00ccff; }} .stat-label {{ display: flex; justify-content: space-between; font-size: 0.8em; text-transform: uppercase; color: #888; }} .stat-value {{ color: #fff; font-weight: bold; }} .status {{ font-size: 0.6em; padding: 4px 8px; border-radius: 4px; text-transform: uppercase; }} .status.Online {{ background: #004400; color: #00ff00; }} .status.Offline {{ background: #440000; color: #ff3333; }} .footer {{ margin-top: 60px; color: #444; font-size: 0.8em; text-align: center; border-top: 1px solid #222; padding-top: 20px; }} \u003c/style\u003e\u003c/head\u003e
\u003cbody\u003e
    \u003cnav class="nav"\u003e\u003ca href="/index.html"\u003eHome\u003c/a\u003e\u003c/nav\u003e
    \u003cdiv class="header"\u003e\u003ch1\u003eMILO FLEET OPERATIONS\u003c/h1\u003e\u003c/div\u003e
    \u003cdiv class="grid"\u003e
{nodes_html}
    \u003c/div\u003e
    \u003cdiv class="fleet-summary"\u003e
        \u003ch2 style="color: #00ccff; border-bottom: 1px solid #00ccff; padding-bottom: 10px; margin-bottom: 20px;"\u003eFLEET AGGREGATE LOAD\u003c/h2\u003e
        \u003cdiv class="grid" style="grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));"\u003e
            \u003cdiv\u003e
                \u003cdiv class="stat-label"\u003e\u003cspan\u003eAvg Fleet CPU\u003c/span\u003e\u003cspan class="stat-value" style="color: #00ccff;"\u003e{avg_cpu}\u003c/span\u003e\u003c/div\u003e
                \u003cdiv class="stat-bar-container"\u003e\u003cdiv class="stat-bar fleet" style="width: {avg_cpu}%"\u003e\u003c/div\u003e\u003c/div\u003e
            \u003c/div\u003e
            \u003cdiv\u003e
                \u003cdiv class="stat-label"\u003e\u003cspan\u003eAvg Fleet Mem\u003c/span\u003e\u003cspan class="stat-value" style="color: #00ccff;"\u003e{avg_mem}\u003c/span\u003e\u003c/div\u003e
                \u003cdiv class="stat-bar-container"\u003e\u003cdiv class="stat-bar fleet" style="width: {avg_mem}%"\u003e\u003c/div\u003e\u003c/div\u003e
            \u003c/div\u003e
            \u003cdiv\u003e
                \u003cdiv class="stat-label"\u003e\u003cspan\u003eAvg Fleet GPU\u003c/span\u003e\u003cspan class="stat-value" style="color: #00ccff;"\u003e{avg_gpu}\u003c/span\u003e\u003c/div\u003e
                \u003cdiv class="stat-bar-container"\u003e\u003cdiv class="stat-bar fleet" style="width: {avg_gpu}%"\u003e\u003c/div\u003e\u003c/div\u003e
            \u003c/div\u003e
        \u003c/div\u003e
    \u003c/div\u003e
    \u003cdiv class="footer"\u003eSYSTEM TIMESTAMP: {timestamp} | AUTO-REFRESH: 60s\u003c/div\u003e
\u003c/body\u003e
\u003c/html\u003e"""


def main():
    milo_blog_path = "/home/dain/.openclaw/workspace/milo_blog"
    os.makedirs(milo_blog_path, exist_ok=True)

    nodes_data = {}
    for name, cfg in NODES.items():
        nodes_data[name] = get_node_status(name, cfg)

    timestamp = datetime.now().strftime("%Y-%m-%d %I:%M %p")
    html = build_html(nodes_data, timestamp)

    out_path = os.path.join(milo_blog_path, "dashboard.html")
    with open(out_path, "w") as f:
        f.write(html)

    print(f"Dashboard refreshed: {out_path} ({len(html)} bytes)")
    for name, data in nodes_data.items():
        print(f"  {name}: {data['status']} | CPU {data['cpu']}% | Mem {data['mem']}% | GPU {data['gpu'] if data['gpu'] is not None else 'N/A'}")


if __name__ == "__main__":
    main()
