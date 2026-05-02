#!/bin/bash
#
# Refresh Fleet Dashboard from Portainer
# Author: Dain Bentley Management LLC
#

PORTAINER="http://192.168.200.220:9000"
PTR_KEY="ptr_jVGvpkWmxmPusWm3yZYeEvMU8LLMvYjqDm8iLmsRQjk="
CONTAINER="milo_blog"
ENDPOINT=7

# Get node stats using SSH
get_node_stats() {
    local name=$1
    local ip=$2
    
    local ssh_prefix="ssh -o ConnectTimeout=2 -o BatchMode=yes dain@"
    
    if [ "$name" == "MILO" ] || [ "$name" == "OTTO" ]; then
        if [ "$name" == "OTTO" ]; then
            ssh_prefix+=" \" "
        fi
        ssh_prefix+=" rocm-smi --showuse --showmemuse --json"
        if [ "$name" == "OTTO" ]; then
            ssh_prefix+=" "
        fi
    fi
    
    if [ "$name" == "IGOR" ]; then
        ssh_prefix+=" cat /sys/class/drm/card*/device/gt_act_freq_mhz 2>/dev/null | head -n 1 || echo 0"
    fi
    
    # Build the full SSH command
    ssh_cmd="$ssh_prefix $@"
    
    # Get CPU
    if [ "$ip" = "127.0.0.1" ]; then
        cpu_val=$(ssh_cmd "top -bn1 | grep 'Cpu(s)' | awk '{print 100 - $8}'")
    else
        cpu_val=$(ssh_cmd "top -bn1 | grep 'Cpu(s)' | awk '{print 100 - $8}'")
    fi
    
    # Get Memory
    if [ "$ip" = "127.0.0.1" ]; then
        mem_val=$(ssh_cmd "free | grep Mem | awk '{printf \"%.1f\", ($3/$2) * 100.0}'")
    else
        mem_val=$(ssh_cmd "free | grep Mem | awk '{printf \"%.1f\", ($3/$2) * 100.0}'")
    fi
    
    # Get GPU
    gpu_val=$(ssh_cmd "$cpu_val")
    gpu_val=$(ssh_cmd "rocm-smi --showuse --showmemuse --json" | jq -r '.GPU.use; .GPU.mem')
    
    # Parse GPU info
    if [ "$gpu_val" != "N/A" ] && [ -n "$gpu_val" ]; then
        if [[ "$gpu_val" == *":"* ]]; then
            gpu_info="${gpu_val%%:*}"
            gpu_mem="${gpu_val#*:}"
            gpu_pct=$(echo "$gpu_mem" | cut -d' ' -f1)
            gpu_mem=$(echo "$gpu_mem" | cut -d' ' -f2-)
            gpu_info="${gpu_pct}%"
            gpu_val="$gpu_info $gpu_mem"
        elif [ "$gpu_val" != "0" ] && [ "$gpu_val" != "N/A" ]; then
            gpu_val="Intel Arc: $gpu_val"
        fi
    fi
    
    echo "$name|$status|cpu|$mem|$gpu"
}

# Process nodes
NODES=("MILO" "OTTO" "IGOR")
declare -A NODE_IPS=("127.0.0.1" "192.168.200.241" "192.168.200.242")
declare -A NODE_STATUS=("Online" "Online" "Online")
declare -A NODE_CPU=("0" "0" "0")
declare -A NODE_MEM=("0" "0" "0")
declare -A NODE_GPU=("N/A" "N/A" "N/A")

declare -A ALL_STATUS
declare -A AVG_CPU
declare -A AVG_MEM
declare -A AVG_GPU

for i in "${!NODES[@]}"; do
    name="${NODES[$i]}"
    ip="${NODE_IPS[$i]}"
    
    status=$(get_node_stats "$name" "$ip")
    IFS='|' read -r name status cpu mem gpu <<< "$status"
    ALL_STATUS["$name"]="$status"
    NODE_STATUS["$name"]="$status"
    NODE_CPU["$name"]="$cpu"
    NODE_MEM["$name"]="$mem"
    NODE_GPU["$name"]="$gpu"
    
    # Update fleet averages if needed
    if [ "$status" == "Online" ]; then
        cpu_int=${cpu%.*}
        if [ -n "$cpu_int" ] && [ "$cpu_int" -gt 0 ] 2>/dev/null; then
            AVG_CPU[$name]=$cpu_int
        fi
        mem_int=${mem%.*}
        if [ -n "$mem_int" ] && [ "$mem_int" -gt 0 ] 2>/dev/null; then
            AVG_MEM[$name]=$mem_int
        fi
        if [ "$name" != "MILO" ] && [ "$name" != "IGOR" ]; then
            AVG_GPU[$name]=$((AVG_GPU[$name] / 2))
        fi
    fi
