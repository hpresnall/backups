#!/bin/zsh
# common functions for backups

set -o errexit
set -o nounset

MOCK=
#MOCK=echo
RSYNC=rsync

YABRC=/Users/hunter/go/bin/yabrc
YABRC_DIR=/Users/hunter/Backup/yabrc # location of config files and indexes
UPDATE=(update --autosave --fast) # default to fast updates, only checksumming new / changed files

# user confirmation function
function ok () {
  vared -p "Does this look ok? " -c ok
  if [ "$ok" != "y" ]; then
    exit 1
  fi
  unset ok
  echo
}

MEDIA_EXCLUDES=(--exclude='*.lrdata' --exclude='*.lroldplugin' --exclude='*.photoslibrary' --exclude='Photo Booth Library')

# assumes SOURCE and DEST are defined
function backup() {
  # default to mirroring backups by deleting files in destination that are not in source
  local mirror="--delete"
  local dry_run=""
  local silent=false

  # parse options; note MacOS getopt is not GNU, so easier to just fake it
  # does not handle errors or out of order options
  while true; do
    case "$1" in
      --copy_only)
          mirror="";;
      --dry_run)
          dry_run=(--dry-run --itemize-changes);;
      --silent)
          silent="true";;
      *)
        break;;
    esac
    shift
  done

  if [ "$silent" = "false" ]; then
    if [ -z "$dry_run" ]; then
      echo "Copying files... "
    else
      echo "Checking what will be copied... "
    fi
  fi

  # the rest of the args will usually be a named location
  # this provides symmetry with the yabrc_ functions
  while [ $# -gt 0 ]; do
    local location=$1
    local src=
    local dest=$DEST
    local mirror=$mirror

    # ignore MacOS metadata
    local opts=(--exclude='.DS_Store' --exclude='._*')

    # note that any --exclude (globs) need to match up with ignoredDirs (regexes) in yabrc configs
    case "$location" in
      backup)
        src=$SOURCE/Backup;;
      documents)
        opts+=(--exclude=Adobe)
        src=$SOURCE/Documents;;
      development)
        opts+=(--exclude=bin --exclude=build --exclude=target --exclude=apk_cache --exclude=__pycache__ --exclude=htmlcov)
        src=$SOURCE/Development;;
      media)
        opts+=($MEDIA_EXCLUDES)
        src=$SOURCE/Media;;
      pictures)
        # laptop Pictures -> Backup/Media/Images
        # note trailing slash to copy contents _under_ Pictures to Media/Images
        opts+=(--exclude=RAW $MEDIA_EXCLUDES)
        src=$SOURCE/Pictures/
        dest=$DEST/Media/Images;;
      partial_raw)
        # laptop RAW is a partial copy; never mirror!
        mirror=""
        src=$SOURCE/Pictures/RAW/
        dest=$DEST/Media/Images/RAW;;
      *)
        # unknown location, assume provided args are a source and destination
        src=$1
        shift
        dest=$1;;
    esac

    shift

    $MOCK $RSYNC -rth --copy-links $mirror $dry_run $opts $src $dest
  done
}

function yabrc_update () {
  # $1 is the backup name / disk
  # all other params are index names to update
  # YABRC indexes are named <disk_name>/<disk_name>_<index_name>
  local disk=$1
  local path=$YABRC_DIR/$1
  shift

  echo "Updating indexes for $disk..."

  for index_name in "$@"; do
    echo "\n----- ${index_name} -----\n"
    $MOCK $YABRC $UPDATE $path/${disk}_${index_name}.yaml
  done

  echo
}

function yabrc_compare () {
  # $1 is the source backup name / disk, $2 is the destination
  local source=$1
  local dest=$2
  shift 2

  echo "Comparing $source with $dest..."

  for index_name in "$@"; do
    echo "\n----- ${index_name} -----\n"

    local index1=$YABRC_DIR/$source/${source}_${index_name}.yaml
    local index2=$YABRC_DIR/$dest/${dest}_${index_name}.yaml

    set +o errexit # compare returns non-zero if there are changes; ensure multiple compares can run
    $MOCK $YABRC compare $index1 $index2
    set -o errexit
  done
}
