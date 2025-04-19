function runCommandVerbose() {
    echo "$@"
    runCommand "$@"
}

function runCommand() {
    "$@"

    local exitStatus=$?
    if [ "$exitStatus" -ne "0" ]; then
        echo "command $@ failed with ${exitStatus}"
        exit ${exitStatus}
    fi
}

# localChecks
# Performs various system and environment checks before executing backup operations
#
# Parameters:
#   $1 - Caller's function name
#   $2 - Subvolume name to validate against SUBVOLUME_LIST
#
# Side effects:
#   - Creates BTRFS_SNPS directory if it doesn't exist
#   - Creates BTRFS_MAINT directory if it doesn't exist
function localChecks() {
    if [[ $EUID -ne 0 ]]; then
        echo "This script must be run as root" 1>&2
        exit 1
    fi

    if [ -z "${SUBVOLUME_LIST}" ]; then
        echo "SUBVOLUME_LIST is not set!"
        exit 1
    fi

    if ! [ -z "$2" ]; then
        # check if given subvolume is on the list
        if ! [[ " $SUBVOLUME_LIST " =~ " $2 " ]]; then
            echo "subvolume $2 isn't on SUBVOLUME_LIST!"
            exit 1
        fi
    fi

    if [ -z "${DEFAULT_POSTFIX}" ]; then
        echo "DEFAULT_POSTFIX is not set!"
        exit 1
    fi

    if ! mountpoint -q "${BTRFS_ROOT}"; then
        echo "make sure that BTRFS_ROOT is mounted at ${BTRFS_ROOT}"
        exit 1
    fi

    # BTRFSBACKUP_ROOT doesn't need to be mounted when making snapshots
    if ! [[ " doSnapshot doSnapshotForAllSubvolumes " =~ " $1 " ]]; then
        if ! mountpoint -q "${BTRFSBACKUP_ROOT}"; then
            echo "make sure that BTRFSBACKUP_ROOT is mounted at ${BTRFSBACKUP_ROOT}"
            exit 1
        fi
    fi

    if ! [ -d "${BTRFS_SNPS}" ]; then
        echo "creating snps directory ${BTRFS_SNPS}"
        mkdir "${BTRFS_SNPS}"
    fi

    if ! [ -d "${BTRFS_MAINT}" ]; then
        echo "creating maint directory ${BTRFS_MAINT}"
        mkdir "${BTRFS_MAINT}"
    fi
}
