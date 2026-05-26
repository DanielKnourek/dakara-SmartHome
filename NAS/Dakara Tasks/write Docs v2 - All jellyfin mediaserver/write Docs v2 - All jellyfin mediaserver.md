---
created: 2024-01-17T18:21
updated: 2024-01-17T18:42
tags:
  - task
status: Done
depends_on:
  - "[[Dakara Tasks/write Docs v2 - mDNS autodiscovery.md|write Docs v2 - mDNS autodiscovery]]"
dependency_completion: 0%
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
```dataviewjs
// 1. Get all tasks from the current page that are NOT completed
let tasks = dv.current().file.tasks.where(t => !t.completed);

// 2. Check if there are any tasks found
if (tasks.length > 0) {
    // Optional: Add a header so you know what this list is
    dv.header(3, "To Do");
    
    // 3. Render the list
    dv.taskList(tasks);
}
```

---
```dataviewjs
// 1. Get the current file's metadata directly from Obsidian's cache
// This avoids reading the raw text and avoids regex errors
const page = dv.current();
const file = app.vault.getAbstractFileByPath(page.file.path);
const cache = app.metadataCache.getFileCache(file);

// 2. Check if there are headings to display
if (cache && cache.headings) {
    
    // 3. Map the headings to a Markdown list with proper indentation
    const toc = cache.headings.map(h => {
        // Indent based on header level (H1 = 0 spaces, H2 = 2 spaces, etc.)
        const indent = "  ".repeat(h.level - 1);
        
        // Use the header text for the link
        const text = h.heading;
        
        // Return the formatted link
        return `${indent}- [[#${text}|${text}]]`;
    });

    // 4. Render the list
    dv.paragraph(toc.join('\n'));
} else {
    dv.paragraph("No headers found.");
}
```

---
setting up All-jellyfin-media-server with few adjustments. I will separate Jellyfin into standalone app. Just I can see it in truenas with ability to restart when needed. Media streming should work independent of media discovery and download.
### resouces
- https://github.com/Morzomb/All-jellyfin-media-server/
## Jellyfin installation
- prepare storage first, cache is separate dataset I can exclude it from backups
```sh
sudo zfs create \
-o acltype=posixacl \
-o xattr=sa \
-o atime=off \
-o compression=lz4 \
"ssd-data0/app-data/jellyfin"

sudo zfs create \
-o acltype=posixacl \
-o xattr=sa \
-o atime=off \
-o compression=lz4 \
"ssd-data0/app-data/jellyfin/cache"

sudo install -d -m 776 -o apps -g apps \
  /mnt/ssd-data0/app-data/jellyfin \
  /mnt/ssd-data0/app-data/jellyfin/config \
  /mnt/ssd-data0/app-data/jellyfin/cache
```

- I started with this compose file
  https://github.com/Morzomb/All-jellyfin-media-server/blob/Main/compose_files/VPN-Only/docker-compose-proton-vpn.yaml
	- [blob](https://github.com/Morzomb/All-jellyfin-media-server/blob/1f647cbcd25d616257b0f2e7b8522cd83f1f8d63/compose_files/VPN-Only/docker-compose-proton-vpn.yaml)
- then I cut out jellyfin only
- added traefik labels and network
```yml
# jellyfin labels
    labels:
      traefik.enable: 'true'
      traefik.docker.network: "proxy"
      traefik.http.routers.jellyfin.rule: "Host(`kino.dakara.stream`)"
      traefik.http.services.jellyfin.loadbalancer.server.port: 8096
```

```yml
networks:
  proxy:
    external: True
  jellyfin-addons:
    external: True
services:
  jellyfin:
    networks:
      - default
      - proxy
      - jellyfin-addons
```

- created addons-only network (probably wont be using this anyway)
```sh
sudo docker network create jellyfin-addons
# if traefik proxy is not yet defined I can also define it here or remove it if traefik is not used
```
- had to change all enviroment variables with `CTRL+R` with static values
- volumes mapped
```yaml
    volumes:
      - /mnt/ssd-data0/app-data/jellyfin/config:/config
      - /mnt/ssd-data0/app-data/jellyfin/cache:/cache
      - /mnt/HomeArchive/HomeArchiveData/Media:/data/media
      - /mnt/HomeArchive/HomeArchiveData/Downloads:/data/media_downloads
