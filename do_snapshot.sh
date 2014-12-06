# working daily weekly monthly
# format
# @
# @_working_snapshot_ro_date
# @home_loj_working_snapshot_ro_date
# @home_loj_virtualbox_working_snapshot_ro_date

# subvolume

if [ "$1" == "@" ];then
    subvol="$1"
elif [ "$1" == "@home" ];then
    subvol="$1"
else
    echo "@ or @home is valid"
    exit 1
fi

# frequency
if [ "$2" == "manual" ];then
    frequency="$2"
elif [ "$2" == "daily" ];then
    frequency="$2"
elif [ "$2" == "weekly" ];then
    frequency="$2"
else
    echo "manual daily weekly is available"
    exit 1
fi

function verbose_command() {
    echo "$@"
    $@
}

# go to the root of the filesystem
cd /ssd

# destination snapshot
dest=$subvol"_"$frequency"_snapshot_ro_"$(date +%Y-%m-%d_%H:%M)


verbose_command btrfs subvolume snapshot -r  $subvol $dest 
if [ $? -ne 0 ];then
    echo "failed"
    exit 3
else
    # mark latest snapshot name
    echo $dest>>$subvol"_"$frequency"_list"
fi
sync


