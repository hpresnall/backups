#!/bin/zsh
# runs yabrc compare on all laptop vs SSD backup indexes
# optionally updates the indexes before comparing them
. ./functions.sh

./combine_media.sh

# update the indexes when update is specified
UPDATE=
set +o nounset
if [[ "$1" == "update" ]]; then
  UPDATE=(update --autosave)

  # specify 'update full' to re-checksum all files instead of just changes
  if [[ "$2" != "full" ]]; then
    UPDATE=($UPDATE --fast)
  fi
fi
set -o nounset

if [[ "$UPDATE" != "" ]]; then
  # run yabrc update on source
  echo "Updating laptop checksums..."
  yabrc_update mac backup documents development pictures

  echo

  # yabrc update on backup
  echo "Updating backup checksums..."
  yabrc_update ssd backup documents development images raw

  ok
fi
# else run with existing indexes

echo "Comparing laptop with backup..."
yabrc_compare backup mac ssd
yabrc_compare documents mac ssd
yabrc_compare development mac ssd
set +o errexit
echo "\n----- pictures -----\n"
$YABRC compare $YABRC_DIR/mac/mac_pictures.properties $YABRC_DIR/ssd/ssd_images.properties
# mac raw is a partial copy, use ignoreMissing to only compare the files that are on both
echo "\n----- raw -----\n"
$YABRC compare --ignore_missing $YABRC_DIR/mac/mac_raw.properties $YABRC_DIR/ssd/ssd_raw.properties
set -o errexit

echo
echo "Updating data not on laptop..."
# data not on laptop; nothing to compare, just update
if [[ "$UPDATE" == "" ]]; then
  UPDATE=(update --autosave --fast) # default to --fast
  yabrc_update ssd media_noimages raw
else # use existing update command
  yabrc_update ssd media_noimages # raw was already updated
fi

echo