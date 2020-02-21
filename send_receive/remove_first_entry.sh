#!/bin/bash

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

source env_vars.sh
echo  "EXP: Password: "
read -s x

#spawn bash -c \"ssh -i $id_rsa_name $remote_user"@"$domain 'btrfs send $2' | btrfs receive $bu_path$bu_dirname/;echo END\$?;\"
#spawn bash -c \"ssh -i $id_rsa_name $remote_user"@"$domain 'uname -a;echo $remote_bu_path\$\(cat $remote_bu_path""maint_snps/$subv""_list|head -n 1\);';echo END\$?;\"

for subv in $subvolumes; do
    expect -c " 
spawn bash -c \"ssh -i $id_rsa_name $remote_user"@"$domain 'sed -i -e 1d $remote_bu_path""maint_snps/$subv""_list' ;echo END\$?;\"
expect \"Enter passphrase\"
send \"$x\r\"
interact
";
done