```

- and deploy app
```sh
sudo touch /mnt/ssd-data0/app-data/jellyfin/deployment.yaml
sudo chmod 660 /mnt/ssd-data0/app-data/jellyfin/deployment.yaml

# lazy person snippet
sudo vim /mnt/ssd-data0/app-data/jellyfin/deployment.yaml

# and INSTALL
sudo ~/deploy_app.py jellyfin --file /mnt/ssd-data0/app-data/jellyfin/deployment.yaml --icon https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/jellyfin.png
```
![[jellyfin-deployment.yaml]]

### Jellyfin setup
- welcome wizard
> [!info]- Steps
> - Open https://kino.dakara.stream/web/#/wizard/start
>
> > [!note] Values
> >
| | |
| ---- | ---- |
| Welcome to Jellyfin!  —> |  |
| Server name | Kino doma |
| language | Čeština |
| Tell us about yourself —> |  |
| Username | asuran |
| Password | "op://Private/Jellyfin admin/password" |
| Set up your media libraries —> |  |
| Filmy CZ → | |
| - Content type | Movies |
| - Display name | Filmy CZ |
| - Folders | /data/media/Filmy🎞️/Czech |
| - Preferred download language | Czech |
| - Country/Region | Czech Republic |
| - Metadata savers | Nfo |
| - Enable chapter image extraction | YES |
| Filmy EN → | |
| - Content type | Movies |
| - Display name | Filmy EN |
| - Folders | /data/media/Filmy🎞️/English |
| - Preferred download language | English |
| - Country/Region | Czech Republic |
| - Metadata savers | Nfo |
| - Enable chapter image extraction | YES |
| Pořady CZ → | |
| - Content type | Shows |
| - Display name | Pořady CZ |
| - Folders | /data/media/Pořady📺/Czech |
| - Preferred download language | Czech |
| - Country/Region | Czech Republic |
| - Metadata savers | Nfo |
| - Enable chapter image extraction | YES |
| Pořady EN → | |
| - Content type | Shows |
| - Display name | Pořady EN |
| - Folders | /data/media/Pořady📺/English |
| - Preferred download language | English |
| - Country/Region | Czech Republic |
| - Metadata savers | Nfo |
| - Enable chapter image extraction | YES |
| Hudba → | |
| - Content type | Music |
| - Display name | Hudba |
| - Folders | /data/media/Hudba🎶 |
| - Metadata savers | Nfo |
| Galerie → | |
| - Content type | Home Videos and Photos |
| - Display name | Galerie |
| - Folders | /data/media/Galerie🖼 |
| Preferred Metadata Language —> |  |
| Language | Czech |
| Country/Region | Czech Republic |
| Configure Remote Access —> |  |
| Allow remote connections | YES |

#### lldap integration
- https://kino.dakara.stream/web/#/dashboard/plugins
- install [LDAP Authentication plugin](https://kino.dakara.stream/web/#/dashboard/plugins/958aad6637844d2ab89aa7b6fab6e25c?name=LDAP%20Authentication)
- restart
> [!info]- Configure
> - Open plugin [settings](https://kino.dakara.stream/web/#/configurationpage?name=LDAP-Auth)
>
> > [!note] Values
> >
| | |
| ---- | ---- |
| LDAP Server | 192.168.0.21 |
| LDAP Port | 3890 |
| LDAP Bind User | `uid=jellyfin_helper,OU=people,DC=knourek,DC=com` |
| LDAP Bind User Password | `"op://Private/lldap jellyfin_helper/password"`     |
| BASE DN       | `DC=knourek,DC=com`    |
| LDAP Search Filter | `(&(objectclass=person)(memberOf=cn=jellyfin_user,ou=groups,DC=knourek,DC=com))` |
| LDAP Search Attributes* | `uid, cn, mail, displayName` |
| LDAP Uid Attribute* | `uid` |
| LDAP Username Attribute* | `cn` |
| LDAP Password Attribute* | `userPassword` |
| Administrators —>|  |
| LDAP Admin Base DN| `DC=knourek,DC=com` |
| LDAP Admin Filter| `(&(objectclass=person)(memberOf=cn=jellyfin_admin,ou=groups,DC=knourek,DC=com))` |
> > notes: 
> > - `*` These are default values  
> > - LDAP Server seems to require IP or url and doesnt work with internal docker hostname eg. `lldap` or `lldap.proxy`  

#### other plugins
- [ ] TODO add plugins: subtitles
- [ ] TODO: network streaming to TV
- [ ] TODO: GPU decoding
## Jellyfin-addons installation

- prepare storage first
```sh
sudo zfs create \
-o acltype=posixacl \
-o xattr=sa \
-o atime=off \
-o compression=lz4 \
"ssd-data0/app-data/jellyfin-addons"

