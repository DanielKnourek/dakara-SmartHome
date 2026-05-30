---"\rcreated": 2024-01-17T18:21
updated: 2024-01-17T18:42
tags:
  - task
status: Done
depends_on: []
dependency_completion: 100%
---
```meta-bind
INPUT[listSuggester(
	optionQuery(#task)
):depends_on]
```

```dataviewjs
const {update} = this.app.plugins.plugins["metaedit"].api;
const result = {result: {}};
await dv.view('_Assets/Scripts/dv-StatusCategoryUtils', result);
update('dependency_completion', `${result.result}%`, dv.current().file.path)
```

# Home NAS on TrueNAS scale

## Installation steps

0. Requirements
    - Install ISO TrueNAS-SCALE-22.02.3.iso
    - Smaller drive (old 40GB)
    - Live Gpadted install

1. Install/Upgrade

2. Select initial install device (40GB drive)

3. Password - root

4. Open UI and change settings
    1. DHCP off
    2. static IP 192.168.90.21
    3. hostname dakara
    4. add user lantean

5. Transfer installation to the SSD
    0. [Instructions](https://www.truenas.com/community/threads/truenas-scale-installation-on-partitioned-drive.93533/)
    1. enable SSH in the UI and log into shell as lantean login as root
    2. used commands

        ```BASH
        su root
        # password
        lsblk
        # sdb smaller current boot drive, sda larger empty drive
        sudo gdisk /dev/sdb
            b
            backup_sdb
            q
        sudo gdisk /dev/sda
            r
            l
            backup_sdb
            w
            y
        sudo zpool status boot-pool
        sudo zpool attach boot-pool sdb3 sda3 -f
        sudo zpool status boot-pool #resilvering
        dd if=/dev/sdb2 of=/dev/sda2 # ~5min, 512M
        dd if=/dev/sdb1 of=/dev/sda1
        sudo zpool offline boot-pool sdb3
        sudo zpool detach boot-pool sdb3
        sudo zpool status boot-pool

        sudo gdisk /dev/sda
            p
            n
            <enter> # part number
            <enter> # first sector
            <enter> # last sector (+185G if want to be specific on size)
            BF01 # type
            w
            y
        
        sudo gdisk /dev/sda
            x
            i
            4
            # Partition GUID code: 6A898CC3-1DD2-11B2-99A6-080020736631 (Solaris /usr & Mac ZFS)
            # Partition unique GUID: 57208DBD-12C7-4084-91A8-C42BABFB8790
            # First sector: 78163968 (at 37.3 GiB)
            # Last sector: 500118158 (at 238.5 GiB)
            # Partition size: 421954191 sectors (201.2 GiB)
            # Attribute flags: 0000000000000000
            # Partition name: 'Solaris /usr & Mac ZFS'

        ```

    3. shutdown
    4. remove small drive
    5. boot system
    6. used commands

        ```BASH
        zpool create -f ssd-data00 /dev/sda4
        # zpool create ssd-data0 gptid/d08b1137-4fa5-4749-bcfb-f3bd2c12eafc
        # zpool create ssd-data0 /dev/disk/by-partuuid/d08b1137-4fa5-4749-bcfb-f3bd2c12eafc
        zpool export ssd-data00
        ```

    7. Import ssd-data00 in UI
    8. mirror boot pool from UI on another EMPTY drive
    9. repat steps 2.5 - 6

6. Import data pools
    1. shutdown
    2. reconect drives
    3. boot and import pools - HomeArchive

7. create users
    1. u daniel 1001 1002
    2. g Family 1002
    3. u vaclav 1002 1002
    4. u vasek  1003 1002
    5. u blanka 1004 1002

8. Set-up SMB
    - service SMB on, auto start
    - share edit NetBios Name dakara



### System

- Name: Dakara

- domain name: local

- Users

    [passwords](https://start.1password.com/open/i?a=WEZ3U4R6AFHPXMGBNNR7PTHYDI&v=hylzluzkivpqm2op5jt6dyj6dy&i=5nagiefi4ikgu6h4j6sha4byeu&h=my.1password.com)

