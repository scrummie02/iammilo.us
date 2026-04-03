#!/usr/bin/env python3
"""
Copy files from Google Drive Documents/ folder into DOCS/ JD structure.
Uses `gog drive copy` and `gog drive ls` — all within Drive, no downloads.
"""
import subprocess, sys, os

GOG = ["gog", "drive"]
ENV = {**os.environ, "GOG_ACCOUNT": "dain.bentley@gmail.com"}
LOG = "/home/dain/.openclaw/workspace/copy_gdrive_docs.log"

# ── JD destination IDs ──────────────────────────────────────────────────────
DEST = {
    # 10-19 Personal & Identity
    "11_identity":      "13pK7gszpaJLKlrKFPMOeugg_aNxC_Mp2",   # 11 Identity & Legal
    "11_notary":        "13pK7gszpaJLKlrKFPMOeugg_aNxC_Mp2",   # → 11 Identity & Legal
    "11_gov":           "1rB2cx2OII1kyxGbImvgYJvKoJTpbvx0d",   # 11.05 Government & VA Forms
    # 20-29 Family & Legal
    "21_charlotte":     "1ffgcsNpNeRyHmtgRBCVes7sXfkV1CfFF",   # 21 Charlotte
    "22_divorce":       "1OVDXLD9rFcmWEczHnq4tcT2RXq41GwZO",   # 22 Divorce & Court
    # 30-39 Finance
    "31_banking":       "1js5FiLhgLYdQ4RUsAXcdfd7WmUm2iLhg",   # 31.01 Banking
    "33_taxes":         "122OJHuWlw1TQ_NpSy8heTeKmUqVlwEYG",   # 33 Taxes
    # 40-49 Work & Career
    "42_from_work":     "1hyXpbjXV5T6J1JSmDimuH9d0VKszBanC",   # 42.01 From Work
    # 60-69 Travel & Lifestyle
    "61_travel":        "13tBPjd1oEti-XVrATAYgrSULWMS2hMp9",   # 61 Travel
    "61_vacations":     "1g9eOvwemHEU8Tio99t2IcJljs3sZFyyC",   # 61.02 Vacations
    # 70-79 Archive & Misc
    "73_archive":       "11qAD20zrrobKyGkQQ2jIkzZ5HlFGJ71c",   # 73 Archive
    "74_duplicates":    "1AzB8SgQq4wj9fwSIFFB5ub3hM070ahNx",   # 74 Duplicates
    # Gov subfolders
    "gov_va":           "12cnpI5CkTJJIYaxF46duesPmPZJA4FhP",
    "gov_state_va":     "1W-Pxi1gRVZ8zImBoBdawE89BrHJP4cHX",
    "gov_opm":          "1xE9lAVWBabcPNmbGI5gPS-VocXVUgnpm",
    "gov_irs":          "1wRYULVRq-XtxtpIbMvhA7AAptoJIUs99",
    "gov_doj":          "1gohhFmGKEaw0a6BZJw4m4S8aCBafXw4Y",
    "gov_resume":       "1iHPZxzgZP-aWEpTCoWWHAP0JYx8JYHsk",
    "gov_les":          "18hcsHs8zgB3SHfTlk2t3rrhre-wFeUQV",
    "gov_other":        "1OF3Rb_gqbW2bOcDl0wzlPi-nBUvs9epH",
    "gov_student_loan": "1fFiOAdGmVnxjgBE_BM7OAmTi9ozivW8Q",
}