sudo install -d -m 776 -o apps -g apps \
  /mnt/ssd-data0/app-data/jellyfin-addons
  
  
sudo install -d -m 776 -o apps -g apps \
  /mnt/HomeArchive/HomeArchiveData/Downloads/radarr \
  /mnt/HomeArchive/HomeArchiveData/Downloads/sonarr
  
```
- [x] TODO: change to jellyfin-plus → jellyfin-addons
- [ ] TODO: delete jellfin-plus dataset

### compose file for all addons
- this icnludes gluetun, qbittorrent, flaresolverr, prowlarr, jackett, sonarr, radarr, jellyseerr

> [!info]- Volume mounts
> |                  |                                                               |
> | ---------------- | ------------------------------------------------------------- |
> | gluetun --→      |                                                               |
> | ├ Host:          | `/mnt/ssd-data0/app-data/jellyfin-addons/gluetun`             |
> | └ Mount:         | `/tmp/gluetun`                                                |
> | qbittorrent --→  |                                                               |
> | ├ Host:          | `/mnt/ssd-data0/app-data/jellyfin-addons/configs/qbittorrent` |
> | └ Mount:         | `/config`                                                     |
> | ├ Host:          | `/mnt/HomeArchive/HomeArchiveData/Downloads`                  |
> | └ Mount:         | `/downloads`                                                  |
> | flaresolverr --→ |                                                               |
> | N/A              |                                                               |
> | prowlarr --→     |                                                               |
> | ├ Host:          | `/mnt/ssd-data0/app-data/jellyfin-addons/configs/prowlarr`    |
> | └ Mount:         | `/config`                                                     |
> | prowlarr --→     |                                                               |
> | ├ Host:          | `/mnt/ssd-data0/app-data/jellyfin-addons/configs/jackett`     |
> | └ Mount:         | `/config`                                                     |
> | sonarr --→       |                                                               |
> | ├ Host:          | `/mnt/ssd-data0/app-data/jellyfin-addons/configs/sonarr`      |
> | └ Mount:         | `/config`                                                     |
> | ├ Host:          | `/mnt/HomeArchive/HomeArchiveData/Downloads`                  |
> | └ Mount:         | `/downloads`                                                  |
> | ├ Host:          | `/mnt/HomeArchive/HomeArchiveData/Media`                      |
> | └ Mount:         | `/media`                                                      |
> | radarr --→       |                                                               |
> | ├ Host:          | `/mnt/ssd-data0/app-data/jellyfin-addons/configs/radarr`      |
> | └ Mount:         | `/config`                                                     |
> | ├ Host:          | `/mnt/HomeArchive/HomeArchiveData/Downloads`                  |
> | └ Mount:         | `/downloads`                                                  |
> | ├ Host:          | `/mnt/HomeArchive/HomeArchiveData/Media`                      |
> | └ Mount:         | `/media`                                                      |
> | jellyseerr --→   |                                                               |
> | ├ Host:          | `/mnt/ssd-data0/app-data/jellyfin-addons/configs/jellyseerr`  |
> | └ Mount:         | `/app/config`                                                 |

- add network for whole compose file
```yml
networks:
  proxy:
    external: True
  jellyfin-addons:
    external: True
```

- modify all other services to work with traefik
```yml
services:
  ...
# qbittorrent labels
  gluetun:
    labels:
      traefik.enable: 'true'
      traefik.docker.network: "proxy"
      traefik.http.routers.qbittorrent.rule: "Host(`torrent.dakara.stream`)"
      traefik.http.services.qbittorrent.loadbalancer.server.port: 8088
    networks:
      - default
      - proxy
      - jellyfin-addons
  ...
# prowlarr labels
  prowlarr:
    labels:
      traefik.enable: 'true'
      traefik.docker.network: "proxy"
      traefik.http.routers.prowlarr.rule: "Host(`prowlarr.dakara.stream`)"
      traefik.http.services.prowlarr.loadbalancer.server.port: 9696
    networks:
      - default
      - proxy
      - jellyfin-addons
  ...
