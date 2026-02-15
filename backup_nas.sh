#!/bin/zsh
# copy all files to the NAS
# this is separate from the main backup.sh script due to how SMB volumes are defined on the NAS
# assumes all files are on the first disk
DIR=$(cd -P -- "$(dirname -- "$0")" && pwd -P)

# mount NAS volumes via SMB; this will open the Finder and prompt for user / pass, if needed
open 'smb://storage/Backup'
open 'smb://storage/Hunter' # includes Development & Document dirs
open 'smb://storage/Media'

. $DIR/functions.sh

# note using master backup disk, not the local copy to avoid partial RAW issues
SOURCE=/Volumes/SSDBackup

# display what will be copied
DEST=/Volumes/Backup
backup --dry_run backup

DEST=/Volumes/Hunter
backup --dry_run documents development

# directly mounted; /Media will be appended to $SOURCE
DEST=/Volumes
backup --dry_run media

ok

# actually copy
DEST=/Volumes/Backup
backup backup

DEST=/Volumes/Hunter
backup documents development

DEST=/Volumes
backup media

echo "Complete!"
echo

# run yabrc update on the NAS
yabrc_update nas backup #documents development media

echo

# compare source and NAS to ensure the copy was successful
yabrc_compare ssd nas backup documents development media

# copy the updated indexes to the backup
SOURCE=/Users/hunter/Backup/yabrc
DEST=/Volumes/Backup
backup --silent $SOURCE $DEST

umount /Volumes/Backup
umount /Volumes/Hunter
umount /Volumes/Media
