#!/bin/bash

. "$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)/${BTRFSBACKUP_CONF_FILE:-conf.sh}"
. "$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)/helpers.sh"

function doSnapshotForAllSubvolumes() {
    localChecks
    local postfix="$1"

    for subvolname in ${SUBVOLUME_LIST}; do
        doSnapshot "${subvolname}" "${postfix}"
    done
}

function doSnapshot() {
    local subvolname="$1"
    localChecks "$subvolname"

    local postfix="$2"
    if [ -z "${postfix}" ]; then
        postfix="$DEFAULT_POSTFIX"
    fi

    local subvolpath="${BTRFS_ROOT}$subvolname"
    local snapshotpath="${BTRFS_SNPS}@snp_ro_${subvolname}_${postfix}_"$(date +%Y-%m-%d_%H:%M)

    if ! [ -d "${subvolpath}" ]; then
        echo "subvolpath ${subvolpath} doesn't exist!"
        exit 1
    fi

    runCommandVerbose btrfs subvolume snapshot -r "${subvolpath}" "${snapshotpath}"
    echo "${snapshotpath}" >> "${BTRFS_MAINT}${subvolname}_list"
    sync
}

function sendLocalAll() {
    localChecks
    for subvolname in ${SUBVOLUME_LIST}; do
        local subvollistfile="${BTRFS_MAINT}${subvolname}_list"
        if ! [ -f "${subvollistfile}" ]; then
            echo "file $subvollistfile doesn't exist! Creating snapshot for subvolume ${subvolname}"
            _doSnapshot "${subvolname}" "${DEFAULT_POSTFIX}"
        fi

        if ! [ -f "${BTRFS_ROOT}/maint_snps/${subvolname}_toremove" ]; then
            _initLocalSending "$subvolname" "$DEFAULT_POSTFIX"
        fi

        echo "subvolume: ${subvolname} snapshots: "$(cat "${subvollistfile}" | wc -l)
        while read snapshotPath; do
            echo "snapshot $snapshotPath"
            _incrementalSend "$subvolname" "$snapshotPath"
        done < "${subvollistfile}"
    done
}

function _incrementalSend() {
    local subvolname=$1
    local snapshotPath=$2
    local toremoveLocation="${BTRFS_MAINT}${subvolname}_toremove"
    local listLocation="${BTRFS_MAINT}${subvolname}_list"
    local lasttimeLocation="${BTRFS_MAINT}${subvolname}_lasttime"
    local parentSnapshotPath=$(cat "$lasttimeLocation")

    echo "parent:${parentSnapshotPath} snapshotPath:${snapshotPath}"
    if [ "$parentSnapshotPath" == "$snapshotPath" ]; then
        echo "parent (lasttime) snapshotPath are the same!"
        exit 2
    fi

    test -d $parentSnapshotPath || { echo "parent $parentSnapshotPath doesn't exist!"; exit 3; }
    test -d $snapshotPath       || { echo "snapshotPath $snapshotPath doesn't exist!"; exit 4; }

    runCommandVerbose bash -c "btrfs send -p \"${parentSnapshotPath}\" \"${snapshotPath}\" | btrfs receive \"${BTRFSBACKUP_DIR}\""
    sync

    cat "$listLocation" | head -n 1 > "$lasttimeLocation"
    sed -i -e "1d" "$listLocation"
    echo "$parentSnapshotPath" >> "$toremoveLocation"
}

function _initLocalSending() {
    local subvolname="$1"
    local postfix="$2"

    echo "initializing $subvolname"
    local subvolpath=$(head -n 1 "${BTRFS_MAINT}${subvolname}_list")
    if ! [ -d "${subvolpath}" ]; then
        echo "subvolpath ${subvolpath} doesn't exist!"
        exit 1
    fi

    runCommandVerbose bash -c "btrfs send \"$subvolpath\" | btrfs receive \"${BTRFSBACKUP_DIR}\""
    sync

    runCommandVerbose touch "${BTRFS_MAINT}${subvolname}_toremove"
    runCommandVerbose bash -c "head -n 1 \"${BTRFS_MAINT}${subvolname}_list\" > \"${BTRFS_MAINT}${subvolname}_lasttime\""
    runCommandVerbose sed -i -e "1d" "${BTRFS_MAINT}${subvolname}_list"
}

function deleteTransferedAll() {
    localChecks
    for subvolname in ${SUBVOLUME_LIST}; do
        local toremoveLocation="${BTRFS_MAINT}${subvolname}_toremove"
        echo "subvolume: ${subvolname} snapshots:"$(cat "$toremoveLocation" | wc -l)
        while read snapshotPath; do
            echo "snapshot $snapshotPath"

            runCommandVerbose btrfs subvolume delete "$snapshotPath"
            sync

            sed -i -e "1d" "$toremoveLocation"
        done < "${toremoveLocation}"
    done
}

# run the command with arguments
"$@"