# jackett labels
  jackett:
    labels:
      traefik.enable: 'true'
      traefik.docker.network: "proxy"
      traefik.http.routers.jackett.rule: "Host(`jackett.dakara.stream`)"
      traefik.http.services.jackett.loadbalancer.server.port: 9117
    networks:
      - default
      - proxy
      - jellyfin-addons
  ...
# sonarr labels
  sonarr:
    labels:
      traefik.enable: 'true'
      traefik.docker.network: "proxy"
      traefik.http.routers.sonarr.rule: "Host(`sonarr.dakara.stream`)"
      traefik.http.services.sonarr.loadbalancer.server.port: 8989
    networks:
      - default
      - proxy
      - jellyfin-addons
  ...
# radarr labels
  radarr:
    labels:
      traefik.enable: 'true'
      traefik.docker.network: "proxy"
      traefik.http.routers.radarr.rule: "Host(`radarr.dakara.stream`)"
      traefik.http.services.radarr.loadbalancer.server.port: 7878
    networks:
      - default
      - proxy
      - jellyfin-addons
  ...
# jellyseerr labels
  jellyseerr:
    labels:
      traefik.enable: 'true'
      traefik.docker.network: "proxy"
      traefik.http.routers.jellyseerr.rule: "Host(`program.dakara.stream`) || Host(`jellyseerr.dakara.stream`)"
      traefik.http.services.jellyseerr.loadbalancer.server.port: 5055
    networks:
      - default
      - proxy
      - jellyfin-addons
```
and deploy app
```sh
sudo touch /mnt/ssd-data0/app-data/jellyfin-addons/deployment.yaml
sudo chmod 660 /mnt/ssd-data0/app-data/jellyfin-addons/deployment.yaml

# lazy person snippet
sudo vim /mnt/ssd-data0/app-data/jellyfin-addons/deployment.yaml

