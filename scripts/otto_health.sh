#!/bin/bash
MODE=$1
STATE_FILE="/tmp/otto_state"
BOT_TOKEN="8544365014:AAEgKwHUF7_iG2AizJND2NuOUouPE4uQymQ"
CHAT_ID="8305133249"

function send_alert() {
    curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
        -H "Content-Type: application/json" \
        -d "{\"chat_id\": \"${CHAT_ID}\", \"text\": \"🚨 *OTTO Alert*\\n\\n$1\", \"parse_mode\": \"Markdown\"}"
}

# 1. Ping Check
ping -c 1 -W 2 192.168.200.241 > /dev/null 2>&1
if [ $? -ne 0 ]; then
    if [ ! -f "$STATE_FILE" ] || [ "$(cat $STATE_FILE)" != "offline" ]; then
        send_alert "OTTO is **OFFLINE** (ping failed)."
        echo "offline" > "$STATE_FILE"
    fi
    exit 0
fi

if [ -f "$STATE_FILE" ] && [ "$(cat $STATE_FILE)" == "offline" ]; then
    send_alert "OTTO is back **ONLINE**."
    echo "online" > "$STATE_FILE"
fi
echo "online" > "$STATE_FILE"

# 2. Stats Check (if mode is 'stats')
if [ "$MODE" == "stats" ]; then
    STATS=$(ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 dain@192.168.200.241 "bash -c \"uptime && echo '---' && free -m && echo '---' && top -b -n1 | head -n 10 && echo '---' && if which rocm-smi >/dev/null 2>&1; then rocm-smi | grep -v 'WARNING' | grep -v 'Exception'; else echo 'No GPU detected'; fi\"" 2>/dev/null)
    if [ $? -ne 0 ]; then
        send_alert "Failed to SSH into OTTO for stats check."
        exit 0
    fi

    PROMPT="Analyze these Linux server stats:\n$STATS\nAre there any critical issues (extremely high load, CPU>90%, RAM almost full)? Answer with ONLY 'YES: <reason>' or 'NO'."
    
    JSON_PAYLOAD=$(jq -n --arg p "$PROMPT" '{model: "qwen2.5:7b", prompt: $p, stream: false}')
    
    RESPONSE=$(curl -s -X POST http://127.0.0.1:11434/api/generate -H "Content-Type: application/json" -d "$JSON_PAYLOAD" | jq -r '.response')
    
    if [[ "$RESPONSE" == YES* ]]; then
        send_alert "Abnormal stats detected by Qwen:\n$RESPONSE"
    fi
fi
