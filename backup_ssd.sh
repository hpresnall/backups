#!/bin/zsh
# backup all laptop files to an external SSD
DIR=$(cd -P -- "$(dirname -- "$0")" && pwd -P)

SOURCE=/Users/hunter
DEST=/Volumes/SSDBackup

SOURCE_DISK=mac
BACKUP_DISK=ssd

. $DIR/functions.sh

# copy SSH keys to backup without checking
backup --silent --dry_run $SOURCE/.ssh $SOURCE/Backup

# run yabrc update on the source
yabrc_update $SOURCE_DISK backup documents development pictures raw

# display what will be copied
backup --dry_run backup documents development pictures partial_raw
ok

# actually copy
backup backup documents development pictures partial_raw
echo "Complete!"
echo

# run yabrc update on the backup
yabrc_update $BACKUP_DISK backup documents development images raw
# note skipping ssd_media since those files should not change; see validate_ssd.sh

# copy the updated indexes to the backup
backup --silent  $SOURCE/Backup/yabrc $DEST/Backup/
