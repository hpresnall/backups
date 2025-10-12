#!/bin/zsh
# backup all laptop files to an external SSD
# differs from backup.ssh due to the laptop containing a partial copy of /Media
DIR=$(cd -P -- "$(dirname -- "$0")" && pwd -P)

SOURCE=/Users/hunter
DEST=/Volumes/SSDBackup

SOURCE_DISK=mac
BACKUP_DISK=ssd

. $DIR/functions.sh

# copy SSH keys to backup without checking
backup --silent $SOURCE/.ssh $SOURCE/Backup

# skipping ssd_media since those files should not change; see validate_ssd.sh
INDEXES=(backup documents development)

# run yabrc update on the source
yabrc_update $SOURCE_DISK $INDEXES pictures raw

# display what will be copied
backup --dry_run $INDEXES pictures partial_raw
ok

# actually copy
backup $INDEXES pictures partial_raw
echo "Complete!"
echo

# run yabrc update on the backup
yabrc_update $BACKUP_DISK $INDEXES images raw

# copy the updated indexes to the backup
backup --silent $SOURCE/Backup/yabrc $DEST/Backup/

# not running yabrc compare here as in backup.sh
# use validate_ssd.sh instead without 'update' to check for changes
# this will check the rest of SSD /Media for changed files
$DIR/validate_ssd.sh
