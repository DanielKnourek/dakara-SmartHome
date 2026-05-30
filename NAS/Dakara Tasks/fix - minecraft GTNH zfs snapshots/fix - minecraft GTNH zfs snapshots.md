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


## problem
Snapshots created include backups server folder which consist of useless zip of world ~T-12h
- need to create dataset from backups folder
- take only replication tasks for minecraft-gthn dataset and exclude backups dataset
- then try to replicate manually history for the new dataset


### create dataset in sub-folder
```shell
cd /mnt/ssd-data1/minecraft-gtnh/FeedTheBeast

sudo mv backups/ backups_tmp/

# from gem with love
sudo zfs create ssd-data1/minecraft-gtnh/backups

# correct subfolder mountpoint
sudo zfs set mountpoint=/ssd-data1/minecraft-gtnh/FeedTheBeast/backups ssd-data1/minecraft-gtnh/backups

# move back backups into new dataset
sudo cp -r backups_tmp/* backups/
```


## preparing Target dataset
```shell
# check what is included
sudo zfs list -r HomeArchive/backup/games
sudo zfs list -t snapshot HomeArchive/backup/games/minecraft-gtnh

# rename old backups with snapshots
sudo zfs rename HomeArchive/backup/games HomeArchive/backup/games-legacy

sudo zfs list -t snapshot HomeArchive/backup/games-legacy/minecraft-gtnh
```

#### output, existing snapshots
```bash
sudo zfs list -t snapshot HomeArchive/backup/games-legacy/minecraft-gtnh
[sudo] password for lantean: 
NAME                                                                                      USED  AVAIL  REFER  MOUNTPOINT
HomeArchive/backup/games-legacy/minecraft-gtnh@manual-2025-05-27_19-46                    959M      -  1.86G  -
HomeArchive/backup/games-legacy/minecraft-gtnh@manual-2025-05-29_21-29                   1.33G      -  2.26G  -
HomeArchive/backup/games-legacy/minecraft-gtnh@manual-2025-06-01_15-29                   2.74G      -  3.76G  -
HomeArchive/backup/games-legacy/minecraft-gtnh@manual-2025-06-09_04-10                   3.05G      -  4.17G  -
HomeArchive/backup/games-legacy/minecraft-gtnh@manual-2025-06-18_23-19-entering-lv-base  3.79G      -  4.91G  -
HomeArchive/backup/games-legacy/minecraft-gtnh@manual-2025-06-24_18-32-revert-backup     5.89G      -  6.87G  -
HomeArchive/backup/games-legacy/minecraft-gtnh@manual-2025-06-28_02-01                   10.8G      -  11.6G  -
HomeArchive/backup/games-legacy/minecraft-gtnh@manual-2025-07-03_23-54-fireindaHaus      13.1G      -  13.9G  -
HomeArchive/backup/games-legacy/minecraft-gtnh@auto-2025-07-09_06-00                     13.4G      -  15.3G  -
HomeArchive/backup/games-legacy/minecraft-gtnh@auto-2025-07-11_06-00                     8.98G      -  12.2G  -
HomeArchive/backup/games-legacy/minecraft-gtnh@auto-2025-07-12_06-00                     13.4G      -  16.7G  -
HomeArchive/backup/games-legacy/minecraft-gtnh@auto-2025-07-13_06-00                     13.8G      -  17.1G  -
HomeArchive/backup/games-legacy/minecraft-gtnh@auto-2025-07-14_06-00                     13.8G      -  17.1G  -
HomeArchive/backup/games-legacy/minecraft-gtnh@auto-2025-07-15_06-00                     13.8G      -  17.1G  -
HomeArchive/backup/games-legacy/minecraft-gtnh@auto-2025-07-16_06-00                     14.0G      -  17.4G  -
HomeArchive/backup/games-legacy/minecraft-gtnh@auto-2025-07-17_06-00                     14.3G      -  17.7G  -
HomeArchive/backup/games-legacy/minecraft-gtnh@auto-2025-07-18_06-00                     14.4G      -  17.8G  -
HomeArchive/backup/games-legacy/minecraft-gtnh@auto-2025-07-19_06-00                     10.8G      -  17.8G  -
HomeArchive/backup/games-legacy/minecraft-gtnh@auto-2025-07-20_06-00                     26.6M      -  17.8G  -
HomeArchive/backup/games-legacy/minecraft-gtnh@auto-2025-07-21_06-00                     3.63G      -  17.8G  -
HomeArchive/backup/games-legacy/minecraft-gtnh@auto-2025-07-22_06-00                     14.4G      -  17.8G  -
HomeArchive/backup/games-legacy/minecraft-gtnh@auto-2025-07-23_06-00                     6.04G      -  17.8G  -
HomeArchive/backup/games-legacy/minecraft-gtnh@auto-2025-07-24_06-00                     1.25G      -  16.6G  -
HomeArchive/backup/games-legacy/minecraft-gtnh@auto-2025-07-25_06-00                     22.5M      -  16.6G  -
HomeArchive/backup/games-legacy/minecraft-gtnh@auto-2025-07-26_06-00                     1.22G      -  16.6G  -
HomeArchive/backup/games-legacy/minecraft-gtnh@auto-2025-07-27_06-00                     8.44G      -  16.7G  -
HomeArchive/backup/games-legacy/minecraft-gtnh@auto-2025-07-28_06-00                     6.75M      -  16.9G  -
HomeArchive/backup/games-legacy/minecraft-gtnh@auto-2025-07-29_06-00                     6.71M      -  16.9G  -
HomeArchive/backup/games-legacy/minecraft-gtnh@auto-2025-07-30_06-00                     6.74M      -  16.9G  -
HomeArchive/backup/games-legacy/minecraft-gtnh@auto-2025-07-31_06-00                     11.1M      -  17.0G  -
HomeArchive/backup/games-legacy/minecraft-gtnh@auto-2025-08-01_06-00                     11.0M      -  17.0G  -
HomeArchive/backup/games-legacy/minecraft-gtnh@auto-2025-08-02_06-00                     11.4M      -  17.0G  -
HomeArchive/backup/games-legacy/minecraft-gtnh@auto-2025-08-03_06-00                     6.19G      -  17.0G  -
HomeArchive/backup/games-legacy/minecraft-gtnh@auto-2025-08-04_06-00                     26.4M      -  17.0G  -
HomeArchive/backup/games-legacy/minecraft-gtnh@auto-2025-08-05_06-00                     12.3M      -  17.0G  -
HomeArchive/backup/games-legacy/minecraft-gtnh@auto-2025-08-06_06-00                     10.3M      -  17.0G  -
HomeArchive/backup/games-legacy/minecraft-gtnh@auto-2025-08-07_06-00                     3.72G      -  17.0G  -
HomeArchive/backup/games-legacy/minecraft-gtnh@auto-2025-08-08_06-00                     9.89G      -  17.0G  -
HomeArchive/backup/games-legacy/minecraft-gtnh@auto-2025-08-09_06-00                     9.89G      -  17.0G  -
HomeArchive/backup/games-legacy/minecraft-gtnh@auto-2025-08-10_06-00                     14.8G      -  17.0G  -
HomeArchive/backup/games-legacy/minecraft-gtnh@auto-2025-08-11_06-00                     12.4G      -  17.1G  -
HomeArchive/backup/games-legacy/minecraft-gtnh@auto-2025-08-12_06-00                     64.5M      -  17.1G  -
HomeArchive/backup/games-legacy/minecraft-gtnh@auto-2025-08-13_06-00                        0B      -  17.2G  -

```

