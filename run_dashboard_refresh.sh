#!/bin/bash
# Run the dashboard refresh script

echo "🔄 Running dashboard refresh..."

# Run the script directly
cd /home/dain/.openclaw/workspace
timeout 300 python3 scripts/refresh_dashboard.py
