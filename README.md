#What this project is about?
bash scripts for doing, transfering and deleting snapshots of btrfs subvolumes
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

    # send all manual snapshots for @home subvolume
    sudo bash send_receive.sh @home manual

    # send all manual snapshots for @ subvolume
    sudo bash send_receive.sh @ manual

    # send all daily snapshots for @ subvolume
    sudo bash send_receive.sh @ daily

    # delete all manual snapshots for @home subvolume which were sent (to external disk)
    sudo bash delete_transfered.sh @home manual


