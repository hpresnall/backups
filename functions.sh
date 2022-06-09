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
UPDATE=(update --fast --autosave) # default to fast updates, only checksumming new / changed files

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
  local prefix=$1
  local path=$YABRC_DIR/$1
  shift
  for name in "$@"; do
    echo "\n----- ${prefix}_$name -----\n"
    $YABRC $UPDATE $path/${prefix}_$name.properties
  done
  echo
}

# $1 = index name
# $2 and $3 are index prefixes which are also in directories with the same name
function yabrc_compare () {
  echo "\n----- $1 -----\n"
  local index1=$YABRC_DIR/$2/$2_$1.properties
  local index2=$YABRC_DIR/$3/$3_$1.properties
  set +o errexit # compare returns non-zero if there are changes; ensure multiple compares can run
  $YABRC compare $index1 $index2
  set -o errexit
}