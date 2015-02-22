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

function verbose_command() {
    echo "$@"
    $@
}


echo "snapshots to delete:$(cat "/ssd/maint_snps/"$subvol"_toremove" | wc -l)"
echo "ok?";read

cat "/ssd/maint_snps/"$subvol"_toremove" | while read next_snapshot; do
    echo snapshot $next_snapshot
    verbose_command btrfs subvolume delete $next_snapshot
    x=$?
    if [ $x -ne 0 ];then
        echo "failed $x"
        exit 3
    else
        # remove from list to delete
        sed -i -e "1d" "/ssd/maint_snps/"$subvol"_toremove"
        echo -e "snapshot $next_snapshot deleted\n"
    fi
    sync
done

