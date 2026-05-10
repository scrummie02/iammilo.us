#!/usr/bin/env python3
"""
Dashboard refresh daemon - runs continuously and refreshes the fleet dashboard every 60 seconds.
Usage: python3 dashboard_daemon.py [start|stop|status]
"""

import os
import sys
import time
import subprocess
import signal
import atexit

PIDFILE = "/tmp/dashboard_daemon.pid"
SCRIPT = "/home/dain/.openclaw/workspace/scripts/refresh_dashboard.py"
INTERVAL = 60

def get_pid():
    if os.path.exists(PIDFILE):
        try:
            with open(PIDFILE) as f:
                return int(f.read().strip())
        except ValueError:
            return None
    return None

def is_running(pid):
    try:
        os.kill(pid, 0)
        return True
    except ProcessLookupError:
        return False

def start():
    pid = get_pid()
    if pid and is_running(pid):
        print(f"Dashboard daemon already running (PID {pid})")
        sys.exit(1)
    
    # Fork to background
    if os.fork() > 0:
        sys.exit(0)
    
    os.setsid()
    if os.fork() > 0:
        sys.exit(0)
    
    # Write pidfile
    with open(PIDFILE, "w") as f:
        f.write(str(os.getpid()))
    
    atexit.register(lambda: os.path.exists(PIDFILE) and os.remove(PIDFILE))
    
    # Main loop
    print(f"[daemon] Starting dashboard refresh every {INTERVAL}s")
    while True:
        try:
            result = subprocess.run(
                [sys.executable, SCRIPT],
                capture_output=True, text=True, timeout=30
            )
            if result.returncode != 0:
                print(f"[daemon] Refresh failed: {result.stderr}", file=sys.stderr)
            else:
                print(f"[daemon] {time.strftime('%H:%M:%S')} - Refreshed OK")
        except Exception as e:
            print(f"[daemon] Error: {e}", file=sys.stderr)
        
        time.sleep(INTERVAL)

def stop():
    pid = get_pid()
    if not pid:
        print("Daemon not running")
        return
    
    try:
        os.kill(pid, signal.SIGTERM)
        print(f"Stopped daemon (PID {pid})")
    except ProcessLookupError:
        print("Daemon already stopped")
    finally:
        if os.path.exists(PIDFILE):
            os.remove(PIDFILE)

def status():
    pid = get_pid()
    if pid and is_running(pid):
        print(f"Dashboard daemon running (PID {pid})")
        return 0
    else:
        print("Dashboard daemon not running")
        if os.path.exists(PIDFILE):
            os.remove(PIDFILE)
        return 1

def run_once():
    """Run a single refresh cycle (for testing or manual runs)."""
    try:
        result = subprocess.run(
            [sys.executable, SCRIPT],
            capture_output=True, text=True, timeout=30
        )
        print(result.stdout)
        if result.stderr:
            print(result.stderr, file=sys.stderr)
        return result.returncode
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        return 1

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: dashboard_daemon.py [start|stop|status|once]")
        print("  start  - Start daemon in background")
        print("  stop   - Stop running daemon")
        print("  status - Check daemon status")
        print("  once   - Run one refresh cycle")
        sys.exit(1)
    
    cmd = sys.argv[1].lower()
    if cmd == "start":
        start()
    elif cmd == "stop":
        stop()
    elif cmd == "status":
        sys.exit(status())
    elif cmd == "once":
        sys.exit(run_once())
    else:
        print(f"Unknown command: {cmd}")
        sys.exit(1)
