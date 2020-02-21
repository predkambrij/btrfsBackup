# this is the root mountpoint of the filesystem that is going to be backed up
BTRFS_ROOT="/btrfs_root_filesystem/"
# this is a subdirectory where snapshots will be created
BTRFS_SNPS="/btrfs_root_filesystem/snapshots_directory/"
# this is a subdirectory where the script will create status files (improvised database)
BTRFS_MAINT="/btrfs_root_filesystem/maint_snapshots/"

# this is the root of a btrfs filesystem (for backup)
BTRFSBACKUP_ROOT="/btrfsbackup/"
# this is a subdirectory where snapshots are going to be sent
BTRFSBACKUP_DIR="/btrfsbackup/possiblesubdirectory/"

# list of subvolumes to be backed up (script expects them to be at the root level)
SUBVOLUME_LIST="@subvolume1 @subvolume2"
# postfix in snapshot name (you can override that in doSnapshotForAllSubvolumes and doSnapshot command)
DEFAULT_POSTFIX="pf"
