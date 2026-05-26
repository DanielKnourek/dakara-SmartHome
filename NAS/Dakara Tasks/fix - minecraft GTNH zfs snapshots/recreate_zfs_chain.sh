#!/bin/bash
# Exit immediately if a command fails.
set -e

# --- Configuration ---
SNAPSHOT_FILE="/tmp/snapshot_list.txt"
STAGING_DATASET="HomeArchive/backup/games-legacy/minecraft-gtnh"

# --- Script Logic ---
echo "--- Starting Snapshot History Rebuilding Process ---"

# --- Setup Staging Area ---
# To ensure a clean history, we destroy and recreate the staging dataset.
# ⚠️ WARNING: This will destroy any existing data in the STAGING_DATASET.
if zfs list -H -o name "$STAGING_DATASET" &>/dev/null; then
    echo "Wiping existing staging dataset to ensure a clean history..."
    sudo zfs destroy -r "$STAGING_DATASET"
fi
echo "Creating new, clean staging dataset: $STAGING_DATASET"
sudo zfs create "$STAGING_DATASET"

STAGING_MOUNTPOINT=$(zfs get -H -o value mountpoint "$STAGING_DATASET")
echo "Staging area is ready at: $STAGING_MOUNTPOINT"
echo "---"

# --- Main Loop ---
while read -r SNAPSHOT_FULL_NAME; do
    
    # Skip any empty lines in the input file.
    if [ -z "$SNAPSHOT_FULL_NAME" ]; then
        continue
    fi
    
    # --- CONFIRMATION STEP (Corrected) ---
    # This 'read' command now explicitly takes input from the keyboard (/dev/tty).
    read -p "Process this snapshot? (Y/n): $SNAPSHOT_FULL_NAME " confirm < /dev/tty
    
    if [[ "${confirm,,}" == "n" ]]; then
        echo "Skipping."
        echo "---"
        continue
    fi
    
    # --- PROCESSING LOGIC (only runs if user confirmed) ---
    OLD_DATASET=$(echo "$SNAPSHOT_FULL_NAME" | cut -d'@' -f1)
    OLD_MOUNTPOINT=$(zfs get -H -o value mountpoint "$OLD_DATASET")
    SNAPSHOT_SHORT_NAME=$(echo "$SNAPSHOT_FULL_NAME" | cut -d'@' -f2)
    
    echo "-> Replicating state of snapshot: $SNAPSHOT_SHORT_NAME"
    
    SOURCE_DIR="$OLD_MOUNTPOINT/.zfs/snapshot/$SNAPSHOT_SHORT_NAME/"
    echo " └-> From source directory: $SOURCE_DIR"
    
    if [ -d "$SOURCE_DIR" ]; then
        sudo rsync -avh --delete --exclude='backups/' "$SOURCE_DIR" "$STAGING_MOUNTPOINT/"
        sudo zfs snapshot "${STAGING_DATASET}@${SNAPSHOT_SHORT_NAME}"
        echo "   ...New snapshot created."
    else
        echo "   ...Source directory not found in snapshot '$SNAPSHOT_SHORT_NAME'. Skipping."
    fi
    echo "---"

done < "$SNAPSHOT_FILE"

echo "History rebuilding complete."