done

# Calculate averages
online_count=${#ALL_STATUS[@]}
online_nodes=("${!ALL_STATUS[@]}")
if [ $online_count -gt 0 ]; then
    if [ $online_count -eq 3 ]; then
        avg_cpu=$(echo "${NODE_CPU[@]}" | awk '{print $1}')
        avg_mem=$(echo "${NODE_MEM[@]}" | awk '{print $1}')
        avg_gpu=$(echo "${NODE_GPU[@]}" | awk '{print $1}')
    else
        avg_cpu=$(echo "${NODE_CPU[@]}" | awk '{print $1}')
        avg_mem=$(echo "${NODE_MEM[@]}" | awk '{print $1}')
        avg_gpu=$(echo "${NODE_GPU[@]}" | awk '{print $1}')
    fi
else
    avg_cpu=0
    avg_mem=0
    avg_gpu=0
fi

# Generate HTML
now="2026-04-28 12:44 AM"
html='<!DOCTYPE html>\n<html>\n<head>\n    <title>MILO Fleet Dashboard</title>\n    <meta http-equiv="refresh" content="60">\n    <style>\n        body { background: #0a0a0a; color: #d1d1d1; font-family: Segoe UI, Tahoma, Geneva, Verdana, sans-serif; padding: 40px; line-height: 1.6; }\n        .nav { margin-bottom: 20px; }\n        .nav a { color: #00ff00; text-decoration: none; border: 1px solid #00ff00; padding: 8px 20px; border-radius: 4px; font-family: monospace; font-weight: bold; display: inline-block; }\n        .nav a:hover { background: #00ff00; color: #000; }\n        .header { border-bottom: 2px solid #00ff00; margin-bottom: 40px; padding-bottom: 10px; }\n        h1 { color: #00ff00; margin: 0; font-size: 2.5em; letter-spacing: 2px; }\n        .grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 30px; }\n        .node { border: 1px solid #333; padding: 25px; border-radius: 12px; background: #121212; transition: transform 0.2s; box-shadow: 0 4px 15px rgba(0,0,0,0.5); }\n        .node:hover { transform: translateY(-5px); border-color: #00ff00; }\n        .node.Offline { border-color: #ff3333; opacity: 0.6; }\n        .fleet-summary { margin-top: 50px; padding: 30px; border: 2px solid #00ccff; border-radius: 12px; background: rgba(0, 204, 255, 0.05); }\n        h2 { margin-top: 0; color: #fff; font-size: 1.5em; display: flex; justify-content: space-between; align-items: center; }\n        .stat-bar-container { background: #222; border-radius: 4px; height: 12px; margin: 5px 0 15px 0; overflow: hidden; }\n        .stat-bar { height: 100%; background: #00ff00; transition: width 0.5s; }\n        .stat-bar.warning { background: #ffaa00; }\n        .stat-bar.critical { background: #ff3333; }\n        .stat-bar.fleet { background: #00ccff; }\n        .stat-label { display: flex; justify-content: space-between; font-size: 0.8em; text-transform: uppercase; color: #888; }\n        .stat-value { color: #fff; font-weight: bold; }\n        .status { font-size: 0.6em; padding: 4px 8px; border-radius: 4px; text-transform: uppercase; }\n        .status.Online { background: #004400; color: #00ff00; }\n        .status.Offline { background: #440000; color: #ff3333; }\n        .footer { margin-top: 60px; color: #444; font-size: 0.8em; text-align: center; border-top: 1px solid #222; padding-top: 20px; }\n    </style>\n</head>\n<body>\n    <nav class="nav"><a href="/index.html">Home</a></nav>\n    <div class="header"><h1>MILO FLEET OPERATIONS</h1></div>\n    <div class="grid">\n'

for i in "${!NODES[@]}"; do
    name="${NODES[$i]}"
    status="${NODE_STATUS[$i]}"
    cpu="${NODE_CPU[$i]}"
    mem="${NODE_MEM[$i]}"
    gpu="${NODE_GPU[$i]}"
    
    try
        cpu_int=${cpu%.*}
        if [ -n "$cpu_int" ] && [ "$cpu_int" -gt 0 ] 2>/dev/null; then
            cpu_pct=$cpu_int
        else
            cpu_pct=0
        fi
        
        mem_int=${mem%.*}
        if [ -n "$mem_int" ] && [ "$mem_int" -gt 0 ] 2>/dev/null; then
            mem_pct=$mem_int
        else
            mem_pct=0
        fi
        
        color="critical"
        if [ "$cpu_pct" -gt 90 ]; then
            color="critical"
        elif [ "$cpu_pct" -gt 70 ]; then
            color="warning"
        fi
        
        html+="<div class=\"node $status\">\n    <h2>$name <span class=\"status $status\">$status</span></h2>\n    <div class=\"stat-label\"><span>CPU Usage</span><span class=\"stat-value\">$cpu_pct%</span></div>\n    <div class=\"stat-bar-container\"><div class=\"stat-bar $color\" style=\"width: $cpu_pct%\"></div></div>\n    <div class=\"stat-label\"><span>Memory Usage</span><span class=\"stat-value\">$mem_pct%</span></div>\n    <div class=\"stat\" style=\"margin-top: 10px; padding: 10px; background: #000; border-radius: 4px;\">\n        <span style=\"color: #00ff00; font-size: 0.7em; text-transform: uppercase; font-weight: bold;\">GPU Activity</span><br/>\n        <span style=\"color: #fff; font-weight: bold; font-size: 1.1em;\">$gpu</span>\n    </div>\n</div>\n"
    fi
done

html+='\n    </div>\n    <div class="fleet-summary">\n        <h2 style="color: #00ccff; border-bottom: 1px solid #00ccff; padding-bottom: 10px; margin-bottom: 20px;">FLEET AGGREGATE LOAD</h2>\n        <div class="grid" style="grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));">\n            <div>\n                <div class="stat-label"><span>Avg Fleet CPU</span><span class="stat-value" style="color: #00ccff;">${avg_cpu}%</span></div>\n                <div class="stat-bar-container"><div class="stat-bar fleet" style="width: ${avg_cpu}%"></div></div>\n            </div>\n            <div>\n                <div class="stat-label"><span>Avg Fleet Mem</span><span class="stat-value" style="color: #00ccff;">${avg_mem}%</span></div>\n                <div class="stat-bar-container"><div class="stat-bar fleet" style="width: ${avg_mem}%"></div></div>\n            </div>\n            <div>\n                <div class="stat-label"><span>Avg Fleet GPU</span><span class="stat-value" style="color: #00ccff;">${avg_gpu}%</span></div>\n                <div class="stat-bar-container"><div class="stat-bar fleet" style="width: ${avg_gpu}%"></div></div>\n            </div>\n        </div>\n    </div>\n    <div class="footer">SYSTEM TIMESTAMP: ${now} | AUTO-REFRESH: 60s</div>\n</body>\n</html>'

# Generate base64-encoded HTML
html_b64=$(echo -n "$html" | base64 -w 0)

# Push to Portainer
exec_cmd="sh -c \"echo '$html_b64' | base64 -d > /usr/share/nginx/html/dashboard.html\""

echo "Pushing dashboard to Portainer..."
echo "Command: $exec_cmd"

try
    exec_result=$(curl -s -X POST \
        -H "X-API-Key: $PTR_KEY" \
        -H "Content-Type: application/json" \
        -H "AttachStdout: true" \
        -H "AttachStderr: true" \
        -d "$exec_cmd" \
        "http://$PORTAINER/api/endpoints/$ENDPOINT/docker/containers/$CONTAINER/exec" 2>/dev/null)
    
    echo "$exec_result"
    
    # Start the container
    start_cmd="exec $exec_result sh -c \"echo '$html_b64' | base64 -d > /usr/share/nginx/html/dashboard.html\""
    start_result=$(curl -s -X POST \
        -H "X-API-Key: $PTR_KEY" \
        -H "Content-Type: application/json" \
        -H "Detach: false" \
        -H "Tty: false" \
        -d "$start_cmd" \
        "http://$PORTAINER/api/endpoints/$ENDPOINT/docker/exec/$exec_result/start" 2>/dev/null)
    
    echo "$start_result"
    
    echo "Dashboard updated at $now"
    
except
    echo "Failed to push to Portainer: $exec_result"
fi
