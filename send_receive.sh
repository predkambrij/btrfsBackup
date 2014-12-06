echo "Locations of root btrfs:: ssd: /ssd & 1t: /1t ok?";read

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

function verbose_btrfs() {
    echo "$@ | btrfs receive /1t/"
    $@ | btrfs receive /1t/
}

# go to the root of the filesystem
cd /ssd


# incremental send
function incremental_send() {
    parent=/ssd/$(cat "/1t/"$subvol"_"$frequency"_last_time")
    #latest=/ssd/$(cat "/ssd/"$subvol"_"$frequency"_list"|head -n 1)
    latest=$1
    
    if [ $parent == $latest ]; then
        echo "last_time and latest are the same! Do a new snapshot!"
        exit 2
    fi
    
    test -d $parent || (echo "parent $parent doesn't exist!" && exit 3)
    test -d $latest || (echo "latest $latest doesn't exist!" && exit 4)
    
    verbose_btrfs btrfs send -p $parent $latest 
    if [ $? -ne 0 ];then
        echo "failed"
        exit 3
    else
        # last time rotate
        mv "/1t/"$subvol"_"$frequency"_last_time" "/1t/"$subvol"_"$frequency"_last_time-bu"
        cat "/ssd/"$subvol"_"$frequency"_list" | head -n 1 > "/1t/"$subvol"_"$frequency"_last_time"
        # remove first line of the list
        sed -i -e "1d" "/ssd/"$subvol"_"$frequency"_list"
        echo "$parent" >> "/ssd/"$subvol"_"$frequency"_toremove"
    fi
}
echo "snapshots to transfer:$(cat "/ssd/"$subvol"_"$frequency"_list"|wc -l)"
cat "/ssd/"$subvol"_"$frequency"_list" | while read next_snapshot; do
    echo snapshot $next_snapshot
    incremental_send $next_snapshot
done


