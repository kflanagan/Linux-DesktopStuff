#!/bin/bash

# This script is used to backup the Proxmox VE configuration files to a specified directory
# It will create a tarball of the configuration files and save it to the specified directory
# Usage: ./pve-config-backup.sh /path/to/backup/directory   




BACKUP_DIR="/tmp/pve-config-backups"
# Create the directory if it doesn't exist
mkdir -p "$BACKUP_DIR"
echo "Backup directory: $BACKUP_DIR"

# Check if sshpass is installed, if not install it
if ! command -v sshpass &> /dev/null
then
    echo "sshpass could not be found, installing it..."
    apt-get update && apt-get install -y sshpass
fi

# Create a tarball of the Proxmox VE configuration files
TIMESTAMP=$(date +"%Y-%m-%d-%H-%M-%S")
BACKUP_FILE="$BACKUP_DIR/pve-config-backup-$TIMESTAMP.tar"
tar -cvf "$BACKUP_FILE" /etc/pve   
echo "Proxmox VE configuration files backed up to $BACKUP_FILE" 

# Optionally, you can also backup the /etc/network/interfaces file if you have custom network configurations
tar -rzvf "$BACKUP_FILE" /etc/network/interfaces
echo "Network interfaces configuration added to $BACKUP_FILE"  

# Also backup the /etc/hosts file in case there are custom host entries
tar -rzvf "$BACKUP_FILE" /etc/hosts
echo "Hosts file added to $BACKUP_FILE" 

# Adding more configuration files to backup /etc/resolv.conf, /etc/fstab, etc.  
tar -rvf "$BACKUP_FILE" /etc/fstab
tar -rvf "$BACKUP_FILE" /etc/resolv.conf

# Compress the backup
gzip $BACKUP_FILE 
# Move the backup to ubuntu-vm
echo "Moving backup to ubuntu-vm:/backups/"
read -sp "Enter root password for ubuntu-vm: " ROOT_PASSWORD
echo
sshpass -p "$ROOT_PASSWORD" scp "$BACKUP_FILE.gz" root@ubuntu-vm:/backups/
echo "Backup moved to ubuntu-vm:/backups/"

echo "Backup completed successfully."

