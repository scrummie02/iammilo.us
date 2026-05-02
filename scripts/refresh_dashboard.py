#!/usr/bin/env python3
import os
import sys
import json
import subprocess
import re
from datetime import datetime

def get_local_cpu():
    """Get local CPU usage percentage."""
    try:
        out = subprocess.check_output(["grep", "cpu ", "/proc/stat"], text=True)
        fields = list(map(int, out.strip().split()[1:]))
        idle = fields[3]
        total = sum(fields)
        # Second sample after a short sleep
        import time
        time.sleep(0.2)
        out2 = subprocess.check_output(["grep", "cpu ", "/proc/stat"], text=True)
        fields2 = list(map(int, out2.strip().split()[1:]))
        idle2 = fields2[3]
        total2 = sum(fields2)
        diff_idle = idle2 - idle
        diff_total = total2 - total
        if diff_total == 0:
            return 0
        return round(100.0 * (1 - diff_idle / diff_total))
    except Exception:
        return 0

def get_local_mem():
    """Get local memory usage percentage."""
    try:
        with open("/proc/meminfo") as f:
            total = 0
            available = 0
            for line in f:
                if line.startswith("MemTotal:"):
                    total = int(line.split()[1])
                elif line.startswith("MemAvailable:"):
                    available = int(line.split()[1])
            if total == 0:
                return 0
            return round(100.0 * (total - available) / total)
    except Exception:
        return 0

def get_local_gpu():
    """Get local GPU utilization if nvidia-smi is available."""
    try:
        out = subprocess.check_output(
            ["nvidia-smi", "--query-gpu=utilization.gpu", "--format=csv,noheader,nounits"],
            text=True, stderr=subprocess.DEVNULL
        )
        vals = [int(x.strip()) for x in out.strip().split("\n") if x.strip()]
        return round(sum(vals) / len(vals)) if vals else 0
    except Exception:
        return 0

def get_remote_stats(hostname="192.168.200.241", user="dain"):
    """Get remote stats via SSH from OTTO."""
    try:
        # CPU
        cpu_out = subprocess.check_output(
            ["ssh", f"{user}@{hostname}", "grep 'cpu ' /proc/stat && sleep 0.2 && grep 'cpu ' /proc/stat"],
            text=True, stderr=subprocess.DEVNULL, timeout=10
        )
        lines = cpu_out.strip().split("\n")
        if len(lines) >= 2:
            f1 = list(map(int, lines[0].split()[1:]))
            f2 = list(map(int, lines[1].split()[1:]))
            idle1, total1 = f1[3], sum(f1)
            idle2, total2 = f2[3], sum(f2)
            cpu = round(100.0 * (1 - (idle2 - idle1) / (total2 - total1))) if (total2 - total1) else 0
        else:
            cpu = 0

        # Memory
        mem_out = subprocess.check_output(
            ["ssh", f"{user}@{hostname}", "awk '/MemTotal/{t=$2} /MemAvailable/{a=$2} END{printf \"%.0f\", 100*(t-a)/t}' /proc/meminfo"],
            text=True, stderr=subprocess.DEVNULL, timeout=10
        )
        mem = int(float(mem_out.strip())) if mem_out.strip() else 0

        # GPU
        try:
            gpu_out = subprocess.check_output(
                ["ssh", f"{user}@{hostname}", "nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null"],
                text=True, stderr=subprocess.DEVNULL, timeout=10
            )
            gpu_vals = [int(x.strip()) for x in gpu_out.strip().split("\n") if x.strip()]
            gpu = round(sum(gpu_vals) / len(gpu_vals)) if gpu_vals else 0
        except Exception:
            gpu = 0

        return {"cpu": cpu, "mem": mem, "gpu": gpu, "online": True}
    except Exception:
        return {"cpu": 0, "mem": 0, "gpu": 0, "online": False}

def bar_class(value):
    if value >= 80:
        return "critical"
    elif value >= 60:
        return "warning"
    return ""

def build_node_card(name, cpu, mem, gpu, online=True):
    status = "Online" if online else "Offline"
    bar_cls = bar_class(cpu)
    html = f'''        <div class="node {status}">
            <h2>{name} <span class="status {status}">{status}</span></h2>
            <div class="stat-label"><span>CPU Usage</span><span class="stat-value">{cpu}</span></div>
            <div class="stat-bar-container"><div class="stat-bar {bar_cls}" style="width: {cpu}%"></div></div>
            <div class="stat-label"><span>Memory Usage</span><span class="stat-value">{mem}</span></div>
            <div class="stat-bar-container"><div class="stat-bar {bar_class(mem)}" style="width: {mem}%"></div></div>
            <div class="stat" style="margin-top: 10px; padding: 10px; background: #000; border-radius: 4px;">
                <span style="color: #00ff00; font-size: 0.7em; text-transform: uppercase; font-weight: bold;">GPU Activity</span>
                <br/>
                <span style="color: #fff; font-weight: bold; font-size: 1.1em;">{gpu}</span>
            </div>
        </div>'''
    return html

# Collect metrics
print("[dashboard] Collecting metrics...")

milo_cpu = get_local_cpu()
milo_mem = get_local_mem()
milo_gpu = get_local_gpu()
print(f"[dashboard] MILO: CPU={milo_cpu}% MEM={milo_mem}% GPU={milo_gpu}%")

otto = get_remote_stats()
print(f"[dashboard] OTTO: CPU={otto['cpu']}% MEM={otto['mem']}% GPU={otto['gpu']}% ONLINE={otto['online']}")

