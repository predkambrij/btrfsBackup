#What this project is about?
Bash scripts for doing, transfering and deleting snapshots of btrfs subvolumes.

It's useful if you have btrfs on your laptop and you want to have automated daily/weekly/monthly backups.
From time to time when you're running out of free space you can send new snapshots to external (btrfs) HDD and delete transfered snapshots from laptop's disk.

Scripts currently include hardcoded paths as they are done ad-hoc (quick & dirty)

#examples

    # do some snapshots
    sudo bash do_snapshot.sh @home manual
    sudo bash do_snapshot.sh @ manual
    sudo bash do_snapshot.sh @home manual
    sudo bash do_snapshot.sh @ manual
    sudo bash do_snapshot.sh @ daily # could be done with cron
    sudo bash do_snapshot.sh @ daily # could be done with cron
    sudo bash do_snapshot.sh @home daily # could be done with cron
    sudo bash do_snapshot.sh @home daily # could be done with cron

    # only at the first time of sending for each type (manual, daily, ...) and each subvolume (@, @home, ...)
    # make file with snapshot name you will send manualy on destination disk (in example is mounted on /1t/)
    # eg.
    echo "@home_daily_snapshot_ro_2014-12-06_15:12" > /1t/@home_daily_last_time
    sudo btrfs send $(cat /1t/@home_daily_last_time) | btrfs receive /1t/ # will take some time as it will send whole subvolume

    # for a new type (manual, daily, ...) you can set parent of one recent snapshot which already exist on external drive and is not deleted on laptop's disk yet
    # eg.
    sudo btrfs send -p /ssd/@home_manual_snapshot_ro_2014-12-06_15:08 /ssd/$(cat /1t/@home_daily_last_time) | btrfs receive /1t/ # is much faster
    
    # after that, delete it from list that send_receive.sh won't try to send it again
    sed -i -e "/$(cat /1t/@home_daily_last_time)/d" /ssd/@home_daily_list
    
    # all further sends can be done with following command
    sudo bash send_receive.sh @home daily

    # and delete them from laptop's disk if you wish
    sudo bash delete_transfered.sh @home daily


    # examples of command with another type or subvolume 

    # send all manual snapshots for @home subvolume (which weren't sent yet)
    sudo bash send_receive.sh @home manual

    # send all manual snapshots for @ subvolume
    sudo bash send_receive.sh @ manual

    # send all daily snapshots for @ subvolume
    sudo bash send_receive.sh @ daily

    # delete all manual snapshots for @home subvolume which were sent (to external disk)
    sudo bash delete_transfered.sh @home manual


