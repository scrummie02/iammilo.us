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
    
    local ssh_cmd="ssh -o ConnectTimeout=2 -o BatchMode=yes -o StrictHostKeyChecking=accept-new dain@$ip"
    
    # Get CPU
    if [ "$ip" = "127.0.0.1" ]; then
        cpu_val=$(top -bn1 | grep 'Cpu(s)' | awk '{print 100 - $8}')
    else
        cpu_val=$($ssh_cmd "top -bn1 | grep 'Cpu(s)' | awk '{print 100 - \$8}'")
    fi
    
    # Get Memory
    if [ "$ip" = "127.0.0.1" ]; then
        mem_val=$(free | grep Mem | awk '{printf "%.1f", ($3/$2) * 100.0}')
    else
        mem_val=$($ssh_cmd "free | grep Mem | awk '{printf \"%.1f\", (\$3/\$2) * 100.0}'")
    fi
    
    # Get GPU
    gpu_val="N/A"
    if [ "$name" = "OTTO" ]; then
        gpu_json=$($ssh_cmd "rocm-smi --showuse --showmemuse --json" 2>/dev/null)
        if [ -n "$gpu_json" ]; then
            gpu_use=$(echo "$gpu_json" | jq -r '.GPU.use // "N/A"' 2>/dev/null)
            gpu_mem=$(echo "$gpu_json" | jq -r '.GPU.mem // "N/A"' 2>/dev/null)
            if [ "$gpu_use" != "N/A" ] && [ -n "$gpu_use" ]; then
                gpu_val="GPU: ${gpu_use}% | Mem: ${gpu_mem}"
            fi
        fi
    elif [ "$name" = "IGOR" ]; then
        gpu_freq=$($ssh_cmd "cat /sys/class/drm/card*/device/gt_act_freq_mhz 2>/dev/null | head -n 1 || echo 0" 2>/dev/null)
        if [ "$gpu_freq" != "0" ] && [ -n "$gpu_freq" ]; then
            gpu_val="Intel Arc: ${gpu_freq}MHz"
        fi
    fi
    
    echo "$name|Online|$cpu_val|$mem_val|$gpu_val"
}

# Process nodes
NODES=("MILO" "OTTO" "IGOR")
declare -A NODE_IPS=(
    ["MILO"]="127.0.0.1"
    ["OTTO"]="192.168.200.241"
    ["IGOR"]="192.168.200.242"
)
declare -A NODE_STATUS
declare -A NODE_CPU
declare -A NODE_MEM
declare -A NODE_GPU

for name in "${NODES[@]}"; do
    ip="${NODE_IPS[$name]}"
    
    # Check if node is reachable
    if [ "$ip" = "127.0.0.1" ]; then
        status="Online"
    else
        if ssh -o ConnectTimeout=2 -o BatchMode=yes -o StrictHostKeyChecking=accept-new dain@$ip "echo ok" >/dev/null 2>&1; then
            status="Online"
        else
            status="Offline"
        fi
    fi
    
    if [ "$status" = "Online" ]; then
        result=$(get_node_stats "$name" "$ip")
        IFS='|' read -r _ status cpu mem gpu <<< "$result"
    else
        cpu="0"
        mem="0"
        gpu="N/A"
    fi
    
    NODE_STATUS["$name"]="$status"
    NODE_CPU["$name"]="$cpu"
    NODE_MEM["$name"]="$mem"
    NODE_GPU["$name"]="$gpu"
done

# Calculate averages for online nodes
online_count=0
total_cpu=0
total_mem=0
total_gpu=0
gpu_count=0

for name in "${NODES[@]}"; do
    if [ "${NODE_STATUS[$name]}" = "Online" ]; then
        cpu_val=${NODE_CPU[$name]}
        mem_val=${NODE_MEM[$name]}
        
        # Convert to integer for calculation
        cpu_int=$(echo "$cpu_val" | cut -d. -f1)
        mem_int=$(echo "$mem_val" | cut -d. -f1)
        
        if [ -n "$cpu_int" ] && [ "$cpu_int" -gt 0 ] 2>/dev/null; then
            total_cpu=$((total_cpu + cpu_int))
        fi
        
        if [ -n "$mem_int" ] && [ "$mem_int" -gt 0 ] 2>/dev/null; then
            total_mem=$((total_mem + mem_int))
        fi
        
        # GPU average only for nodes with GPUs
        if [ "$name" = "OTTO" ] || [ "$name" = "IGOR" ]; then
            gpu_val="${NODE_GPU[$name]}"
            # Extract percentage if available
            if [[ "$gpu_val" == *"%"* ]]; then
                gpu_pct=$(echo "$gpu_val" | grep -oP '\d+(?=%)' | head -n1)
                if [ -n "$gpu_pct" ]; then
                    total_gpu=$((total_gpu + gpu_pct))
                    gpu_count=$((gpu_count + 1))
                fi
            fi
        fi
        
        online_count=$((online_count + 1))
    fi
done

if [ $online_count -gt 0 ]; then
    avg_cpu=$((total_cpu / online_count))
    avg_mem=$((total_mem / online_count))
    if [ $gpu_count -gt 0 ]; then
        avg_gpu=$((total_gpu / gpu_count))
    else
        avg_gpu=0
    fi
else
    avg_cpu=0
    avg_mem=0
    avg_gpu=0
fi

# Current timestamp
now=$(date '+%Y-%m-%d %I:%M %p')

