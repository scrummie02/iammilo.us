#!/bin/bash
# Setup script for gas prices daily report
# Run this to add the cron job manually

CRON_ENTRY="0 8 * * 1 /home/dain/.openclaw/workspace/gas_prices_daily_report.sh >> /home/dain/.openclaw/workspace/logs/gas_prices.log 2>&1  # Weekly: Mondays at 8 AM"

echo "To set up daily gas prices reports at 8 AM, run:"
echo ""
echo "  crontab -e"
echo ""
echo "Then add this line:"
echo ""
echo "  $CRON_ENTRY"
echo ""
echo "Or run this one-liner:"
echo ""
echo "  (crontab -l 2>/dev/null; echo '$CRON_ENTRY') | crontab -"
echo ""

# Create logs directory
mkdir -p /home/dain/.openclaw/workspace/logs
echo "✓ Created logs directory"

# Show current crontab
echo ""
echo "Current crontab:"
crontab -l 2>/dev/null || echo "(no crontab set)"
