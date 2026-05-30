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
---

## Requirements

- [https://truecharts.org/manual/SCALE/guides/getting-started](https://truecharts.org/manual/SCALE/guides/getting-started)
- TrueCharts catalog - premium
- TrueNAS version TrueNAS-SCALE-23.10.2
- app-pool setup
- lldap service - [[write Docs - lldap|write Docs - lldap]]


## Installation

## 1. creating app-pools
- HomeArchive
	- root:root 755
- HomeArchive/nextcloud
    - nextcloud user data folder
    - apps:apps 770
- HomeArchive/HomeArchiveData
    - apps:apps 770
- HomeArchive/HomeArchiveData/Downloads
    - torrent and other dowload folder
    - apps:apps 770
- HomeArchive/HomeArchiveData/Media
    - complete archive of all shared data
    - apps:apps 770
- HomeArchive/HomeArchiveData/Sdilene
    - extra share folder
    - apps:apps 770
- ssd-data0/app-data/Nextcloud
	- skeleton (default) folder
	- apps:apps 770

```sh
sudo zfs create \
-o acltype=posixacl \
-o xattr=sa \
-o atime=off \
-o compression=lz4 \
"ssd-data0/app-data/nextcloud"

sudo zfs create \
-o acltype=posixacl \
-o xattr=sa \
-o atime=off \
-o compression=lz4 \
"ssd-data0/app-data/nextcloud/app-data"

sudo zfs create \
-o acltype=posixacl \
-o xattr=sa \
-o atime=off \
-o compression=lz4 \
"ssd-data0/app-data/nextcloud/postgres"

sudo install -d -m 776 -o apps -g apps \
  /mnt/ssd-data0/app-data/nextcloud
  
sudo install -d -m 777 -o 33 -g 33 \
  /mnt/ssd-data0/app-data/nextcloud/app-data \
  /mnt/HomeArchive/nextcloud

# TODO: find out why cannot use apps
sudo chown -R 33:33 /mnt/HomeArchive/nextcloud
  
sudo install -d -m 776 -o 999 -g 999 \
  /mnt/ssd-data0/app-data/nextcloud/postgres
```

## 2. nextcloud

> [!tip]- Picture reference
> - [ ] Todo add image
> ![[noimage.png]]

> [!info]- Steps
> - Apps → Discover Apps → Application Name (nextcloud) → Install
>
> > [!note] Values
> >
| | |
| ---- | ---- |
| Application Name | nextcloud (default) |
| Version                       | 2.1.22                                  |
| App Configuration →           |                                            |
| Initial Admin User            | asuran                                     |
| Initial Admin Password        | "op://Private/nextcloud admin/password"    |
| APT Packages          | `ffmpeg`                                         |
| Tesseract Language Codes         | `ces`                                         |
| Imaginary Enabled                  | YES          |
| Host                  | `192.168.0.21 archive.dakara.stream`          |
| Redis Password                  | "op://Private/nextcloud admin/db password"          |
| Database Password                  | "op://Private/nextcloud admin/db password"          |
| PHP Upload Limit (in GB)                  | `20`          |
| Network Configuration →     |                                            |
| Port Bind Mode                  | Publish port on the host for external access          |
| Port Number                  | `30027`          |
| Storage Configuration →     |                                            |
| - Nextcloud AppData Storage →          |    (HTML, Custom Themes, Apps, etc.)          |
| Type of Storage               | Host Path                                  |
| Host Path                     | /mnt/ssd-data0/app-data/nextcloud/app-data   |
| - Nextcloud User Data Storage →        |                                            |
| Type of Storage               | Host Path                                  |
| Host Path                     | /mnt/HomeArchive/nextcloud   |
| - Nextcloud Postgres Data Storage →        |                                            |
| Type of Storage               | Host Path                                  |
| Host Path                     | /mnt/ssd-data0/app-data/nextcloud/postgres   |
| Automatic Permissions | YES |
| - Additional App Storage →    |                                            |
| 1. Type of Storage            | Host Path                                  |
| 1. Mount Path                 | /mnt/HomeArchiveData/Media                 |
| 1. Host Path                  | /mnt/HomeArchive/HomeArchiveData/Media     |
| 2. Type of Storage            | Host Path                                  |
| 2. Mount Path                 | /mnt/HomeArchiveData/Sdilene               |
| 2. Host Path                  | /mnt/HomeArchive/HomeArchiveData/Sdilene   |
| 3. Type of Storage            | Host Path                                  |
| 3. Mount Path                 | /mnt/HomeArchiveData/Downloads             |
| 3. Host Path                  | /mnt/HomeArchive/HomeArchiveData/Downloads |
```yaml
# nextcloud labels
# ...
networks:
  proxy:
    external: True
services:
  nextcloud:
    networks:
      - default
      - proxy
    labels:
      traefik.enable: 'true'
      traefik.docker.network: "proxy"
      traefik.http.routers.nextcloud.rule: Host(`archive.dakara.stream`)
      traefik.http.services.nextcloud.loadbalancer.server.port: '80'
# ...
```

**result compose file:**
![[nextcloud-deployment.yaml]]

- make sure that `nextcloud-deployment.yaml` file exists and has correct values
```sh
sudo touch /mnt/ssd-data0/app-data/nextcloud/deployment.yaml
sudo chmod 660 /mnt/ssd-data0/app-data/nextcloud/deployment.yaml

# lazy person snippet
sudo vim /mnt/ssd-data0/app-data/nextcloud/deployment.yaml

# and INSTALL
sudo ~/deploy_app.py nextcloud --file /mnt/ssd-data0/app-data/nextcloud/deployment.yaml --icon https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/nextcloud.png
```




> [!attention]
> ended here, continue from here!


## 3. Nextcloud config

#### 3.1. Enable Apps

> [!info]- Steps
> - log in as administrator (asuran)
> - Menu → (+) Apps → Enable Apps
> 	- [https://archive.dakara.stream/settings/apps/featured](https://archive.dakara.stream/settings/apps/featured)
> 
> > [!note] Apps
> > 
| Name | installed version | App link |
| --- | --- | --- |
| LDAP user and group backend | 1.19.0 | [settings/apps/featured/user_ldap](https://archive.dakara.stream/settings/apps/featured/user_ldap) |
| External storage support | 1.20.0 | [settings/apps/featured/files_external](https://archive.dakara.stream/settings/apps/featured/files_external) |
| Dashboard → Welcome | 1.1.0 | [settings/apps/dashboard/welcome](https://archive.dakara.stream/settings/apps/dashboard/welcome) |
| Memories | 7.2.0 | [settings/apps/multimedia/memories](https://archive.dakara.stream/settings/apps/multimedia/memories) |
| Preview Generator | 5.5.0 | [settings/apps/multimedia/previewgenerator](https://archive.dakara.stream/settings/apps/multimedia/previewgenerator) |
| Recognize  | 6.1.1 | [settings/apps/enabled/recognize](https://archive.dakara.stream/settings/apps/enabled/recognize) |
| Whiteboard   | 1.5.2 | [settings/apps/featured/whiteboard](https://archive.dakara.stream/settings/apps/featured/whiteboard) |
| Archive Manager    | 1.2.8 | [settings/apps/files/files_archive](https://archive.dakara.stream/settings/apps/files/files_archive) |
| Zipper    | 2.2.0 | [settings/apps/files/files_zip](https://archive.dakara.stream/settings/apps/files/files_zip) |

#### 3.2. App configuration - LDAP/AD integration
- Menu → Administration settings → LDAP/AD integration
    - [https://archive.dakara.stream/settings/admin/ldap](https://archive.dakara.stream/settings/admin/ldap)
    - [https://docs.nextcloud.com/server/latest/admin_manual/configuration_user/user_auth_ldap.html](https://docs.nextcloud.com/server/latest/admin_manual/configuration_user/user_auth_ldap.html)


##### 3.2.1 LDAP/AD integration → Server

> [!tip]- Picture reference
> ![[conf-app-nextcloud-lldap-1.png]]

> [!info]- Steps
>    - Test Base DN button     
 >	→ Configuration OK  
 >	→ 18 entries available within the provided Base DN  
 >	
> > [!note] Values
> >
| | |
| --- | --- |
| Host | `ldap://192.168.0.21` |
| Port | `3890` |
| User DN | `uid=nextcloud_helper,OU=people,DC=knourek,DC=com` |
| Password | `"op://Private/lldap nextcloud_helper/password"` |
| Base DN | `DC=knourek,DC=com` |

##### 3.2.2 LDAP/AD integration → Expert

> [!info]- Steps
>    - change default internal username from ldap uuid to uid (username)
 >	
> > [!note] Values
> >
| | |
| --- | --- |
| Internal Username Attribute | uid |

##### 3.2.3 LDAP/AD integration → Users

> [!tip]- Picture reference
> ![[conf-app-nextcloud-lldap-2.png]]

> [!info]- Steps
 > - allowing only users with nextcloud_users group in lldap
 > - Verify settings and count users  
>        → 6 users found  
 >	
> > [!note] Values
> > - Edit LDAP Query 
> > ```
> > (
> > &(objectclass=person)
> > (memberOf=cn=nextcloud_users,ou=groups,DC=knourek,DC=com)
> > )
> > ```

##### 3.2.4 LDAP/AD integration → Login Attributes

> [!tip]- Picture reference
> ![[conf-app-nextcloud-lldap-3.png]]

> [!info]- Steps
>    - allowing only users with nextcloud_users group in lldap
>    - Verify settings - Test Loginname: daniel  
>        → User found and settings verified.
>    - Verify settings - Test Loginname: fakename  
>        → User not found.
>    - Verify settings - Test Loginname: [[daniel@knourek.com]]  
>        → User found and settings verified.
 >	
> > [!note] Values
> >
| | |
| --- | --- |
| LDAP/AD Username | Yes |
| LDAP/AD Email Address | Yes |
> LDAP Filter 
> > ```
> > (&( &(objectclass=person) (memberOf=cn=nextcloud_users,ou=groups,DC=knourek,DC=com) )(|(uid=%uid)(|(mailPrimaryAddress=%uid)(mail=%uid))))
> > ```

##### 3.2.5 LDAP/AD integration → Groups

> [!tip]- Picture reference
> ![[conf-app-nextcloud-lldap-4.png]]

> [!info]- Steps
>    - Verify settings and count the groups     
 >	→ Configuration OK  
 >	→ 2 groups found  
 >	
> > [!note] Values
> >
| | |
| --- | --- |
| Only these object classes | groupOfUniqueNames |
| Only from these groups | family, guests |
> LDAP Filter 
> > ```
> > (&(|(objectclass=groupOfUniqueNames))(|(cn=family)(cn=guests)))
> > ```

#### 3.3. App configuration - External storage
- Menu → Administration settings → External storage
    - [https://archive.dakara.stream/settings/admin/externalstorages](https://archive.dakara.stream/settings/admin/externalstorages)
    
> [!tip]- Picture reference
> ![[conf-app-nextcloud-external-storage.png]]

> [!info]- Steps
> - Menu → Administration settings → External storage
>
> > [!note] Values
> >
| Folder name | External storage | Authentication | Configuration                  | Available for |
| ----------- | ---------------- | -------------- | ------------------------------ | ------------- |
| Sdilene     | Local            | None           | /mnt/HomeArchiveData/Sdilene   | family, admin |
| Media       | Local            | None           | /mnt/HomeArchiveData/Media     | All users     |
| Stažené     | Local            | None           | /mnt/HomeArchiveData/Downloads | All users     |

#### 3.4. App configuration - Memories
 - Menu → Administration settings → Memories
    - [https://archive.dakara.stream/settings/admin/memories](https://archive.dakara.stream/settings/admin/memories)

##### 3.4.1. exclude non-media folders

> [!info]- Steps
> - Open truenas cli
> - System Settings → shell
> 	- https://admin.dakara.stream/ui/system/shell
>
> > [!note] Commands
> >    ```shell
> >    touch /mnt/HomeArchive/HomeArchiveData/Downloads/.nomemories
> >    touch /mnt/HomeArchive/HomeArchiveData/Media/Filmy🎞️/.nomemories
> >    touch /mnt/HomeArchive/HomeArchiveData/Media/Pořady📺/.nomemories
> >    ```

##### 3.4.1. Index & geocoding 
- [https://memories.gallery/config/](https://memories.gallery/config/)
- Open nextcloud cli

> [!info]- Steps
> - Open nextcloud cli
> - TrueNAS Scale → Apps → Installed Applications
> - Nextcloud → Workloads → Shell
>
>
> > [!note] Commands
> >    ```shell
> >    php occ memories:places-setup
> >    # takes about ~2-4 mins
> >    
> >    php occ memories:index --path "/Media"	
> >    ```


#### 3.5. General configuration - New user
- add skeleton dataset
```sh
sudo zfs create \
-o acltype=posixacl \
-o xattr=sa \
-o atime=off \
-o compression=lz4 \
"ssd-data0/app-data/nextcloud/skeleton"

sudo install -d -m 776 -o apps -g apps \
  /mnt/ssd-data0/app-data/nextcloud/skeleton
```
- add mount to the container
```yaml
# ...
services:
  nextcloud:
# ...
      - bind:
          create_host_path: False
          propagation: rprivate
        read_only: False
        source: /mnt/ssd-data0/app-data/nextcloud/skeleton
        target: /mnt/skeleton
        type: bind
# ...
```
- Open nextcloud cli

> [!info]- Steps
> - TrueNAS Scale → Apps → Installed Applications
> - Nextcloud → Workloads → Shell
>
> > [!note] Commands
> >    ```shell
> >    # configure default nextcloud language
> >    php occ config:system:set default_language --value="cs"
> >    php occ config:system:set default_locale --value="cs_CZ"
> >    php occ config:system:get default_language
> >	
> >    # set skeleton directory, default files for new users
> >    php occ config:system:set skeletondirectory --value="/mnt/skeleton"
> >    ```

```sh
# in a nextcloud container

# fix reverse proxy to correct protocol
php occ config:system:set overwriteprotocol --value=https
php occ config:system:set overwrite.cli.url --value="https://archive.dakara.stream"

php occ config:system:set maintenance_window_start --value="4" --type=integer
```

#### 3.6. App configuration - Whiteboard
- https://archive.dakara.stream/settings/admin/whiteboard
- https://github.com/nextcloud/whiteboard?tab=readme-ov-file#websocket-server-for-real-time-collaboration
```sh
# in a nextcloud container

# set values
php occ config:app:set whiteboard collabBackendUrl --value="https://whiteboard.dakara.stream"
php occ config:app:set whiteboard jwt_secret_key --value="op://Private/nextcloud admin/Whiteboard JWT"
```

- add this service to deployment.yaml
```yaml
nextcloud-whiteboard-server:
    networks:
      - default
      - proxy
    labels:
      traefik.enable: 'true'
      traefik.docker.network: "proxy"
      traefik.http.routers.nextcloud-whiteboard.rule: Host(`whiteboard.dakara.stream`)
      traefik.http.services.nextcloud-whiteboard.loadbalancer.server.port: '3002'
    image: ghcr.io/nextcloud-releases/whiteboard:stable
    environment:
      NEXTCLOUD_URL: https://archive.dakara.stream
      JWT_SECRET_KEY: "op://Private/nextcloud admin/Whiteboard JWT"
```

#### 3.6. App configuration - Archive manager
- https://archive.dakara.stream/settings/apps/files/files_archive
```sh
# in a nextcloud container

# install RAR support
pecl install rar
```

---
---
## used commands
```sh
# nuke unvatned files
sudo rm -fr /mnt/HomeArchive/nextcloud/.htaccess
sudo rm -fr /mnt/HomeArchive/nextcloud/asuran
sudo rm -fr /mnt/HomeArchive/nextcloud/index.html
sudo rm -fr /mnt/HomeArchive/nextcloud/nextcloud.log

# reset content again
sudo rm -fr /mnt/ssd-data0/app-data/nextcloud/app-data/*
sudo rm -fr /mnt/ssd-data0/app-data/nextcloud/app-data/.*

sudo rm -fr /mnt/ssd-data0/app-data/nextcloud/postgres/*
sudo rm -fr /mnt/ssd-data0/app-data/nextcloud/app-postgres/.*
```

```sh
# scanning all files again

# my exec into contianer script
ls ~/exec-into-container.sh || wget -qO ~/exec-into-container.sh https://raw.githubusercontent.com/DanielKnourek/IT-support/main/Tools/dockerSelectContainer/exec-into-container.sh && sudo bash ~/exec-into-container.sh

# > ix-nextcloud-nextcloud-1

php occ files:scan --all
```
- clearing some warning
```sh
# inside nextcloud container

# Database missing indices 
php occ db:add-missing-indices

# Mimetype migrations available
php occ maintenance:repair --include-expensive

php occ config:system:set maintenance_window_start --value="4" --type=integer

php occ config:system:set default_phone_region --value="CZ"
```