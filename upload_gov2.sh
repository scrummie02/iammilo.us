#!/bin/bash
export GOG_KEYRING_PASSWORD=""

LOG="/home/dain/.openclaw/workspace/upload_government.log"
TMPDIR="/home/dain/.openclaw/workspace/.upload_tmp"
mkdir -p "$TMPDIR"
> "$LOG"

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

get_dest() {
  local path="$1"
  case "$path" in
    */Government/DoJ/*) echo "$DOJ" ;;
    */Government/eOPF/*) echo "$OPM" ;;
    */Government/VA/*) echo "$VA_ID" ;;
    */Government/Virginia/*) echo "$STATE_VA" ;;
    */Government/CO/*) echo "$STATE_CO" ;;
    */Government/IRS/*) echo "$IRS_ID" ;;
    */Government/SBA/*) echo "$SBA_ID" ;;
    */Government/LES/*) echo "$LES_ID" ;;
    */Government/Resumes/*) echo "$RESUME_ID" ;;
    */Government/FAFSA/*) echo "$STUDENT_LOAN" ;;
    */Government/FAR/*) echo "$FROM_WORK" ;;
    */Government/COR/*) echo "$FROM_WORK" ;;
    */Government/"From SBA"/*) echo "$DUPLICATES" ;;
    */Government/DD-214*|*/Government/Dain*DD*) echo "$VA_ID" ;;
    */Government/*GI*Bill*) echo "$VA_ID" ;;
    */Government/*Resume*) echo "$RESUME_ID" ;;
    */Government/sf15*|*/Government/SF52*) echo "$OTHER_FED" ;;
    *) echo "$OTHER_FED" ;;
  esac
}

echo "Started: $(date)" | tee -a "$LOG"
echo "Total files: $(wc -l < /home/dain/.openclaw/workspace/gov_filelist.txt)" | tee -a "$LOG"

count=0
success=0
failed=0

while IFS= read -r -u3 filepath; do
  filename=$(basename "$filepath")
  dest=$(get_dest "$filepath")
  tmpfile="$TMPDIR/$filename"

  # Copy from mount to local
  cp "$filepath" "$tmpfile" 2>/dev/null
  if [ ! -f "$tmpfile" ]; then
    echo "✗ CP_FAIL: $filename" | tee -a "$LOG"
    ((failed++))
    continue
  fi

  # Upload
  result=$(GOG_KEYRING_PASSWORD="" GOG_ACCOUNT=dain.bentley@gmail.com gog drive upload "$tmpfile" --parent "$dest" --plain < /dev/null 2>/dev/null | awk 'NR==1{print $2}')
  rm -f "$tmpfile"

  count=$((count + 1))
  if [ -n "$result" ]; then
    echo "✓ [$count] $filename → $(basename $dest 2>/dev/null || echo $dest)" | tee -a "$LOG"
    success=$((success + 1))
  else
    echo "✗ [$count] FAIL: $filename" | tee -a "$LOG"
    failed=$((failed + 1))
  fi

done 3< /home/dain/.openclaw/workspace/gov_filelist.txt

rmdir "$TMPDIR" 2>/dev/null
echo "" | tee -a "$LOG"
echo "=== DONE: $(date) ===" | tee -a "$LOG"
echo "Success: $success | Failed: $failed | Total: $count" | tee -a "$LOG"
echo "UPLOAD_COMPLETE"
