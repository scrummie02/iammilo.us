#!/usr/bin/env bash
# Backup milo_blog content to NFS
# The blog is a local bind mount — no container/Portainer needed

set -euo pipefail

BACKUP_DIR="/mnt/backups/cachyos/milo-blog"
DATE=$(date +%Y-%m-%d)
OUTFILE="$BACKUP_DIR/milo_blog_${DATE}.tar.gz"
BLOG_DIR="/home/dain/.openclaw/workspace/blog"

mkdir -p "$BACKUP_DIR"

# Ensure NFS is mounted; fall back to local temp if not
if ! mountpoint -q /mnt/backups 2>/dev/null; then
    echo "Warning: NFS not mounted, attempting mount..."
    mount -t nfs 192.168.200.224:/data/Backups /mnt/backups -o nolock 2>/dev/null || true
fi

if ! mountpoint -q /mnt/backups 2>/dev/null; then
    echo "Error: NFS backup mount unavailable. Exiting."
    exit 1
fi

# Create tar from the local bind mount
tar czf "$OUTFILE" -C "$BLOG_DIR" .

echo "Backup saved: $OUTFILE ($(du -sh "$OUTFILE" | cut -f1))"

# Prune backups older than 30 days
find "$BACKUP_DIR" -name "milo_blog_*.tar.gz" -mtime +30 -delete
echo "Cleanup done. Current backups:"
ls -lh "$BACKUP_DIR"
