

Copy files to NAS
```BASH
sudo rsync --ignore-existing -czraP -t --progress --log-file=/home/rsync.progress.log /mnt/e/_zaloha\ NAS/Mamča lantean@dakara:/mnt/HomeArchive/tmp/
sudo rsync --ignore-existing -czraP -t --progress --log-file=/home/rsync.progress.log /mnt/f/_zaloha\ NAS/Vašek/_* lantean@dakara:/mnt/HomeArchive/HomeArchiveData/Sdilene/Gdrive/Vašek/

# copy betwen two directories
sudo rsync --ignore-existing -craP -t --progress --log-file=/home/rsync.progress.log /mnt/f/_zaloha\ NAS/Vašek /mnt/d/Clouds/nextcloud_drivetransfer
```

restart SCALE UI
```BASH
sudo systemctl restart middlewared
``` 