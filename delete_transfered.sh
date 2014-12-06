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


echo "snapshots to delete:$(cat "/ssd/"$subvol"_"$frequency"_toremove" | wc -l)"
echo "ok?";read

cat "/ssd/"$subvol"_"$frequency"_toremove" | while read next_snapshot; do
    echo snapshot $next_snapshot
    verbose_command btrfs subvolume delete $next_snapshot
    if [ $? -ne 0 ];then
        echo "failed"
        exit 3
    else
        # remove from list to delete
        sed -i -e "1d" "/ssd/"$subvol"_"$frequency"_toremove"
        echo -e "snapshot $next_snapshot deleted\n"
    fi
    sync
done