```shell
sudo zfs list -t snapshot HomeArchive/backup/game-backup/minecraft-gtnh
NAME                                                                    USED  AVAIL  REFER  MOUNTPOINT
HomeArchive/backup/game-backup/minecraft-gtnh@auto-2025-07-04_06-00    10.0G      -  13.9G  -
HomeArchive/backup/game-backup/minecraft-gtnh@auto-2025-07-05_06-00    5.00G      -  13.9G  -
HomeArchive/backup/game-backup/minecraft-gtnh@auto-2025-07-06_06-00    7.00G      -  13.9G  -
HomeArchive/backup/game-backup/minecraft-gtnh@auto-2025-07-07_06-00    12.2G      -  14.2G  -
HomeArchive/backup/game-backup/minecraft-gtnh@auto-2025-07-08_06-00    12.3G      -  14.3G  -
HomeArchive/backup/game-backup/minecraft-gtnh@auto-2025-07-09_06-00    13.3G      -  15.3G  -
HomeArchive/backup/game-backup/minecraft-gtnh@manual-2025-07-11_03-00  8.09M      -  10.0G  -
HomeArchive/backup/game-backup/minecraft-gtnh@manual-2025-07-11_03-09     0B      -  10.0G  -
```
### testing
testing copy of world copy using rsync from hiddnes snapshot folder
```shell
#sudo zfs snapshot pool/dataset@auto-$(date +'%Y-%m-%d_%H-%M')

# copy oldest snapshot to test folder
sudo rsync -avh --delete --exclude='backups' /mnt/HomeArchive/backup/games-legacy/minecraft-gtnh/.zfs/snapshot/manual-2025-05-27_19-46/FeedTheBeast /mnt/HomeArchive/backup/games-test/


# copy 2nd oldest snapshot to test folder
sudo rsync -avh --delete --exclude='backups' /mnt/HomeArchive/backup/games-legacy/minecraft-gtnh/.zfs/snapshot/manual-2025-05-29_21-29/FeedTheBeast /mnt/HomeArchive/backup/games-test/
```

### Result
370GiB + 77GiB = 14GiB 
433 saved, 31x compression

![[Pasted image 20250816183316.png]]
+
![[Pasted image 20250816183343.png]]
=
![[Pasted image 20250816183400.png]]



- ## script   
	![[recreate_zfs_chain.sh]]
- ## input data
	![[snapshot_list.txt]]