#!/bin/bash

PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/opt/etcd-v2.0.0-linux-amd64:/opt/kubernetes"
# mount disk if it's not already
PATH=$PATH bash -c "test 0 -eq $(mount |grep /ssd|wc -l) && mount -U 32ad744b-16f6-4b1d-88c0-eb0d4c6a67ee /ssd/"

whoami
date
cd /opt/btrfsBackup
PATH=$PATH bash do_snapshot.sh @ daily
PATH=$PATH bash do_snapshot.sh @home daily
PATH=$PATH bash do_snapshot.sh @opt_docker_volumes daily
sync

