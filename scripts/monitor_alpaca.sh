#!/bin/bash
# Alpaca repo monitor - checks for new commits and notifies

REPO="scrummie02/Alpaca"
STATE_FILE="/home/dain/.openclaw/workspace/.alpaca_monitor_state"
DISCORD_WEBHOOK="https://discord.com/api/webhooks/1366894728249008218/TOKEN_PLACEHOLDER"

# Get latest commit
LATEST=$(gh api repos/$REPO/commits?per_page=1 --jq '.[0] | {sha: .sha[:7], message: .commit.message, author: .commit.author.name, date: .commit.author.date, url: .html_url}')

if [ -z "$LATEST" ]; then
    echo "Failed to fetch latest commit"
    exit 1
fi

SHA=$(echo "$LATEST" | jq -r '.sha')

# Check if we have a stored state
if [ -f "$STATE_FILE" ]; then
    LAST_SHA=$(cat "$STATE_FILE")
    if [ "$SHA" != "$LAST_SHA" ]; then
        echo "New commit detected: $SHA"
        # Could notify here
    fi
fi

# Update state
echo "$SHA" > "$STATE_FILE"
echo "$LATEST"