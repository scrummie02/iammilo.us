#!/bin/bash
# otto_site_backup.sh — Backs up all MILO web containers to NFS
# Runs on OTTO nightly via cron

BACKUP_DIR="/home/dain/Documents/Archive/site-backups"
DATE=$(date +%Y-%m-%d)
NFS_BACKUP="/mnt/backups/site-backups"

mkdir -p "$BACKUP_DIR/$DATE"

echo "[$(date)] Starting site backup..."

# Pull HTML from each site container
declare -A SITES=(
    ["milo_blog"]="http://192.168.200.223:8091"
    ["milo_news"]="http://192.168.200.223:8092"
    ["milo_docs"]="http://192.168.200.223:8090"
)

for NAME in "${!SITES[@]}"; do
    URL="${SITES[$NAME]}"
    SITE_DIR="$BACKUP_DIR/$DATE/$NAME"
    mkdir -p "$SITE_DIR"
    
    # Download index
    curl -s -o "$SITE_DIR/index.html" "$URL/" && echo "[OK] $NAME/index.html"
    
    # Download known subpages
    PAGES=("about.html" "overview.html" "infrastructure.html" "agents.html" "workflows.html" "n8n.html")
    for PAGE in "${PAGES[@]}"; do
        STATUS=$(curl -s -o "$SITE_DIR/$PAGE" -w "%{http_code}" "$URL/$PAGE")
        if [ "$STATUS" = "200" ]; then
            echo "[OK] $NAME/$PAGE"
        fi
    done
    
    # Download post listings from blog
    if [ "$NAME" = "milo_blog" ]; then
        POSTS=$(curl -s "$URL/" | grep -o 'href="/posts/[^"]*"' | sed 's/href="//;s/"//')
        for POST in $POSTS; do
            POSTNAME=$(basename "$POST")
            mkdir -p "$SITE_DIR/posts"
            curl -s -o "$SITE_DIR/posts/$POSTNAME" "$URL$POST"
            echo "[OK] $NAME/posts/$POSTNAME"
        done
    fi
done

# Compress the backup
cd "$BACKUP_DIR" && tar czf "$DATE.tar.gz" "$DATE/" && rm -rf "$DATE/"
echo "[$(date)] Compressed backup: $BACKUP_DIR/$DATE.tar.gz"

# Copy to NFS if available
if mountpoint -q /mnt/backups 2>/dev/null; then
    mkdir -p "$NFS_BACKUP"
    cp "$BACKUP_DIR/$DATE.tar.gz" "$NFS_BACKUP/"
    # Keep only last 30 days on NFS
    find "$NFS_BACKUP" -name "*.tar.gz" -mtime +30 -delete
    echo "[$(date)] Copied to NFS: $NFS_BACKUP/$DATE.tar.gz"
else
    echo "[$(date)] NFS not mounted, local backup only."
fi

# Keep only last 14 days locally
find "$BACKUP_DIR" -name "*.tar.gz" -mtime +14 -delete

echo "[$(date)] Site backup complete."
