#!/bin/zsh
# copy all files from one backup disk to another
# assumes all files are on the first disk
. ./functions.sh

BACKUP=$1
set +o nounset
if [[ -z $2 ]]; then
  PREFIX=${BACKUP:l} # assume prefix is the lowercase drive name
else
  PREFIX=$2
fi
set -o nounset

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
yabrc_update $PREFIX backup documents development media

# finally, compare source and destination
echo "Comparing source with destination..."
yabrc_compare backup ssd $PREFIX
yabrc_compare documents ssd $PREFIX
yabrc_compare development ssd $PREFIX
yabrc_compare media ssd $PREFIX