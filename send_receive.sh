echo "Locations of root btrfs:: ssd: /ssd & 1t: /1t ok?";read

# subvolume
if [ "$1" == "@" ];then
    subvol="$1"
elif [ "$1" == "@home" ];then
    subvol="$1"
elif [ "$1" == "@opt_docker_volumes" ];then
    subvol="$1"
else
    echo "@ or @home or @opt_docker_volumes is valid"
    exit 1
fi

# device
if [ "$2" == "think" ];then
    device="$2"
elif [ "$3" == "serv1" ];then
    device="$2"
else
    echo "think and serv1 is available"
    exit 1
fi

function verbose_btrfs() {
    echo "$@ | btrfs receive /1t/"$device"/"
    $@ | btrfs receive "/1t/"$device"/"
    return $?
}

# go to the root of the filesystem
cd /ssd


# incremental send
function incremental_send() {
    parent=/ssd/$(cat "/1t/"$device"/"$subvol"_last_time")
    latest=$1
    
    if [ $parent == $latest ]; then
        echo "last_time and latest are the same! Do a new snapshot!"
        exit 2
    fi
    
    test -d $parent || (echo "parent $parent doesn't exist!"; exit 3)
    test -d $latest || (echo "latest $latest doesn't exist!"; exit 4)
    
    verbose_btrfs btrfs send -p $parent $latest 
    x=$?
    if [ $x -ne 0 ];then
        echo "failed $x"
        exit 3
    else
        # last time rotate
        cat "/ssd/maint_snps/"$subvol"_list" | head -n 1 > "/1t/"$device"/"$subvol"_last_time"
        # remove first line of the list
        sed -i -e "1d" "/ssd/maint_snps/"$subvol"_list"
        echo "$parent" >> "/ssd/maint_snps/"$subvol"_toremove"
    fi
}
echo "snapshots to transfer:$(cat "/ssd/maint_snps/"$subvol"_list"|wc -l)"
cat "/ssd/maint_snps/"$subvol"_list" | while read next_snapshot; do
    echo snapshot $next_snapshot
    incremental_send $next_snapshot
done


