# Backup Scripts

This set of scripts is designed to backup files from a laptop to an external USB drive. Once that drive is backed up, the files there can be copied to one or more *other* drives for additional backups.

rsync is used to copy files bewteen disks. Note that this should be the version installed from HomeBrew, *not* the default that comes with MacOS which is very old and outdated.

[yabrc](https://github.com/hpresnall/yabrc) is used to create checksums of files on both the source and backups. This program compares the contents of all files to confirm backups are consistent and ensures that files at rest do not change (aka bit rot).

## Laptop Configuration

The laptop functions as the source and master of *almost* all files. The following directories will be backed up:

- `Backup` - archival documents that are rarely changed. Also includes these backup scripts and the `yabrc` directory containing configuration files & indexes for validating backups.
- `Documents` - actively edited documents
- `Development` - code and other projects
- `Pictures` - images and videos. This includes a *partial* copy of the `RAW` directory containing unedited camera files. The full copy exists on all backup disks.

The base directory for all these locations is the user's home directory (`~` or `/Users/<username`>).

## Backup Disk Configurations

All backup drives will contain copies of the above laptop directories. However, the directory structure is slightly different:

- Images are stored in `Media/Images`, not `Pictures`
- A complate set of unedited camera files is stored in `Media/Images/RAW`
- `Media` contains other directories of old data which is at rest. This *will not be checksummed* as part of regular backups.

## yabrc Configuration

All yabrc `.properties` files are contained in `Backup/yabrc`. There is a separate subdirectory for each backup disk.

The source laptop configurations are in `mac` and use the following `.properties` files:

- `mac_backup.properties` - for `~/Backup`
- `mac_documents.properties` - for `~/Documents`
- `mac_development.properties` - for `~/Development`
- `mac_pictures.properties` - for `~/Pictures`; excludes `RAW`
- `mac_raw.properties` - for `~/Pictures/RAW`; this is a partial copy of what is on the backups

Backups disks use the following configurations:

- `<backup>_backup.properties` - mirrors `mac_backup`
- `<backup>_documents.properties` - mirrors `mac_documents`
- `<backup>_development.properties` - mirrors `mac_development` except for `.git` directories
- `<backup>_media.properties` - mirrors `mac_pictures` under `Media/Images` plus all the RAW files and other data at rest

In all cases, backup disks are mounted under `/Volumes` on MacOS.

Except for the default, external SSD backup, `<backup>_media` indexes *all* the data in `<backup>/Media`. For comparison with the partial contents of the laptop, the default SSD backup instead includes indexes for:

- `ssd_media_noimages` - `Media` without `Images`
- `ssd_images` - `Media/Images` without `RAW`
- `ssd_raw` - `Media/Images/RAW`

For comparison with other backup drives, the `ssd_media` index is created using the above indexes via `combine_media.sh` script. It *must* be run before comparing the SSD with other backup disks.

## Shell Scripts

### `backup_ssd.sh`

Used to copy files from the laptop to the default SSD backup. This script updates the SSD yabrc indexes after copying the files, using `--fast`.

### `combine_media.sh`
Merges the SSD indexes for `Media` into `ssd_media_current` for comparision with other backups.

### `backup.sh`
Copies files from the default SSD backup disk to another backup. The backup disk is specified by the first command line parameter (`$1`). It is assumed that the prefix used for the yabrc indexes is the lowercase name of the mountpoint for the disk. If not, `$2` can be used to set the prefix.

After copying the files, `yabrc update --fast` is run to update the destination indexes. Finally `yabrc compare` is run on all the indexes to ensure all files match between the external SSD and destination.

### `validate_ssh.sh`
Runs `yabrc compare` on all laptop indexes against the SSD indexes. Also updates `ssd_media_noimages` and `ssd_raw` to confirm that no files at rest have changed.

Accepts two optional parameters. `update` runs update on both the laptop and SSD indexes before doing the compare. `update full` updates the indexes *without* `--fast` to checksum all files, not just the files that have changed since the last index update.