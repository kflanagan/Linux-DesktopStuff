#!/bin/bash

# Bash Script for Incremental Backups using rsync to a Remote System

# --- Configuration ---
# Define the source directory on the 'from' device (local path).
# Example: SOURCE_DIR="/home/youruser/Documents"
SOURCE_DIR="/home/kevin" # Path to the directory you want to back up


#set the current host to a variable
CURRENT_HOST=$(hostname -s)

# Define the base destination directory on the 'to' device (remote system).
# Format: [user@]host:/path/to/base/directory
# rsync uses SSH for remote connections, so ensure SSH keys or password authentication is set up.
# Example: DESTINATION_BASE_DIR="youruser@remotehost:/mnt/backup_drive/my_backups"
# Example: DESTINATION_BASE_DIR="backupuser@192.168.1.100:/data/backups"
DESTINATION_BASE_DIR="kevin@ubuntu-vm:/backups/$CURRENT_HOST" # Path to your remote backup directory



# Create a directory for the backup if it does not exist, based on the timestamp.
# homedir files for the user running the script go in it, then move to the remote host.

#now=$(date +"%d-%m-%Y")
#mkdir ~/$now
#STAGING_DIR=~/$now

# Define a file for exclusions (optional).
# This file should contain one pattern per line for files/directories to exclude.
# Example: If you have a file named 'exclude.txt' in the same directory as the script:
# exclude.txt content example:
#   *.tmp
#   cache/
#   node_modules/
#   .Trash/
# Set to an empty string if you don't want to use an exclusion file: EXCLUSION_FILE=""
EXCLUSION_FILE="./exclude.txt" # Path to your exclusion file (optional)

# Log file for script output.
#if the directory backups does not exist, create it
mkdir -p /var/log/backups
LOG_FILE="/var/log/backups/backup_$(date +%Y%m%d%H%M%S).log"

# --- Script Logic ---

# Generate a timestamp for the backup directory
TIMESTAMP=$(date +%Y%m%d_%H%M)
FINAL_DESTINATION="$DESTINATION_BASE_DIR/$TIMESTAMP"

echo "Starting backup process from '$SOURCE_DIR' to '$FINAL_DESTINATION'..." | tee -a "$LOG_FILE"
echo "Log file: $LOG_FILE" | tee -a "$LOG_FILE"
echo "----------------------------------------------------" | tee -a "$LOG_FILE"

# Check if local source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
    echo "ERROR: Source directory '$SOURCE_DIR' does not exist." | tee -a "$LOG_FILE"
    exit 1
fi

# Construct rsync options
# -a: archive mode (recursively copy files, preserve symlinks, permissions, ownership, timestamps)
# -v: verbose output
# -h: human-readable numbers
# --progress: show progress during transfer
# --exclude-from: specify a file with patterns of files to exclude
# --log-file: write rsync output to a specified log file (local log for local operations)
# --info=progress2: (newer rsync versions) provides overall progress bar
# -e ssh: tells rsync to use ssh for the remote connection
RSYNC_OPTIONS="-avh --progress --info=progress2 -e ssh"

# Add exclusion file option if EXCLUSION_FILE is specified
if [ -n "$EXCLUSION_FILE" ] && [ -f "$EXCLUSION_FILE" ]; then
    RSYNC_OPTIONS+=" --exclude-from=$EXCLUSION_FILE"
    echo "Using exclusion file: $EXCLUSION_FILE" | tee -a "$LOG_FILE"
elif [ -n "$EXCLUSION_FILE" ] && [ ! -f "$EXCLUSION_FILE" ]; then
    echo "WARNING: Exclusion file '$EXCLUSION_FILE' specified but not found. Skipping exclusions." | tee -a "$LOG_FILE"
fi

# Perform the backup
echo "Executing rsync command..." | tee -a "$LOG_FILE"
echo "rsync $RSYNC_OPTIONS \"$SOURCE_DIR/\" \"$FINAL_DESTINATION\"" | tee -a "$LOG_FILE"

# The trailing slash on SOURCE_DIR ("$SOURCE_DIR/") means "copy the *contents* of this directory"
# Without it ("$SOURCE_DIR"), it would copy the directory itself into the timestamped destination.
# rsync will automatically create the $FINAL_DESTINATION directory on the remote if it doesn't exist.
rsync $RSYNC_OPTIONS "$SOURCE_DIR/" "$FINAL_DESTINATION" 2>&1 | tee -a "$LOG_FILE"

# compress the backup directory on the remote server
echo "Compressing the backup directory on the remote server..." | tee -a "$LOG_FILE"
ssh -o BatchMode=yes -o ConnectTimeout=5 "ubuntu-vm" "tar -czf /backups/$TIMESTAMP.tgz /backups/$CURRENT_HOST/$TIMESTAMP && rm -rf /backups/$TIMESTAMP" 2>&1 | tee -a "$LOG_FILE"    

# Check if the compression was successful
if [ $? -ne 0 ]; then
    echo "ERROR: Compression of the backup directory failed!" | tee -a "$LOG_FILE"
    exit 1
fi  

# Now copy the compressed backup to a google drive or other cloud storage if needed
# Uncomment the following line if you want to upload to Google Drive or another cloud service
# echo "Uploading the compressed backup to Google Drive..." | tee -a "$LOG_FILE"
# gdrive upload --parent <folder_id> "$FINAL_DESTINATION.tar.gz" 2>&1 | tee -a "$LOG_FILE"  
# Clean up the local log file to avoid excessive size
find /var/log/ -name "backup_*.log" -type f -mtime +7 -exec rm -f {} \; 2>&1 | tee -a "$LOG_FILE"   



# Check the exit status of rsync
if [ $? -eq 0 ]; then
    echo "----------------------------------------------------" | tee -a "$LOG_FILE"
    echo "Backup completed successfully to '$FINAL_DESTINATION'!" | tee -a "$LOG_FILE"
else
    echo "----------------------------------------------------" | tee -a "$LOG_FILE"
    echo "Backup completed with errors. Please check the log file: $LOG_FILE" | tee -a "$LOG_FILE"
    exit 1
fi

echo "Backup process finished." | tee -a "$LOG_FILE"
echo "see $LOG_FILE for details."
# End of script
