#!/usr/bin/env bash
# Backup milo_blog container content to NFS
# Runs daily — tar the nginx html dir inside the container, pull via Portainer API

set -euo pipefail

BACKUP_DIR="/mnt/backups/cachyos/milo-blog"
DATE=$(date +%Y-%m-%d)
OUTFILE="$BACKUP_DIR/milo_blog_${DATE}.tar.gz"
PORTAINER_URL="${PORTAINER_URL:-http://192.168.200.220:9000}"
PORTAINER_API_KEY="${PORTAINER_API_KEY}"
CONTAINER_ID="88cd933f3579"
ENDPOINT_ID="7"

mkdir -p "$BACKUP_DIR"

# Step 1: Create tar inside container
EXEC_PAYLOAD='{"AttachStdout":true,"AttachStderr":true,"Cmd":["sh","-c","tar czf /tmp/milo_blog_backup.tar.gz -C /usr/share/nginx/html . && echo TAR_OK"]}'
EXEC_ID=$(curl -sf -X POST -H "X-API-Key: $PORTAINER_API_KEY" \
  -H "Content-Type: application/json" \
  -d "$EXEC_PAYLOAD" \
  "$PORTAINER_URL/api/endpoints/$ENDPOINT_ID/docker/containers/$CONTAINER_ID/exec" \
  | python3 -c "import sys,json; print(json.load(sys.stdin)['Id'])")

curl -sf -X POST -H "X-API-Key: $PORTAINER_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"Detach":false,"Tty":false}' \
  "$PORTAINER_URL/api/endpoints/$ENDPOINT_ID/docker/exec/$EXEC_ID/start" > /dev/null

# Step 2: Pull tar via Portainer archive API
curl -sf -o "$OUTFILE" \
  -H "X-API-Key: $PORTAINER_API_KEY" \
  "$PORTAINER_URL/api/endpoints/$ENDPOINT_ID/docker/containers/$CONTAINER_ID/archive?path=/tmp/milo_blog_backup.tar.gz"

echo "Backup saved: $OUTFILE ($(du -sh "$OUTFILE" | cut -f1))"

# Step 3: Prune backups older than 30 days
find "$BACKUP_DIR" -name "milo_blog_*.tar.gz" -mtime +30 -delete
echo "Cleanup done. Current backups:"
ls -lh "$BACKUP_DIR"
