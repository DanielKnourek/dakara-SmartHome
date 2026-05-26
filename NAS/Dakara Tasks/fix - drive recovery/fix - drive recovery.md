---
created: 2024-01-17T18:21
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
# lots ssd-data0 trying to recover data
it was unsuccessfull

but here are the resources
https://www.johndstech.com/security/backup-and-mount-disk-images-using-ddrescue/
https://www.diskinternals.com/partition-recovery/recover-gpt-partition/

https://www.system-rescue.org/

```sh
# mounitng NTFS drive to try extract img file to recover on
mkdir /mnt/backup
mount -t ntfs3 /dev/sdc1 /mnt/backup

# create raw image of drive to work on
ddrescue -n -v /dev/sdb /mnt/backup/sdb.img /mnt/backup/sdb.map

# testing tools, using systemRescue live CD
gdisk /mnt/backup/sdb.img
testdisk /mnt/backup/sdb.img

# prints raw data - test if there are any data at all
xxd /mnt/backup/sdb.img
xxd /dev/sdv | less
cmp -n 100M /dev/zero /dev/sdb
```

i found old gdisk gpt backup
```sh
# try it on drive image
gdisk /mnt/backup/sdb-image.img
r
l
/mnt/backup/data/backup_sdb_v1
p
w

kpartx -av /mnt/backup/sdb-image.img

# I needed zfs-tools
# https://www.system-rescue.org/scripts/build-zfs-srm/
build-zfs-srm

zdb -l /dev/mapper/loop1p3
# failed to unpack label 0
# failed to unpack label 1
# failed to unpack label 2
# failed to unpack label 3
# unsuccessfull

```

drive really died. I ran a test
```sh
smartctl -a /dev/sda
```

results working vs broken
![[test_sda.pl]]

![[test_sdb.pl]]



gemini’s Mad science on e-waste
```sh
ddrescue -v -R -n /dev/sdb /mnt/backup/sdb-reverse.img /mnt/backup/sdb-reverse.map
```