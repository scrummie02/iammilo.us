#!/bin/bash
# Upload Government docs to Google Drive DOCS structure (COPY only)
# Workaround: copy from WebDAV mount to local temp, upload, delete temp

export GOG_KEYRING_PASSWORD=""
LOG="/home/dain/.openclaw/workspace/upload_government.log"
TMPDIR="/home/dain/.openclaw/workspace/.upload_tmp"
mkdir -p "$TMPDIR"
> "$LOG"

upload_file() {
  local filepath="$1"
  local parent_id="$2"
  local filename=$(basename "$filepath")
  local tmpfile="$TMPDIR/$filename"

  # Copy from WebDAV mount to local temp
  cp "$filepath" "$tmpfile" 2>/dev/null
  if [ ! -f "$tmpfile" ]; then
    echo "✗ COPY_FAILED: $filename" | tee -a "$LOG"
    return
  fi

  # Upload to Google Drive
  local result=$(GOG_ACCOUNT=dain.bentley@gmail.com gog drive upload "$tmpfile" --parent "$parent_id" --plain --no-input < /dev/null 2>/dev/null | awk 'NR==1{print $2}')

  # Clean up temp
  rm -f "$tmpfile"

  if [ -n "$result" ]; then
    echo "✓ $filename" | tee -a "$LOG"
  else
    echo "✗ UPLOAD_FAILED: $filename" | tee -a "$LOG"
  fi
}

upload_folder() {
  local src="$1"
  local parent_id="$2"
  local label="$3"
  echo "" | tee -a "$LOG"
  echo "=== $label ===" | tee -a "$LOG"
  while IFS= read -r f; do
    upload_file "$f" "$parent_id"
  done < <(find "$src" -maxdepth 1 -type f | sort)
}

# Destination IDs
DOJ="1gohhFmGKEaw0a6BZJw4m4S8aCBafXw4Y"
OPM="1xE9lAVWBabcPNmbGI5gPS-VocXVUgnpm"
SBA_ID="1J-tXR61RGJocjET1oM458n08gTO7dtMy"
VA_ID="12cnpI5CkTJJIYaxF46duesPmPZJA4FhP"
IRS_ID="1wRYULVRq-XtxtpIbMvhA7AAptoJIUs99"
OTHER_FED="1OF3Rb_gqbW2bOcDl0wzlPi-nBUvs9epH"
STATE_VA="1W-Pxi1gRVZ8zImBoBdawE89BrHJP4cHX"
STATE_CO="1Y6g2Ku8qidhwtGWDv6r0vHYuzQhqSU4Q"
LES_ID="18hcsHs8zgB3SHfTlk2t3rrhre-wFeUQV"
RESUME_ID="1iHPZxzgZP-aWEpTCoWWHAP0JYx8JYHsk"
STUDENT_LOAN="1fFiOAdGmVnxjgBE_BM7OAmTi9ozivW8Q"
FROM_WORK="1hyXpbjXV5T6J1JSmDimuH9d0VKszBanC"
DUPLICATES="1AzB8SgQq4wj9fwSIFFB5ub3hM070ahNx"

GOV="/home/dain/Nextcloud/data/Documents/Government"

echo "Started: $(date)" | tee -a "$LOG"

upload_folder "$GOV/DoJ"       "$DOJ"          "DoJ → DOJ - Dept of Justice"
upload_folder "$GOV/eOPF"      "$OPM"          "eOPF → OPM"
upload_folder "$GOV/VA"        "$VA_ID"        "VA → Veterans Affairs"
upload_folder "$GOV/Virginia"  "$STATE_VA"     "Virginia → State - Virginia"
upload_folder "$GOV/CO"        "$STATE_CO"     "CO → State - Colorado"
upload_folder "$GOV/IRS"       "$IRS_ID"       "IRS"
upload_folder "$GOV/SBA"       "$SBA_ID"       "SBA"
upload_folder "$GOV/LES"       "$LES_ID"       "LES → Pay Stubs (large batch)"
upload_folder "$GOV/Resumes"   "$RESUME_ID"    "Resumes → Resume Versions"
upload_folder "$GOV/FAFSA"     "$STUDENT_LOAN" "FAFSA → Student Loan"
upload_folder "$GOV/FAR"       "$FROM_WORK"    "FAR → From Work"
upload_folder "$GOV/COR"       "$FROM_WORK"    "COR → From Work"
upload_folder "$GOV/From SBA"  "$DUPLICATES"   "From SBA → Duplicates"

echo "" | tee -a "$LOG"
echo "=== Root-level files ===" | tee -a "$LOG"
upload_file "$GOV/Dain Bentley DD-214.pdf" "$VA_ID"
upload_file "$GOV/Dains Post 9-11 GI Bill Eligibility.pdf" "$VA_ID"
upload_file "$GOV/Dain Bentley IT Spec Data Management 604674200 Federal Resume_convertedToPDF.pdf" "$RESUME_ID"
upload_file "$GOV/Dain Bentley IT Spec Data Management 604674200 Federal Resume.docx" "$RESUME_ID"
upload_file "$GOV/sf15.pdf" "$OTHER_FED"
upload_file "$GOV/SF52.pdf" "$OTHER_FED"

rmdir "$TMPDIR" 2>/dev/null
echo "" | tee -a "$LOG"
echo "Completed: $(date)" | tee -a "$LOG"
echo "UPLOAD_COMPLETE"
