#!/bin/bash

echo  "acih "
read -s x

expect -c " 
spawn ssh root@blatnik.info -i netcup_root_id_rsa \"$1\"
expect \"Enter passphrase\"
send \"$x\r\"
interact
"


