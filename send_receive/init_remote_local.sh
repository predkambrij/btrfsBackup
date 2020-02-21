PATH="$PATH:/home/loj/.nix-profile/bin"

pw="secre"

if ! test -d /1t_btrfs/netcup/; then
    echo "not mounted /1t_btrfs/netcup/"
    exit 
fi

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

function execute_remote() {
    expect -c " 
spawn bash -c \"ssh root@n.blatnik.org -i netcup_root_id_rsa  $1 \"
expect \"Enter passphrase\"
send \"$pw\r\"
interact
    "
}

for subvname in @opt_docker_volumes @ @home;do

    if ! test -f "/1t_btrfs/netcup/"$subvname"_last_time"; then
        echo "proceed $subvname"

        com="'btrfs send  /ssd/\$\(head -n 1 /ssd/maint_snps/"$subvname"_list\)' | btrfs receive /1t_btrfs/netcup/"
        echo $com
        execute_remote "$com"
        com="'head -n 1 /ssd/maint_snps/"$subvname"_list' > /1t_btrfs/netcup/"$subvname"_last_time"
        echo $com
        execute_remote "$com"
        com="'sed -i -e 1d /ssd/maint_snps/"$subvname"_list'"
        echo $com
        execute_remote "$com"


    else
        echo "$subvname already exists"
    fi
done