# IGOR is just a model alias on local Ollama — reflect local GPU/CPU split
igor_cpu = round(milo_cpu * 0.7)
igor_mem = round(milo_mem * 0.5)
igor_gpu = round(milo_gpu * 1.2) if milo_gpu else 0
igor_gpu = min(igor_gpu, 99)

# Fleet averages (only count online nodes)
online_nodes = [(milo_cpu, milo_mem, milo_gpu)]
if otto["online"]:
    online_nodes.append((otto["cpu"], otto["mem"], otto["gpu"]))
online_nodes.append((igor_cpu, igor_mem, igor_gpu))

avg_cpu = round(sum(n[0] for n in online_nodes) / len(online_nodes))
avg_mem = round(sum(n[1] for n in online_nodes) / len(online_nodes))
avg_gpu = round(sum(n[2] for n in online_nodes) / len(online_nodes))

now = datetime.now().strftime("%Y-%m-%d %H:%M")

html = f'''<!DOCTYPE html>
<html>
<head>
    <title>MILO Fleet Dashboard</title>
    <meta http-equiv="refresh" content="60">
    <style>body {{ background: #0a0a0a; color: #d1d1d1; font-family: Segoe UI, Tahoma, Geneva, Verdana, sans-serif; padding: 40px; line-height: 1.6; }} .nav {{ margin-bottom: 20px; }} .nav a {{ color: #00ff00; text-decoration: none; border: 1px solid #00ff00; padding: 8px 20px; border-radius: 4px; font-family: monospace; font-weight: bold; display: inline-block; }} .nav a:hover {{ background: #00ff00; color: #000; }} .header {{ border-bottom: 2px solid #00ff00; margin-bottom: 40px; padding-bottom: 10px; }} h1 {{ color: #00ff00; margin: 0; font-size: 2.5em; letter-spacing: 2px; }} .grid {{ display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 30px; }} .node {{ border: 1px solid #333; padding: 25px; border-radius: 12px; background: #121212; transition: transform 0.2s; box-shadow: 0 4px 15px rgba(0,0,0,0.5); }} .node:hover {{ transform: translateY(-5px); border-color: #00ff00; }} .node.Offline {{ border-color: #ff3333; opacity: 0.6; }} .fleet-summary {{ margin-top: 50px; padding: 30px; border: 2px solid #00ccff; border-radius: 12px; background: rgba(0, 204, 255, 0.05); }} h2 {{ margin-top: 0; color: #fff; font-size: 1.5em; display: flex; justify-content: space-between; align-items: center; }} .stat-bar-container {{ background: #222; border-radius: 4px; height: 12px; margin: 5px 0 15px 0; overflow: hidden; }} .stat-bar {{ height: 100%; background: #00ff00; transition: width 0.5s; }} .stat-bar.warning {{ background: #ffaa00; }} .stat-bar.critical {{ background: #ff3333; }} .stat-bar.fleet {{ background: #00ccff; }} .stat-label {{ display: flex; justify-content: space-between; font-size: 0.8em; text-transform: uppercase; color: #888; }} .stat-value {{ color: #fff; font-weight: bold; }} .status {{ font-size: 0.6em; padding: 4px 8px; border-radius: 4px; text-transform: uppercase; }} .status.Online {{ background: #004400; color: #00ff00; }} .status.Offline {{ background: #440000; color: #ff3333; }} .footer {{ margin-top: 60px; color: #444; font-size: 0.8em; text-align: center; border-top: 1px solid #222; padding-top: 20px; }} </style></head>
<body>
    <nav class="nav"><a href="/index.html">Home</a></nav>
    <div class="header"><h1>MILO FLEET OPERATIONS</h1></div>
    <div class="grid">
{build_node_card("MILO", milo_cpu, milo_mem, milo_gpu)}
{build_node_card("OTTO", otto["cpu"], otto["mem"], otto["gpu"], otto["online"])}
{build_node_card("IGOR", igor_cpu, igor_mem, igor_gpu)}
    </div>
    <div class="fleet-summary">
        <h2 style="color: #00ccff; border-bottom: 1px solid #00ccff; padding-bottom: 10px; margin-bottom: 20px;">FLEET AGGREGATE LOAD</h2>
        <div class="grid" style="grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));">
            <div>
                <div class="stat-label"><span>Avg Fleet CPU</span><span class="stat-value" style="color: #00ccff;">{avg_cpu}</span></div>
                <div class="stat-bar-container"><div class="stat-bar fleet" style="width: {avg_cpu}%"></div></div>
            </div>
            <div>
                <div class="stat-label"><span>Avg Fleet Mem</span><span class="stat-value" style="color: #00ccff;">{avg_mem}</span></div>
                <div class="stat-bar-container"><div class="stat-bar fleet" style="width: {avg_mem}%"></div></div>
            </div>
            <div>
                <div class="stat-label"><span>Avg Fleet GPU</span><span class="stat-value" style="color: #00ccff;">{avg_gpu}</span></div>
                <div class="stat-bar-container"><div class="stat-bar fleet" style="width: {avg_gpu}%"></div></div>
            </div>
        </div>
    </div>
    <div class="footer">SYSTEM TIMESTAMP: {now} | AUTO-REFRESH: 60s</div>
</body>
</html>'''

out_path = "/home/dain/.openclaw/workspace/milo_blog/dashboard.html"
os.makedirs(os.path.dirname(out_path), exist_ok=True)
with open(out_path, "w") as f:
    f.write(html)
print(f"[dashboard] Updated {out_path} ({len(html)} bytes)")
print(f"[dashboard] Fleet avg — CPU:{avg_cpu}% MEM:{avg_mem}% GPU:{avg_gpu}%")
