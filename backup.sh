#!/bin/zsh
# copy all files from the SSD backup to another disk
# assumes all files are on the first disk
DIR=$(cd -P -- "$(dirname -- "$0")" && pwd -P)

BACKUP=$1
set +o nounset
if [ -z "$2" ]; then
  BACKUP_DISK=${BACKUP:l} # assume YABRC file names are the lowercase disk name
else
  BACKUP_DISK=$2
fi
set -o nounset

SOURCE_DISK=ssd

SOURCE=/Volumes/SSDBackup
DEST=/Volumes/$BACKUP

. $DIR/functions.sh

# display what will be copied
backup --dry_run backup documents development media
ok

# actually copy
backup backup documents development media
echo "Complete!"
echo

# run yabrc update on the backup
yabrc_update $BACKUP_DISK backup documents development media

echo

# compare source and backup
yabrc_compare $SOURCE_DISK $BACKUP_DISK backup documents development media
