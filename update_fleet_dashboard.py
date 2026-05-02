#!/usr/bin/env python3
"""Refresh Fleet Dashboard script."""

import asyncio
import json
import os
import subprocess
import time

async def main():
    """Refresh the fleet dashboard."""
    dashboard_file = "dashboard.html"
    
    print("🔄 Refreshing fleet dashboard...")
    
    try:
        # Run the script in background
        result = subprocess.run(
            ["python3", "scripts/refresh_dashboard.py"],
            capture_output=True,
            text=True,
            timeout=300,
            cwd="/home/dain/.openclaw/workspace"
        )
        
        print(f"Exit code: {result.returncode}")
        print(f"Stdout: {result.stdout}")
        print(f"Stderr: {result.stderr}")
        
        if result.returncode == 0:
            print("✅ Dashboard updated successfully!")
        else:
            print("⚠️  Warning: Dashboard may not have updated successfully.")
            print("   Check the console output above.")
        
    except subprocess.TimeoutExpired:
        print("❌ Command timed out.")
    except Exception as e:
        print(f"❌ Error: {e}")

if __name__ == "__main__":
    asyncio.run(main())
