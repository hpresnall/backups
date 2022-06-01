#!/bin/zsh
# backup drives are orgainized as /Media/Images, Videos, Games etc.
# not all of these subdirectories are stored on the laptop
# so, multiple yabrc indexes are used for the main SSDBackup volume
# this script combines these indexes into a single index so it can be compared with other backup drives

set -o errexit
set -o nounset

YABRC=yabrc
YABRC_DIR=/Users/hunter/Backup/yabrc # location of config files and indexes

# indexes are just gzipped CSV files
# start with the base media directory
gunzip -k -c $YABRC_DIR/ssd/ssd_media_noimages_current > /tmp/media

# skip header row on subsequent indexes
# update the relative path of each entry
IFS=$(echo -en "\n\b")

for entry in $(gunzip -k -c $YABRC_DIR/ssd/ssd_images_current | tail -n+2); do
  echo "Images/$entry" >> /tmp/media
done

for entry in $(gunzip -k -c $YABRC_DIR/ssd/ssd_raw_current | tail -n+2); do
  echo "Images/RAW/$entry" >> /tmp/media
done

gzip -f /tmp/media
mv /tmp/media.gz $YABRC_DIR/ssd/ssd_media_current

# note using pre-created ssd_media.properties
$YABRC print $YABRC_DIR/ssd/ssd_media.properties