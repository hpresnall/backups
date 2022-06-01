#!/bin/zsh
# copy all files from one backup disk to another
# assumes all files are on the first disk
. ./functions.sh

set +o errexit
FROM=/Users/hunter
TO=/Volumes/Hunter

# rsync options and paths for each directory to backup
# note that any rsync --exclude (globs) need to match up with ignoredDirs (regexes) in yabrc configs
BACKUP=($FROM/Backup $TO)
DOCUMENTS=(--exclude=Adobe $FROM/Documents $TO)
DEVELOPMENT=(--exclude=.git $FROM/Development $TO)
#MEDIA=(--exclude='*.lrdata' --exclude='*.lroldplugin' --exclude='*.photoslibrary' --exclude="Photo Booth Library" $FROM/Media $TO)

# display what will be copied using $DRY_RUN
echo -n "Checking what will be copied... "
$MIRROR $DRY_RUN $BACKUP
$MIRROR $DRY_RUN $MIRROR $DOCUMENTS
$MIRROR $DRY_RUN $MIRROR $DEVELOPMENT
#$MIRROR $DRY_RUN $MIRROR $MEDIA

# confirm everything looks ok
ok

# then actually copy
echo -n "Copying files... "
$MIRROR $BACKUP
$MIRROR $DOCUMENTS
$MIRROR $DEVELOPMENT
#$MIRROR $MEDIA
echo "Complete!"

# run yabrc update on the destination backup
echo "Backup checksums"
echo
yabrc_update nas backup documents development #images

# finally, compare source and destination
echo "Comparing source with destination..."
echo
#yabrc_compare backup mac nas
#yabrc_compare documents mac nas
#yabrc_compare development mac nas
#yabrc_compare media mac nas