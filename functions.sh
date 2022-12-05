#!/bin/zsh
# common functions for backups

set -o errexit
set -o nounset

RSYNC=rsync
COPY=($RSYNC -rth --copy-links)
MIRROR=($COPY --delete) # remove deleted files from backups
DRY_RUN=(--dry-run --itemize-changes)

YABRC=/Users/hunter/go/bin/yabrc
YABRC_DIR=/Users/hunter/Backup/yabrc # location of config files and indexes
UPDATE=(update --autosave --fast) # default to fast updates, only checksumming new / changed files

# user confirmation function
function ok () {
  vared -p "Does this look ok? " -c ok
  if [[ "$ok" != "y" ]]; then
    exit 1
  fi
  unset ok
  echo
}

function yabrc_update () {
  # $1 is the disk name
  # all other params are index names to update
  # YABRC indexes are named <disk_name>/<disk_name>_<index_name>
  local disk=$1
  local path=$YABRC_DIR/$1
  shift
  for name in "$@"; do
    echo "\n----- ${disk}_$name -----\n"
    $YABRC $UPDATE $path/${disk}_$name.properties
  done
  echo
}

function yabrc_compare () {
  # $1 is the index name
  # $2 is the source backup name / disk, $3 is the destination
  echo "\n----- $1 -----\n"
  local index1=$YABRC_DIR/$2/$2_$1.properties
  local index2=$YABRC_DIR/$3/$3_$1.properties
  set +o errexit # compare returns non-zero if there are changes; ensure multiple compares can run
  $YABRC compare $index1 $index2
  set -o errexit
}