# and INSTALL
sudo ~/deploy_app.py jellyfin-addons --file /mnt/ssd-data0/app-data/jellyfin-addons/deployment.yaml --icon https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/jellyseerr.png
```
![[jellyfin-addons-deployment.yaml]]

### Addons setup
#### QBitTorrent
 - find password in log
 - go to local ip http://admin.dakara.stream:8088/
	 - username: admin
	 - password: ${shell}
- set password `Tools –> Options –> WebUI –> Authentication`
	- username: lantean
	- password: `"op://Private/lldap lantean/password"`
- set Trusted proxies for traefik `Tools –> Options –> WebUI` 
  `–> Enable reverse proxy support`
	- Trusted proxies list: `172.0.0.0/8`
- disable security checks `Tools –> Options –> WebUI --> Security` 
	- Enable Cross-Site Request Forgery (CSRF) protection: FALSE
	- Enable Host header validation: FALSE
-  from here folowing guide [All-jellyfin-media-server#qbittorrent-1](https://github.com/Morzomb/All-jellyfin-media-server?tab=readme-ov-file#qbittorrent-1)
- configure category-based managment `Tools –> Options –> Dowloads --> Saving Management`
	- Default Torrent Management Mode: `Automatic`
	- When Torrent Category changed: `Relocate torrent`
	- When Default Save Path changed: `Relocate affected torrents`
	- When Category Save Path changed: `Relocate affected torrents`
	- Default Save Path: `/downloads`
	- SAVE
- configure categories `Left panel --> CATEGORIES --> All (right-click) --> Add Category`
	- Category: `radarr`
	- Save path: `/downloads/radarr`
	- Category: `sonarr`
	- Save path: `/downloads/sonarr`
	- Category: `manual`
	- Save path: `/downloads/manual`
- [ ] TODO: configure Reverse proxy headers and others
      https://github.com/qbittorrent/qBittorrent/wiki/Traefik-Reverse-Proxy-for-Web-UI

> Ip of VPN is **109.164**.**48.239**
#### Jackett
- welcome wizard
> [!info]- Steps
> - Open https://jackett.dakara.stream/UI/Dashboard
>
> > [!note] Values
> >
| | |
| ---- | ---- |
| Admin password | "op://Private/Jellyfin admin/password" |

#### Radarr
- welcome wizard
> [!info]- Steps
> - Open https://radarr.dakara.stream/
>
> > [!note] Values
> >
| | |
| ---- | ---- |
| Authentication Method | Forms (Login Page) |
| Authentication Required | Enabled |
| Username | asuran |
| Password | "op://Private/Jellyfin admin/password" |

- Add Root Folder `Settings --> Media Managment --> Root Folders`
	  https://radarr.dakara.stream/settings/mediamanagement
	- Path: `/media/Filmy🎞️/Czech`
	- Path: `/media/Filmy🎞️/English`
- Add qBitTorrent `Settings –> Download Clients`
	  https://radarr.dakara.stream/settings/downloadclients
- Add (+) → qBitTorrent
	- Name: `qBittorrent`
	- Host: `gluetun`
	- Port: `8088`
	- Use SSL: FALSE
	- Username: `lantean`
	- Password: `"op://Private/lldap lantean/password"`
	- Category: `radarr`
-  [ ] TODO: change target Host from: `qluetun` to `qbittorrent`
	- container needs to have additional `proxy` and `jellyfin_addons` networks
- Jackett Indexer `Settings --> Indexers`
	  https://radarr.dakara.stream/settings/indexers
- Add (+) → Torznab
	- Name: `Jackett`
	- [ ] I dont understand this, evaluate for future use - something something FlareSolverr

#### Sonarr
- welcome wizard
> [!info]- Steps
> - Open https://sonarr.dakara.stream/
>
> > [!note] Values
> >
| | |
| ---- | ---- |
| Authentication Method | Forms (Login Page) |
| Authentication Required | Enabled |
| Username | asuran |
| Password | "op://Private/Jellyfin admin/password" |

- Add Root Folder `Settings --> Media Managment --> Root Folders`
	  https://sonarr.dakara.stream/settings/mediamanagement
	- Path: `/media/Pořady📺/Czech/`
	- Path: `/media/Pořady📺/English/`
- Add qBitTorrent `Settings –> Download Clients`
	  https://sonarr.dakara.stream/settings/downloadclients
- Add (+) → qBitTorrent
	- Name: `qBittorrent`
	- Host: `gluetun`
	- Port: `8088`
	- Use SSL: FALSE
	- Username: `lantean`
	- Password: `"op://Private/lldap lantean/password"`
	- Category: `sonarr`
-  [ ] TODO: change target Host from: `qluetun` to `qbittorrent`
	- container needs to have additional `proxy` and `jellyfin_addons` networks
- Jackett Indexer `Settings --> Indexers`
	  https://radarr.dakara.stream/settings/indexers
- Add (+) → Torznab
	- Name: `Jackett`
	- URL: `https://jackett.dakara.stream/api/v2.0/indexers/1337x/results/torznab/`
	- URL (direct): `http://jackett:9117/api/v2.0/indexers/1337x/results/torznab/`
	- API KEY: `jackett api key`
	- Seed Ratio: `1.5`
	- [ ] I dont understand this, evaluate for future use - something something FlareSolverr

#### Prowlarr
- welcome wizard
> [!info]- Steps
> - Open https://prowlarr.dakara.stream/
>
> > [!note] Values
> >
| | |
| ---- | ---- |
| Authentication Method | Forms (Login Page) |
| Authentication Required | Enabled |
| Username | asuran |
| Password | "op://Private/Jellyfin admin/password" |

- add FlareSolverr `Settings --> Indexers`
	  https://prowlarr.dakara.stream/settings/indexers
- Add (+) → FlareSolverr
	- Name: `FlareSolverr`
	- Tags: `flaresolverr`
	- Host: `http://flaresolverr:8191/`
- `Indexers --> Add New Indexer --> 1337x`
	- Name: `1337x`
	- Sort requested from site: `seeders`
- add Radarr `Settings -> Apps`
	  https://prowlarr.dakara.stream/settings/applications
- Add (+) → Radarr
	- Name: `Radarr`
	- Sync Level: `Full Sync`
	- Prowlarr Server: `http://prowlarr:9696`
	- Radarr Server: `http://radarr:7878`
	- API Key: `"op://Private/Jellyfin admin/radarr API key"`
- Add (+) → Sonarr
	- Name: `Sonarr`
	- Sync Level: `Full Sync`
	- Prowlarr Server: `http://prowlarr:9696`
	- Radarr Server: `http://sonarr:8989`
	- API Key: `"op://Private/Jellyfin admin/radarr API key"`