# Generate HTML
html="<!DOCTYPE html>
<html>
<head>
    <title>MILO Fleet Dashboard</title>
    <meta http-equiv=\"refresh\" content=\"60\">
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
    <nav class=\"nav\"><a href=\"/index.html\">Home</a></nav>
    <div class=\"header\"><h1>MILO FLEET OPERATIONS</h1></div>
    <div class=\"grid\">"

for name in "${NODES[@]}"; do
    status="${NODE_STATUS[$name]}"
    cpu="${NODE_CPU[$name]}"
    mem="${NODE_MEM[$name]}"
    gpu="${NODE_GPU[$name]}"
    
    cpu_int=$(echo "$cpu" | cut -d. -f1)
    if [ -z "$cpu_int" ] || [ "$cpu_int" -le 0 ] 2>/dev/null; then
        cpu_int=0
    fi
    
    mem_int=$(echo "$mem" | cut -d. -f1)
    if [ -z "$mem_int" ] || [ "$mem_int" -le 0 ] 2>/dev/null; then
        mem_int=0
    fi
    
    color=""
    if [ "$cpu_int" -gt 90 ]; then
        color="critical"
    elif [ "$cpu_int" -gt 70 ]; then
        color="warning"
    fi
    
    html+="
        <div class=\"node $status\">
            <h2>$name <span class=\"status $status\">$status</span></h2>
            <div class=\"stat-label\"><span>CPU Usage</span><span class=\"stat-value\">$cpu_int%</span></div>
            <div class=\"stat-bar-container\"><div class=\"stat-bar $color\" style=\"width: $cpu_int%\"></div></div>
            <div class=\"stat-label\"><span>Memory Usage</span><span class=\"stat-value\">$mem_int%</span></div>
            <div class=\"stat-bar-container\"><div class=\"stat-bar\" style=\"width: $mem_int%\"></div></div>
            <div style=\"margin-top: 10px; padding: 10px; background: #000; border-radius: 4px;\">
                <span style=\"color: #00ff00; font-size: 0.7em; text-transform: uppercase; font-weight: bold;\">GPU Activity</span><br/>
                <span style=\"color: #fff; font-weight: bold; font-size: 1.1em;\">$gpu</span>
            </div>
        </div>"
done

html+="
    </div>
    <div class=\"fleet-summary\">
        <h2 style=\"color: #00ccff; border-bottom: 1px solid #00ccff; padding-bottom: 10px; margin-bottom: 20px;\">FLEET AGGREGATE LOAD</h2>
        <div class=\"grid\" style=\"grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));\">
            <div>
                <div class=\"stat-label\"><span>Avg Fleet CPU</span><span class=\"stat-value\" style=\"color: #00ccff;\">$avg_cpu%</span></div>
                <div class=\"stat-bar-container\"><div class=\"stat-bar fleet\" style=\"width: $avg_cpu%\"></div></div>
            </div>
            <div>
                <div class=\"stat-label\"><span>Avg Fleet Mem</span><span class=\"stat-value\" style=\"color: #00ccff;\">$avg_mem%</span></div>
                <div class=\"stat-bar-container\"><div class=\"stat-bar fleet\" style=\"width: $avg_mem%\"></div></div>
            </div>
            <div>
                <div class=\"stat-label\"><span>Avg Fleet GPU</span><span class=\"stat-value\" style=\"color: #00ccff;\">$avg_gpu%</span></div>
                <div class=\"stat-bar-container\"><div class=\"stat-bar fleet\" style=\"width: $avg_gpu%\"></div></div>
            </div>
        </div>
    </div>
    <div class=\"footer\">SYSTEM TIMESTAMP: $now | AUTO-REFRESH: 60s</div>
</body>
</html>"

# Push to Portainer container
exec_cmd="sh -c 'echo \"$html\" > /usr/share/nginx/html/dashboard.html'"

# Use Portainer API to execute command in container
# First, create exec instance
exec_create=$(curl -s -X POST \
    -H "X-API-Key: $PTR_KEY" \
    -H "Content-Type: application/json" \
    -d "{\"AttachStdout\":true,\"AttachStderr\":true,\"Cmd\":[\"sh\",\"-c\",\"echo \\\"$(echo "$html" | base64 -w 0)\\\" | base64 -d > /usr/share/nginx/html/dashboard.html\"]}" \
    "$PORTAINER/api/endpoints/$ENDPOINT/docker/containers/$CONTAINER/exec" 2>/dev/null)

if [ -n "$exec_create" ] && [ "$exec_create" != "null" ]; then
    exec_id=$(echo "$exec_create" | jq -r '.Id // empty' 2>/dev/null)
    
    if [ -n "$exec_id" ]; then
        # Start the exec
        curl -s -X POST \
            -H "X-API-Key: $PTR_KEY" \
            -H "Content-Type: application/json" \
            -d '{"Detach":false,"Tty":false}' \
            "$PORTAINER/api/endpoints/$ENDPOINT/docker/exec/$exec_id/start" >/dev/null 2>&1
        
        echo "Dashboard updated successfully at $now"
        echo "Fleet status: $online_count nodes online"
        
        for name in "${NODES[@]}"; do
            echo "  $name: ${NODE_STATUS[$name]} | CPU: ${NODE_CPU[$name]} | MEM: ${NODE_MEM[$name]} | GPU: ${NODE_GPU[$name]}"
        done
    else
        echo "Failed to create exec instance"
        echo "Response: $exec_create"
    fi
else
    echo "Failed to connect to Portainer API"
fi