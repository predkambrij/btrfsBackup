#!/bin/bash

echo  "acih "
read -s x

expect -c " 
spawn bash -c \"ssh -i netcup_root_id_rsa root@blatnik.info 'btrfs send -p $1 $2' | btrfs receive /1t_btrfs/netcup/;echo END\$?;\"
expect \"Enter passphrase\"
send \"$x\r\"
interact

"


