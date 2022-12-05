#!/bin/zsh
# copy all files from one backup disk to another
# assumes all files are on the first disk
. ./functions.sh

BACKUP=$1
set +o nounset
if [[ -z $2 ]]; then
  BACKUP_DIR=${BACKUP:l} # assume YABRC file names are the lowercase disk name
else
  BACKUP_DIR=$2
fi
set -o nounset

SOURCE_DIR=ssd

FROM=/Volumes/SSDBackup
TO=/Volumes/$BACKUP

# rsync options and paths for each directory to backup
# note that any rsync --exclude (globs) need to match up with ignoredDirs (regexes) in yabrc configs
BACKUP=($FROM/Backup $TO)
DOCUMENTS=(--exclude=Adobe $FROM/Documents $TO)
DEVELOPMENT=(--exclude=.git $FROM/Development $TO)
MEDIA=(--exclude='*.lrdata' --exclude='*.lroldplugin' --exclude='*.photoslibrary' --exclude="Photo Booth Library" $FROM/Media $TO)

# display what will be copied using $DRY_RUN
echo "Checking what will be copied... "
$MIRROR $DRY_RUN $BACKUP
$MIRROR $DRY_RUN $DOCUMENTS
$MIRROR $DRY_RUN $DEVELOPMENT
$MIRROR $DRY_RUN $MEDIA

# confirm everything looks ok
ok

# then actually copy
echo -n "Copying files... "
$MIRROR $BACKUP
$MIRROR $DOCUMENTS
$MIRROR $DEVELOPMENT
$MIRROR $MEDIA
echo "Complete!"
echo

# run yabrc update on the destination backup
echo "Updating backup indexes..."
yabrc_update $TO backup documents development media

# compare source and destination
echo "Comparing source with destination..."
yabrc_compare backup $SOURCE_DIR $BACKUP_DIR
yabrc_compare documents $SOURCE_DIR $BACKUP_DIR
yabrc_compare development $SOURCE_DIR $BACKUP_DIR
yabrc_compare media $SOURCE_DIR $BACKUP_DIR