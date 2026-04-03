#!/bin/bash
# Fetch emails via gog and POST to N8N webhook for AI categorization + Telegram delivery
# Usage: send_email_digest.sh [personal|biz]

ACCOUNT="${1:-personal}"
N8N_WEBHOOK="http://192.168.200.223:5678/webhook/email-digest"

if [ "$ACCOUNT" = "biz" ]; then
    EMAIL="info@dainbentley.com"
    LABEL="💼 Biz"
else
    EMAIL="dain.bentley@gmail.com"
    LABEL="Personal"
fi

# Fetch last 24h of inbox
EMAILS=$(GOG_KEYRING_PASSWORD=milo-gog-keyring \
    /home/linuxbrew/.linuxbrew/bin/gog gmail search \
    "in:inbox newer_than:1d" \
    --account="$EMAIL" \
    --max 50 \
    --plain 2>/dev/null)

if [ -z "$EMAILS" ]; then
    echo "No emails found for $EMAIL"
    exit 0
fi

# POST to N8N webhook
curl -s -X POST "$N8N_WEBHOOK" \
    -H "Content-Type: application/json" \
    -d "{\"emails\": $(echo "$EMAILS" | python3 -c 'import sys,json; print(json.dumps(sys.stdin.read()))'), \"account\": \"$LABEL\"}"

echo "✓ Sent to N8N digest pipeline"
