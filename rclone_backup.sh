#!/usr/bin/env bash
# /home/dain/.openclaw/workspace/rclone_backup.sh
# Quick script to mount a remote via rclone and run a backup.

# IMPORTANT: You must configure the remote in rclone first!
# Run `rclone config` and create a remote named "hv04" (SFTP/SSH) pointing to 192.168.200.226.
REMOTE="hv04:/data/Backups/HV04/openldap"
MOUNT_POINT="/mnt/Backups/openldap"

# 1. Ensure the mount point exists
if [ ! -d "$MOUNT_POINT" ]; then
    echo "Creating mount point at $MOUNT_POINT..."
    sudo mkdir -p "$MOUNT_POINT"
fi

# 2. Mount the remote in the background
echo "Mounting $REMOTE to $MOUNT_POINT..."
# --daemon runs it in the background
# --vfs-cache-mode writes is recommended for reliable writing
rclone mount "$REMOTE" "$MOUNT_POINT" \
    --vfs-cache-mode writes \
    --daemon

# Give it a second to establish the mount
sleep 3

# Check if mount was successful
if mountpoint -q "$MOUNT_POINT"; then
    echo "Mount successful."
    
    # ---------------------------------------------------------
    # 3. RUN YOUR BACKUP LOGIC HERE
    # Example: backing up local LDAP data to the mounted folder
    # rsync -av --delete /var/lib/ldap/ "$MOUNT_POINT/"
    # ---------------------------------------------------------
    echo "Running backup..."
    # TODO: Add your specific backup command here!
    
    echo "Backup complete."

    # 4. Unmount when finished to keep things clean
    echo "Unmounting $MOUNT_POINT..."
    fusermount -u "$MOUNT_POINT"
else
    echo "ERROR: Failed to mount $REMOTE. Backup aborted."
    exit 1
fi
