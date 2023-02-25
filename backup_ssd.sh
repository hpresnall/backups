#!/bin/zsh
# backup all laptop files to an external SSD

. ./functions.sh

FROM=/Users/hunter
TO=/Volumes/SSDBackup

# rsync options and paths for each directory to backup
# note that any rsync --exclude (globs) need to match up with ignoredDirs (regexes) in yabrc configs
BACKUP=($FROM/Backup $TO)
DOCUMENTS=(--exclude=Adobe $FROM/Documents $TO)
DEVELOPMENT=(--exclude=bin --exclude=build --exclude=target --exclude=apk_cache --exclude=__pycache__ --exclude=htmlcov $FROM/Development $TO) # backup git to SSD, but still ignore in index
# note trailing slash to copy contents _under_ Pictures to Media/Images
IMAGES=(--exclude=RAW --exclude='*.lrdata' --exclude='*.lroldplugin' --exclude='*.photoslibrary' --exclude="Photo Booth Library" $FROM/Pictures/ $TO/Media/Images)
# copy RAW separately since $FROM only has a partial backup / new files
RAW=($FROM/Pictures/RAW/ $TO/Media/Images/RAW/)

# copy SSH keys to backup without checking
$COPY $FROM/.ssh $FROM/Backup
echo

# first run yabrc update on source
echo "Source checksums"
yabrc_update mac backup documents development pictures raw

# then display what will be copied using $DRY_RUN
echo "Checking what will be copied... "
$MIRROR $DRY_RUN $BACKUP
$MIRROR $DRY_RUN $DOCUMENTS
$MIRROR $DRY_RUN $DEVELOPMENT
$MIRROR $DRY_RUN $IMAGES
$COPY $DRY_RUN $RAW # only copy since not all RAW files are kept on the laptop

# confirm everything looks ok
ok

# then actually copy
echo -n "Copying files... "
$MIRROR $BACKUP
$MIRROR $DOCUMENTS
$MIRROR $DEVELOPMENT
$MIRROR $IMAGES
$COPY $RAW # only copy since not all RAW files are kept on the laptop
echo "Complete!"

# run yabrc update on the backup
echo "Backup checksums"
yabrc_update ssd backup documents development images raw
# note skipping ssd_media since those files should not change; see validate_ssd.sh

# copy the updated indexes to the backup
$COPY $FROM/Backup/yabrc $TO/Backup/