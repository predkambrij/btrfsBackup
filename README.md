## What is this project about?

Bash scripts for making, transfering and deleting snapshots of btrfs subvolumes.

It's useful if you have btrfs on your computer and you want to make regular snapshots and transfer all of them later to external btrfs storage (and after that delete them from your computer).

First time setup: copy config.sample.sh to config.sh and set the variables.

## EXAMPLES

### CREATE SNAPSHOTS (for all subvolumes or for desired one)

    # ./backup.sh doSnapshotForAllSubvolumes
    btrfs subvolume snapshot -r /btrfs/@test1 /btrfs/snps/@snp_ro_@test1_pf1_2020-02-22_23:34
    Create a readonly snapshot of '/btrfs/@test1' in '/btrfs/snps/@snp_ro_@test1_pf1_2020-02-22_23:34'
    btrfs subvolume snapshot -r /btrfs/@test2 /btrfs/snps/@snp_ro_@test2_pf1_2020-02-22_23:34
    Create a readonly snapshot of '/btrfs/@test2' in '/btrfs/snps/@snp_ro_@test2_pf1_2020-02-22_23:34'

    # ./backup.sh doSnapshot @test1
    btrfs subvolume snapshot -r /btrfs/@test1 /btrfs/snps/@snp_ro_@test1_pf1_2020-02-22_23:37
    Create a readonly snapshot of '/btrfs/@test1' in '/btrfs/snps/@snp_ro_@test1_pf1_2020-02-22_23:37'

### SEND CREATED SNAPSHOTS TO EXTERNAL BTRFS STORAGE

    # ./backup.sh sendLocalAll
    subvolume: @test1 snapshots: 2
    snapshot /btrfs/snps/@snp_ro_@test1_pf1_2020-02-22_23:34
    parent:/btrfs/snps/@snp_ro_@test1_pf2_2020-02-22_23:17 snapshotPath:/btrfs/snps/@snp_ro_@test1_pf1_2020-02-22_23:34
    bash -c btrfs send -p "/btrfs/snps/@snp_ro_@test1_pf2_2020-02-22_23:17" "/btrfs/snps/@snp_ro_@test1_pf1_2020-02-22_23:34" | btrfs receive "/btrfsbackup/kista/"
    At subvol /btrfs/snps/@snp_ro_@test1_pf1_2020-02-22_23:34
    At snapshot @snp_ro_@test1_pf1_2020-02-22_23:34
    snapshot /btrfs/snps/@snp_ro_@test1_pf1_2020-02-22_23:37
    parent:/btrfs/snps/@snp_ro_@test1_pf1_2020-02-22_23:34 snapshotPath:/btrfs/snps/@snp_ro_@test1_pf1_2020-02-22_23:37
    bash -c btrfs send -p "/btrfs/snps/@snp_ro_@test1_pf1_2020-02-22_23:34" "/btrfs/snps/@snp_ro_@test1_pf1_2020-02-22_23:37" | btrfs receive "/btrfsbackup/kista/"
    At subvol /btrfs/snps/@snp_ro_@test1_pf1_2020-02-22_23:37
    At snapshot @snp_ro_@test1_pf1_2020-02-22_23:37
    subvolume: @test2 snapshots: 1
    snapshot /btrfs/snps/@snp_ro_@test2_pf1_2020-02-22_23:34
    parent:/btrfs/snps/@snp_ro_@test2_pf1_2020-02-22_23:04 snapshotPath:/btrfs/snps/@snp_ro_@test2_pf1_2020-02-22_23:34
    bash -c btrfs send -p "/btrfs/snps/@snp_ro_@test2_pf1_2020-02-22_23:04" "/btrfs/snps/@snp_ro_@test2_pf1_2020-02-22_23:34" | btrfs receive "/btrfsbackup/kista/"
    At subvol /btrfs/snps/@snp_ro_@test2_pf1_2020-02-22_23:34
    At snapshot @snp_ro_@test2_pf1_2020-02-22_23:34

### DELETE (transfered) SNAPSHOTS FROM COMPUTER

    # ./backup.sh deleteTransferedAll
    subvolume: @test1 snapshots:2
    snapshot /btrfs/snps/@snp_ro_@test1_pf2_2020-02-22_23:17
    btrfs subvolume delete /btrfs/snps/@snp_ro_@test1_pf2_2020-02-22_23:17
    Delete subvolume (no-commit): '/btrfs/snps/@snp_ro_@test1_pf2_2020-02-22_23:17'
    snapshot /btrfs/snps/@snp_ro_@test1_pf1_2020-02-22_23:34
    btrfs subvolume delete /btrfs/snps/@snp_ro_@test1_pf1_2020-02-22_23:34
    Delete subvolume (no-commit): '/btrfs/snps/@snp_ro_@test1_pf1_2020-02-22_23:34'
    subvolume: @test2 snapshots:1
    snapshot /btrfs/snps/@snp_ro_@test2_pf1_2020-02-22_23:04
    btrfs subvolume delete /btrfs/snps/@snp_ro_@test2_pf1_2020-02-22_23:04
    Delete subvolume (no-commit): '/btrfs/snps/@snp_ro_@test2_pf1_2020-02-22_23:04'
