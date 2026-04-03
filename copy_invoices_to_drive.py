#!/usr/bin/env python3
"""Download PDF attachments from Google Workspace billing emails and upload to Drive."""
import subprocess, json, os, tempfile

ACCOUNT = "info@dainbentley.com"
EXPENSES_FOLDER = "1QqzqvlokH6i21TIPnZQNMnMzXnl22vF3"

# All billing email IDs
MESSAGE_IDS = [
    "19cad14fab4e9810", "19c1bc647230bad3", "19b7a626da4750cd",
    "19ade35762f2442c", "19a425244c132e96", "199a00fa7ed08814",
    "199082f5251ae190", "1986561527e6c371", "197cd43c6464e697",
    "1972cf8b39efe992", "1968cdc453e3f779", "195f5c12aa599f13",
    "1955422afc93f461", "194c2508b2bffc51", "1942288ec7257837",
]

def run(cmd):
    r = subprocess.run(cmd, capture_output=True, text=True)
    return r.stdout, r.stderr

def get_pdf_attachment(msg_id):
    out, _ = run(["gog", "gmail", "get", msg_id, "--json",
                  f"--account={ACCOUNT}"])
    try:
        d = json.loads(out)
        msg = d.get("message", {})
        payload = msg.get("payload", {})

        def find_pdf(parts):
            for p in parts:
                if p.get("mimeType") == "application/pdf" and p.get("filename"):
                    return p["filename"], p["body"]["attachmentId"]
                if p.get("parts"):
                    result = find_pdf(p["parts"])
                    if result:
                        return result
            return None

        return find_pdf(payload.get("parts", []))
    except:
        return None

ok = 0
skip = 0

with tempfile.TemporaryDirectory() as tmpdir:
    for msg_id in MESSAGE_IDS:
        result = get_pdf_attachment(msg_id)
        if not result:
            print(f"  SKIP {msg_id} — no PDF attachment")
            skip += 1
            continue

        filename, attach_id = result
        outpath = os.path.join(tmpdir, filename)

        print(f"  Downloading {filename} from {msg_id}...")
        out, err = run(["gog", "gmail", "attachment", msg_id, attach_id,
                        f"--out={outpath}", f"--account={ACCOUNT}"])
        if not os.path.exists(outpath):
            print(f"  ERROR: {err[:100]}")
            continue

        print(f"  Uploading {filename} to notary/expenses...")
        out, err = run(["gog", "drive", "upload", outpath,
                        f"--parent={EXPENSES_FOLDER}",
                        f"--account={ACCOUNT}"])
        if "id" in out or "name" in out:
            print(f"  ✓ {filename}")
            ok += 1
        else:
            print(f"  ERROR uploading: {err[:100]}")

print(f"\nDone: {ok} uploaded, {skip} skipped (no attachment)")
