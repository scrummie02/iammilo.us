#!/usr/bin/env python3
import subprocess
import shutil
import os
import sys

LOG = "/home/dain/.openclaw/workspace/upload_government.log"
TMPDIR = "/home/dain/.openclaw/workspace/.upload_tmp"
FILELIST = "/home/dain/.openclaw/workspace/gov_filelist.txt"

os.makedirs(TMPDIR, exist_ok=True)

# Destination folder IDs
DEST = {
    "DoJ":      "1gohhFmGKEaw0a6BZJw4m4S8aCBafXw4Y",
    "eOPF":     "1xE9lAVWBabcPNmbGI5gPS-VocXVUgnpm",
    "VA":       "12cnpI5CkTJJIYaxF46duesPmPZJA4FhP",
    "Virginia": "1W-Pxi1gRVZ8zImBoBdawE89BrHJP4cHX",
    "CO":       "1Y6g2Ku8qidhwtGWDv6r0vHYuzQhqSU4Q",
    "IRS":      "1wRYULVRq-XtxtpIbMvhA7AAptoJIUs99",
    "SBA":      "1J-tXR61RGJocjET1oM458n08gTO7dtMy",
    "LES":      "18hcsHs8zgB3SHfTlk2t3rrhre-wFeUQV",
    "Resumes":  "1iHPZxzgZP-aWEpTCoWWHAP0JYx8JYHsk",
    "FAFSA":    "1fFiOAdGmVnxjgBE_BM7OAmTi9ozivW8Q",
    "FAR":      "1hyXpbjXV5T6J1JSmDimuH9d0VKszBanC",
    "COR":      "1hyXpbjXV5T6J1JSmDimuH9d0VKszBanC",
    "From SBA": "1AzB8SgQq4wj9fwSIFFB5ub3hM070ahNx",
}
OTHER_FED = "1OF3Rb_gqbW2bOcDl0wzlPi-nBUvs9epH"
VA_ID     = "12cnpI5CkTJJIYaxF46duesPmPZJA4FhP"
RESUME_ID = "1iHPZxzgZP-aWEpTCoWWHAP0JYx8JYHsk"

def get_dest(path):
    parts = path.split("/")
    # Find the subfolder after "Government"
    try:
        gov_idx = parts.index("Government")
        subfolder = parts[gov_idx + 1] if gov_idx + 1 < len(parts) else None
    except ValueError:
        return OTHER_FED

    if subfolder in DEST:
        return DEST[subfolder]
    # Root-level files
    fname = os.path.basename(path).lower()
    if "dd-214" in fname or "dd214" in fname or "gi bill" in fname.lower():
        return VA_ID
    if "resume" in fname:
        return RESUME_ID
    return OTHER_FED

def upload_file(filepath, dest_id):
    filename = os.path.basename(filepath)
    tmpfile = os.path.join(TMPDIR, filename)
    try:
        shutil.copy2(filepath, tmpfile)
    except Exception as e:
        return False, f"CP_FAIL: {e}"

    env = os.environ.copy()
    env["GOG_ACCOUNT"] = "dain.bentley@gmail.com"

    try:
        result = subprocess.run(
            ["gog", "drive", "upload", tmpfile, "--parent", dest_id, "--plain"],
            capture_output=True, text=True, env=env, timeout=60,
            stdin=subprocess.DEVNULL
        )
        os.unlink(tmpfile)
        if result.returncode == 0 and result.stdout.strip():
            lines = result.stdout.strip().split("\n")
            file_id = lines[0].split("\t")[1] if "\t" in lines[0] else ""
            return True, file_id
        else:
            return False, result.stderr.strip()[:100]
    except subprocess.TimeoutExpired:
        try: os.unlink(tmpfile)
        except: pass
        return False, "TIMEOUT"
    except Exception as e:
        return False, str(e)

with open(FILELIST) as f:
    files = [l.strip() for l in f if l.strip()]

success = 0
failed = 0

with open(LOG, "w") as log:
    log.write(f"Started: {__import__('datetime').datetime.now()}\n")
    log.write(f"Total: {len(files)}\n\n")
    log.flush()

    for i, filepath in enumerate(files, 1):
        dest = get_dest(filepath)
        filename = os.path.basename(filepath)
        ok, info = upload_file(filepath, dest)
        if ok:
            success += 1
            line = f"✓ [{i}/{len(files)}] {filename}"
        else:
            failed += 1
            line = f"✗ [{i}/{len(files)}] {filename} — {info}"
        print(line, flush=True)
        log.write(line + "\n")
        log.flush()

    summary = f"\nDone: success={success} failed={failed} total={len(files)}"
    print(summary)
    log.write(summary + "\n")

print("UPLOAD_COMPLETE")