#### Jellyseerr
- welcome wizard
> [!info]- Steps
> - Open https://program.dakara.stream/setup
>
> > [!note] Values
> >
| | |
| ---- | ---- |
| Choose Server Type | Jellyfin |
| Sign In —> | |
| Jellyfin URL | `kino.dakara.stream` |
| Use SSL | `TRUE` |
| URL Base | N/A |
| Email Address | dev.danielknourek+jellyseer@gmail.com |
| Username | asuran |
| Password | "op://Private/Jellyfin admin/password" |
| Jellyfin Libraries —> | |
| Sync Libraries | `Filmy CZ; Filmy EN; Pořady CZ; Pořady EN` |
| Radarr Settings —> |  |
| - Default Server | TRUE |
| - Server Name | `radarr.dakara.stream` |
| - Hostname | `http://``radarr` |
| - Port | `8989` |
| - Use SSL | FALSE |
| - API Key* | `"op://Private/Jellyfin admin/radarr API key"` |
| - Quality Profile | `HD-1080p` |
| - Root Folder | `/media/Pořady📺/English/` |
| - Minimum Availability | `Released` |
| - aaaaaa | bbbbbb |
| Sonarr Settings —> |  |
| - Default Server | TRUE |
| - Server Name | `sonarr.dakara.stream` |
| - Hostname | `http://``sonarr` |
| - Port | `8989` |
| - Use SSL | FALSE |
| - API Key* | `"op://Private/Jellyfin admin/sonarr API key"` |
| - Quality Profile | `HD-720p/1080p` |
| - Root Folder | `/media/Pořady📺/English/` |
> `*` API Key: Find the API key in the Radarr/Sonarr interface under Settings > General > API Key.


- [ ] TODO: dont run as Root but as apps 568

---
---
---
## used Commands

- given truenas app creation flow its hard to include enviroment variables in separate file, I have done this manually![[all-jellyfin-deployment-env.yaml]]
- create env file
```sh
# BASE
COMMON_PATH=/mnt/ssd-data0/app-data/jellyfinPlus
TZ=Europe/Prague

# Uncomment the lines below to enable the corresponding VPN configuration

# NORD VPN
# OPENVPN_USER=username  # Your username for NordVPN
# OPENVPN_PASSWORD=password  # Your password for NordVPN
# SERVER_REGIONS=Belgium  # Choose the server region (Belgium here)

# PROTON VPN 
# ENDPOINT_IP=PEER_ENDPOINT_IP  # The endpoint IP address of the VPN server
# WIREGUARD_ADDR=Interface_Address  # The WireGuard interface address
# ENDPOINT_PORT=51820  # Default port is 51820, but confirm if different
# DNS_ADDRESS=Interface_DNS  # DNS address for ProtonVPN
# PUBLIC_KEY=PEER_PublicKey  # The public key of the other peer
# PRIVATE_KEY=PrivateKey  # Your private key
# MULLVAD VPN
SERVER_CITIES=Amsterdam  # Choose the server city (Amsterdam here)
PRIVATE_KEY="op://Private/5jdug5dtjs63g2oe7vlbcyv5ey/WIREGUARD PRIVATE KEY"  # Your private key
```

```sh
sudo touch /mnt/ssd-data0/app-data/jellyfinPlus/options.env
sudo chmod 660 /mnt/ssd-data0/app-data/jellyfinPlus/options.env

# lazy person snippet
sudo vim /mnt/ssd-data0/app-data/jellyfinPlus/options.env
```
![[options.env]]

---
- I changed bit more than ENV. This worked, but I split Jellyfin and others
```sh
sudo touch /mnt/ssd-data0/app-data/jellyfin-plus/deployment.yaml
sudo chmod 660 /mnt/ssd-data0/app-data/jellyfin-plus/deployment.yaml

# lazy person snippet
sudo vim /mnt/ssd-data0/app-data/jellyfin-plus/deployment.yaml

# and INSTALL
sudo ~/deploy_app.py jellyfin-plus --file /mnt/ssd-data0/app-data/jellyfin-plus/deployment.yaml --icon https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/jellyfin.png
```
![[all-jellyfin-deployment.yaml]]


- app Icon is from https://dashboardicons.com/icons/jellyfin

- ~~to fix flaresolvarr gem’s recomendation is add this to container~~   
```yaml
sysctls:
      - net.ipv6.conf.all.disable_ipv6=1
      - net.ipv6.conf.default.disable_ipv6=1
```
	  doesnt help ofc