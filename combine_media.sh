#!/bin/zsh
# backup drives are organized as /Media/Images, Videos, Games etc.
# not all of these subdirectories are stored on the laptop
# so, multiple yabrc indexes are used for the main SSDBackup volume
# this script combines these indexes into a single index so it can be compared with other backup drives

set -o errexit
set -o nounset

YABRC=yabrc
YABRC_DIR=/Users/hunter/Backup/yabrc/ssd # location of config files and indexes

# skip header row on indexes
TAIL=(tail -n+2)

echo "Combining SSD yabrc media indexes..."

# indexes are just gzipped CSV files
# start with the base media directory
gunzip -k -c $YABRC_DIR/ssd_media_noimages_current > /tmp/yabrc_idx

# update the header row with the current timestamp; output the rest of the index unchanged
echo "$(head -n1 /tmp/yabrc_idx | cut -d, -f1),$(date +%s)" > /tmp/media
$TAIL /tmp/yabrc_idx >> /tmp/media
rm /tmp/yabrc_idx

IFS=$(echo -en "\n\b")

# update the relative path of each entry
for entry in $(gunzip -k -c $YABRC_DIR/ssd_images_current | $TAIL); do
  echo "Images/$entry" >> /tmp/media
done

for entry in $(gunzip -k -c $YABRC_DIR/ssd_raw_current | $TAIL); do
  echo "Images/RAW/$entry" >> /tmp/media
done

# create the final index file
gzip -f /tmp/media
mv /tmp/media.gz $YABRC_DIR/ssd_media_current

# using pre-created ssd_media.properties
$YABRC print $YABRC_DIR/ssd_media.properties
echo