# ── Folder-to-destination mapping ───────────────────────────────────────────
# (source folder ID from Documents/) → dest key
FOLDER_MAP = {
    "11jCga6c5BTAdhkq14bBbragBoMd4n8fp": "11_notary",       # Notary
    "1y9OQWSOV7taAF-updC6tg17eouFpwcsk": "61_travel",       # Travel
    "1oJNBO1FU5imaZKvzxOr0vpqQK0LLRzmJ": "31_banking",      # Banking
    "1ab5PRrq6yOb6PJwRhUle_TUR5286LwIP": "21_charlotte",     # Charlotte
    "1IwxOnDjyRjeygv0RClKZhO-VCH3v9wbP": "74_duplicates",   # test
    "1hWEq8bYcwNUbovJmsq-Fb9i-41-MkMXp": "73_archive",      # Archive
    "1gBQgfqaE_2aI3HdkU6Ml2WDbgthINpTa": "33_taxes",        # Taxes
    "1-D1eDnnExUlTY7mw0SAA6GsXB42f-WTL": "22_divorce",      # Divorce
    "1F21VSKl-tpQ-3YB24mdhK-z9f5J_Yza7": "42_from_work",    # From Work
    "1bYmkYFi7Yy9BcQUN69TIr8mLrSakwP5B": "74_duplicates",   # ICloud
    "1Tq1PmtTnRN8blr0K5bHwkdtrfLiwP29Q": "gov_va",          # VA
    "1s2o155v6th5iFCI-_MVyhSl0tMPBmaQO": "gov_state_va",    # Virginia State forms
    "1YUYuWoBXggzY7lanu7wgOKXrHDb7LQat": "73_archive",      # Workout Info
    "1s40mD9KbQ2EoKL_OER-bxNKbX4eBooPj": "74_duplicates",   # iPhone Backup
    "1X_8fmEcJToyCmDA6iC3Lbiq4KpMhe8uv": "61_vacations",    # Vacations
    # Government subfolders mapped individually below
}

# Government subfolder IDs → dest keys
GOV_SUBFOLDER_MAP = {
    # Will be resolved dynamically
}

# Root-level loose files in Documents/
ROOT_FILE_MAP = {
    "1W91yt1E9PI3g6meGUkMe1neeeWmZEla9": "73_archive",   # Readme.md
    "1cm35D9ujh6uo9Jj5OmW0PbobQxB1rLZm": "73_archive",  # Welcome to Nextcloud Hub.docx
    "1R-4ptO5uTPTQracYGHMBApwJYlnDdzVW": "73_archive",  # Example.md
    "1LyV3fEBHv0_WK-Vvojw-8-oStGph3mlH": "73_archive",  # Nextcloud flyer.pdf
}

# Root-level SF50 files in Drive root
DRIVE_ROOT_FILES = {
    "1wDCeVPhPu46VSTnVK8AqLUi1_k9eX9hL": ("SF50-10-1-25 (1).pdf",  "gov_opm"),
    "15VkjTjLGStoWBL4fKHfhZxV0niLe6qxx": ("SF50-09-16-25 (1).pdf", "gov_opm"),
    "1XAiDkdff3YL6eIhKWPpEqLLNfeNHIzG-": ("SF50-09-30-25 (1).pdf", "gov_opm"),
    "1RH1SO8c3OOpw9w-2t8ld9e_N-q_v_I":   ("SF50-10-1-25.pdf",      "gov_opm"),
    "1zT3mH95SL_axcnboF5tBiPYs6SzLt49O": ("SF50-09-16-25.pdf",     "gov_opm"),
    "1Xlf4GUQQXYAkd48HIm4fDdI8yMrUm9JE": ("SF50-09-30-25.pdf",     "gov_opm"),
    "1VSchY701oPrLz8WkO-P-vqdNMp7ziOot":  ("C. Bentley AIP 2025-2026.docx.pdf", "21_charlotte"),
}

def gog_ls(parent_id):
    """Return list of (id, name, type) for items in a folder."""
    r = subprocess.run(
        GOG + ["ls", "--parent", parent_id, "--plain"],
        capture_output=True, text=True, env=ENV, stdin=subprocess.DEVNULL, timeout=30
    )
    items = []
    for line in r.stdout.strip().split("\n")[1:]:
        parts = line.split("\t")
        if len(parts) >= 3:
            items.append((parts[0], parts[1], parts[2]))
    return items

def gog_copy(file_id, name, dest_id):
    """Copy a file within Drive to dest_id."""
    r = subprocess.run(
        GOG + ["copy", file_id, name, "--parent", dest_id, "--plain"],
        capture_output=True, text=True, env=ENV, stdin=subprocess.DEVNULL, timeout=60
    )
    if r.returncode == 0 and r.stdout.strip():
        parts = r.stdout.strip().split("\n")[0].split("\t")
        return parts[0] if parts else ""
    return ""

