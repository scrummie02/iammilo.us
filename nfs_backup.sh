#!/usr/bin/env bash
# /home/dain/.openclaw/workspace/nfs_backup.sh
# Mount remote NFS share and backup local directory.

REMOTE_NFS="192.168.200.226:/data/Backups/HV04/openldap"
MOUNT_POINT="/mnt/Backups/openldap"
LOCAL_SOURCE="/data/backups/HV04/openldap"

# Exit on any error
set -e

# 1. Ensure the mount point exists
if [ ! -d "$MOUNT_POINT" ]; then
    echo "Creating mount point at $MOUNT_POINT..."
    sudo mkdir -p "$MOUNT_POINT"
fi

# 2. Mount the NFS share
echo "Mounting $REMOTE_NFS to $MOUNT_POINT..."
sudo mount -t nfs "$REMOTE_NFS" "$MOUNT_POINT"

# 3. Check if mount was successful
if mountpoint -q "$MOUNT_POINT"; then
    echo "Mount successful."
    
    # 4. Run the backup via rsync
    # -a: archive mode, -v: verbose, --delete: exact mirror
    echo "Backing up $LOCAL_SOURCE to $MOUNT_POINT..."
    sudo rsync -av --delete "$LOCAL_SOURCE/" "$MOUNT_POINT/"
    
    echo "Backup sync complete."

    # 5. Unmount when finished
    echo "Unmounting $MOUNT_POINT..."
    sudo umount "$MOUNT_POINT"
    echo "All done!"
else
    echo "ERROR: Failed to mount $REMOTE_NFS. Backup aborted."
    exit 1
fi
