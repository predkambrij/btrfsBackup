#!/bin/bash

echo  "acih "
read -s x

expect -c " 
spawn ssh root@blatnik.info -i netcup_root_id_rsa \"bash -c 'uname -a; sleep 3; uname -a'\"
expect \"Enter passphrase\"
send \"$x\r\"
interact
"


