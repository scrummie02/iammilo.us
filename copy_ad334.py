#!/usr/bin/env python3
import subprocess, os, re

ENV = {**os.environ, "GOG_ACCOUNT": "dain.bentley@gmail.com"}
LES_SRC = "1pH7giw6ogQ54h3P5OUlPbUo3SaLGVt8Y"
LES_DEST = "18hcsHs8zgB3SHfTlk2t3rrhre-wFeUQV"
LOG = "/home/dain/.openclaw/workspace/copy_ad334.log"

def gog_ls(parent, max=500):
    r = subprocess.run(
        ["gog", "drive", "ls", "--parent", parent, "--plain", f"--max={max}"],
        capture_output=True, text=True, env=ENV, stdin=subprocess.DEVNULL, timeout=30
    )
    items = []
    for line in r.stdout.strip().split("\n")[1:]:
        parts = line.split("\t")
        if len(parts) >= 3:
            items.append((parts[0], parts[1], parts[2]))
    return items

def gog_copy(file_id, name, dest_id):
    r = subprocess.run(
        ["gog", "drive", "copy", file_id, name, "--parent", dest_id, "--plain"],
        capture_output=True, text=True, env=ENV, stdin=subprocess.DEVNULL, timeout=60
    )
    if r.returncode == 0 and r.stdout.strip():
        return r.stdout.strip().split("\n")[0].split("\t")[0]
    return ""

items = gog_ls(LES_SRC, max=500)
ad_files = [(fid, fname) for fid, fname, ftype in items if fname.upper().startswith("FORM AD")]

print(f"Found {len(ad_files)} AD-334 files")

success = failed = 0
with open(LOG, "w") as log:
    log.write(f"Found {len(ad_files)} AD-334 files\n\n")
    for i, (fid, fname) in enumerate(sorted(ad_files, key=lambda x: x[1]), 1):
        result = gog_copy(fid, fname, LES_DEST)
        if result:
            msg = f"✓ [{i}/{len(ad_files)}] {fname}"
            success += 1
        else:
            msg = f"✗ [{i}/{len(ad_files)}] FAIL: {fname}"
            failed += 1
        print(msg, flush=True)
        log.write(msg + "\n")
        log.flush()

    summary = f"\nDone: {success} copied, {failed} failed"
    print(summary)
    log.write(summary + "\n")

print("COPY_COMPLETE")
