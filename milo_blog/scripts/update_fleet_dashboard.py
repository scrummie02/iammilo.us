#!/usr/bin/env python3
"""
Auto-refresh the MILO Fleet Dashboard.
This script runs every 60 seconds to update the dashboard.html file
with current node states and fleet aggregates.
"""

import subprocess
import sys
import time
import os

BASE_URL = os.environ.get('FLEET_BASE_URL', 'http://localhost:8080')

def refresh_dashboard():
    """Update the dashboard.html file with current node states and metrics."""
    try:
        result = subprocess.run(
            ["python3", "scripts/refresh_dashboard.py"],
            capture_output=True,
            text=True,
            timeout=60
        )
        return result.returncode == 0
    except Exception as e:
        print(f"Error updating dashboard: {e}", file=sys.stderr)
        return False

def main():
    print("🔄 Fleet Dashboard Auto-Refresher")
    print(f"   Base URL: {BASE_URL}")
    print(f"   Heartbeat interval: 60s")
    print()
    
    # Refresh immediately
    print("Starting dashboard refresh...")
    if refresh_dashboard():
        print("✅ Dashboard refresh completed successfully.")
    else:
        print("⚠️  Dashboard refresh failed.")
        print("   Check the output above for details.")
    
    # Auto-refresh scheduled
    print("\n⏰ Starting auto-refresh in 60 seconds...")
    while True:
        time.sleep(60)
        if not refresh_dashboard():
            print("⚠️  Auto-refresh failed.")
            print("   Please check the dashboard for manual updates.")
            break

if __name__ == "__main__":
    main()