def copy_folder_contents(src_folder_id, dest_key, label, log):
    """Copy all files from src_folder_id to DEST[dest_key]. Recurse into subfolders."""
    dest_id = DEST[dest_key]
    try:
        items = gog_ls(src_folder_id)
    except Exception as e:
        msg = f"  ✗ LS_FAIL {label}: {e}"
        print(msg); log.write(msg + "\n"); log.flush()
        return 0, 0

    success = failed = 0
    for fid, fname, ftype in items:
        if ftype == "folder":
            # Recurse — keep same dest (flatten into parent JD folder)
            s, f = copy_folder_contents(fid, dest_key, f"{label}/{fname}", log)
            success += s; failed += f
        else:
            new_id = gog_copy(fid, fname, dest_id)
            if new_id:
                msg = f"  ✓ {fname}  →  {dest_key}"
                success += 1
            else:
                msg = f"  ✗ FAIL: {fname}"
                failed += 1
            print(msg); log.write(msg + "\n"); log.flush()
    return success, failed

# ── Main ─────────────────────────────────────────────────────────────────────
total_s = total_f = 0

with open(LOG, "w") as log:
    import datetime
    log.write(f"Started: {datetime.datetime.now()}\n\n")
    log.flush()

    # 1. Copy root-level files from Documents/
    print("=== Root files in Documents/ ===")
    log.write("=== Root files in Documents/ ===\n"); log.flush()
    for fid, dest_key in ROOT_FILE_MAP.items():
        # Get filename
        items = [i for i in gog_ls("1FKnp_htU4F1elhkKyvEjPdT3sxWuBEfg") if i[0] == fid]
        fname = items[0][1] if items else fid
        new_id = gog_copy(fid, fname, DEST[dest_key])
        if new_id:
            msg = f"  ✓ {fname}  →  {dest_key}"; total_s += 1
        else:
            msg = f"  ✗ FAIL: {fname}"; total_f += 1
        print(msg); log.write(msg + "\n"); log.flush()

    # 2. Copy each subfolder from Documents/
    print("\n=== Subfolders ===")
    log.write("\n=== Subfolders ===\n"); log.flush()
    for src_id, dest_key in FOLDER_MAP.items():
        # Get folder name for logging
        print(f"\n--- {src_id} → {dest_key} ---")
        log.write(f"\n--- {src_id} → {dest_key} ---\n"); log.flush()
        s, f = copy_folder_contents(src_id, dest_key, src_id, log)
        total_s += s; total_f += f

    # 3. Handle Government/ subfolders individually
    print("\n=== Government subfolders ===")
    log.write("\n=== Government subfolders ===\n"); log.flush()
    GOV_ID = "1N7HlQazkEHDpduLnRsHFyLmxXCuyXG1U"
    gov_sub_map = {
        "eOPF":    "gov_opm",
        "LES":     "gov_les",
        "Resumes": "gov_resume",
        "DoJ":     "gov_doj",
        "IRS":     "gov_irs",
        "VA":      "gov_va",
        "FAR":     "42_from_work",
        "Virginia":"gov_state_va",
        "FAFSA":   "gov_student_loan",
    }
    gov_items = gog_ls(GOV_ID)
    for fid, fname, ftype in gov_items:
        if ftype == "folder" and fname in gov_sub_map:
            dest_key = gov_sub_map[fname]
            print(f"\n--- Gov/{fname} → {dest_key} ---")
            log.write(f"\n--- Gov/{fname} → {dest_key} ---\n"); log.flush()
            s, f = copy_folder_contents(fid, dest_key, fname, log)
            total_s += s; total_f += f

    # 4. Copy Drive root-level SF50s and Charlotte AIP
    print("\n=== Drive root loose files ===")
    log.write("\n=== Drive root loose files ===\n"); log.flush()
    for fid, (fname, dest_key) in DRIVE_ROOT_FILES.items():
        new_id = gog_copy(fid, fname, DEST[dest_key])
        if new_id:
            msg = f"  ✓ {fname}  →  {dest_key}"; total_s += 1
        else:
            msg = f"  ✗ FAIL: {fname}"; total_f += 1
        print(msg); log.write(msg + "\n"); log.flush()

    summary = f"\n=== DONE: {datetime.datetime.now()} ===\nSuccess: {total_s}  Failed: {total_f}\n"
    print(summary); log.write(summary)

print("COPY_COMPLETE")
