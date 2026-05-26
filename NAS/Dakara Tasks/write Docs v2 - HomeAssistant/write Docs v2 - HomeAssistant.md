---
created: 2024-01-17T18:21
updated: 2024-01-17T18:42
tags:
  - task
status: Done
depends_on:
  - "[[Dakara Tasks/write Docs v2 - lldap/write Docs v2 - lldap.md|write Docs v2 - lldap]]"
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

I used ix-app for home assistant as base, needed some fixing, I can create image again with these steps [[#A. first creation]] or skip few of them and just recreate this setup [[#B. recreate home-assistant container]]

- prepare storage first
```sh
sudo zfs create \
-o acltype=posixacl \
-o xattr=sa \
-o atime=off \
-o compression=lz4 \
"ssd-data0/app-data/home-assistant"

sudo install -d -m 776 -o apps -g apps \
  /mnt/ssd-data0/app-data/home-assistant \
  /mnt/ssd-data0/app-data/home-assistant/media \
  /mnt/ssd-data0/app-data/home-assistant/config
  
 sudo install -d -m 776 -o 999 -g 999 \
  /mnt/ssd-data0/app-data/home-assistant/postgres_data
```
## A. first creation
- use Truecharts for app creation, this allows to obtain working yaml for home-assistant
	- https://admin.dakara.stream/ui/apps/available
	
   > [!info]- Steps
   > - Apps → Discover Apps → Application Name → Install
   > > [!note] Values
   > > 
   > > | | |
   > > | ---- | ---- |
   > > | Application Name | home-assistant (default) |
   > > | Version | 1.6.22 |
   > > | Timezone | 'Europe/Prague' timezone |
   > > | Database Password | "op://Domov 1912/HomeAssistant admin/password"                     |
   > > | Storage and Persistence →     |                                                        |
   > > | - Config Storage →          |                                           |
   > > | Type of Storage               | Host Path                                              |
   > > | Host Path                     | /mnt/ssd-data0/app-data/home-assistant/config          |
   > > | - Media Storage →          |                                            |
   > > | Type of Storage               | Host Path                                              |
   > > | Host Path                     | /mnt/ssd-data0/app-data/home-assistant/media           |
   > > | - Postgres Data Storage →          |                                    |
   > > | Type of Storage               | Host Path                                              |
   > > | Host Path                     | /mnt/ssd-data0/app-data/home-assistant/postgres_data   |
   > > | Labels Configuration | {see labels below} |
```yml
# Home-assistant labels
      - "traefik.enable=true"
      - "traefik.http.routers.homeassistant.rule=Host(`ha.dakara.stream`)"
      - "traefik.http.services.homeassistant.loadbalancer.server.port=30103"
```
- convert to custom app
- fix icon using deploy_app script
```sh
sudo bash ~/deploy_app.sh home-assistant  --icon https://media.sys.truenas.net/apps/home-assistant/icons/icon.png
```

Traefik specific configuration
- add network to home-assistant-deployment.yml. This allows this contianer be visible for the proxy. in this step I can add network `addons` for the mqtt and zigbee service
```yml
networks:
  proxy:
    external: True
  addons:
    external: True
services:
  home-assistant:
    networks:
      - default
      - proxy
      - addons
```

there is now need to create network that is not yet defined
```sh
sudo docker network create addons
# if traefik proxy is not yet defined I can also define it here or remove it if traefik is not used
# sudo docker network create addons
```
- add traefik proxy to the configuration.yaml of the home assistant. So it does actually allow communication from traefik

```sh
# lazy person snippet
sudo vim /mnt/ssd-data0/app-data/home-assistant/config/configuration.yaml

# OR directly in container
sudo docker exec -it ix-home-assistant-home-assistant-1 /bin/sh
vi /config/configuration.yaml
```  
```yml
http:
  use_x_forwarded_for: true
  trusted_proxies:
    - 127.0.0.1
    - 172.16.0.0/12   # Covers standard Docker networks (including 'proxy')
    - 192.168.0.0/16  # Covers local LAN (TrueNAS IP)
```

### home initialization

   > [!info]- onboarding
   > - http://admin.dakara.stream:30103/onboarding.html
   > > [!note] Values
   > > 
   > > | | |
   > > | ---- | ---- |
   > > | Name | asuran |
   > > | Username | asuran |
   > > | Password | asuran |
   > > | Username | "op://Domov 1912/HomeAssistant admin/password" |
   > > | Next page → | |
   > > | Address | 1912, Na Strži, Nová Paka, Nová Paka |
   > > | Next page → | |
   > > | Basic analytics | yes |
   > > | Usage | yes |
   > > | Statistical data | yes |
   > > | Diagnostics | yes |
---

### Traefik integration - trusted domains
- need to allow requests form traefik to be accepted by home-assistant
```yaml
http:
  use_x_forwarded_for: true
  trusted_proxies:
    - 127.0.0.1
    - 172.16.0.0/12  # Standard Docker Subnet
    - 192.168.0.0/23 # Your Local LAN
```
```sh
# lazy person snippet
sudo vim /mnt/ssd-data0/app-data/home-assistant/config/configuration.yaml

# after edit restart home-assistant (optional)
sudo midclt call app.redeploy home-assistant
```
### ldap integration

#### resources
- [[write Docs v2 - lldap]]
- https://github.com/lldap/lldap/blob/main/example_configs/home-assistant.md

- download the script
```sh
sudo curl -L -o /mnt/ssd-data0/app-data/home-assistant/config/scripts/lldap-ha-auth.sh "https://raw.githubusercontent.com/lldap/lldap/main/example_configs/lldap-ha-auth.sh"

sudo chown apps:apps /mnt/ssd-data0/app-data/home-assistant/config/scripts/lldap-ha-auth.sh
sudo chmod 550 /mnt/ssd-data0/app-data/home-assistant/config/scripts/lldap-ha-auth.sh

# check the file integrity
sudo vim /mnt/ssd-data0/app-data/home-assistant/config/scripts/lldap-ha-auth.sh
```
- add script as custom authenticator
```yaml
homeassistant:
    auth_providers:
    - type: command_line
      command: /config/scripts/lldap-ha-auth.sh
      # arguments: [<LDAP Host>, <regular user group>, <admin user group>, <local user group>]
      # <regular user group>: Find users that has permission to access homeassistant, anyone inside
      # this group will have the default 'system-users' permission in homeassistant.
      #
      # <admin user group>: Allow users in the <regular user group> to be assigned into 'system-admin' group.
      # Anyone inside this group will not have the 'system-users' permission as only one permission group
      # is allowed in homeassistant
      #
      # <local user group>: Users in the <local user group> (e.g., 'homeassistant_local') can only access
      # homeassistant inside LAN network.
      #
      # Only the first argument is required. ["https://lldap.example.com"] allows all users to log in from
      # anywhere and have 'system-users' permissions. 
      args: ["https://lldap.dakara.stream", "ha_user", "ha_admin", "ha_local"]
      meta: true
      
    - type: homeassistant
```
```sh
# lazy person snippet
sudo vim /mnt/ssd-data0/app-data/home-assistant/config/configuration.yaml

# after edit restart home-assistant (optional)
sudo midclt call app.redeploy home-assistant
```

### Adding util containers
#### requirements
- Zigbee usb gateway
- app volumes
	- "ssd-data0/app-data/mosquitto"
	- "ssd-data0/app-data/zigbee"

#### resources 
 - https://www.reddit.com/r/truenas/comments/1ip4qvq/help_setting_up_user_authentication_for_eclipse/
 - https://mosquitto.org/man/mosquitto-conf-5.html
#### mosquitto
- prepare storage first
```sh
sudo zfs create \
-o acltype=posixacl \
-o xattr=sa \
-o atime=off \
-o compression=lz4 \
"ssd-data0/app-data/mosquitto"

sudo install -d -m 776 -o apps -g apps \
  /mnt/ssd-data0/app-data/mosquitto \
  /mnt/ssd-data0/app-data/mosquitto/data \
  /mnt/ssd-data0/app-data/mosquitto/config
```

   > [!info]- Steps
   > - Apps → Discover Apps → Application Name → Install
   > > [!note] Values
   > > 
   > > | | |
   > > | ---- | ---- |
   > > | Application Name | mosquitto |
   > > | Version | 1.1.14 |
   > > | Timezone | 'Europe/Prague' timezone |
   > > | Storage and Persistence →     |                                                        |
   > > | - Data Storage →          |                                           |
   > > | Type of Storage               | Host Path                                              |
   > > | Host Path                     | `/mnt/ssd-data0/app-data/mosquitto/data`          |
   > > | - Config Storage →          |                                            |
   > > | Type of Storage               | Host Path                                              |
   > > | Host Path                     | `/mnt/ssd-data0/app-data/mosquitto/config`          |
   > > | Labels Configuration | {see labels below} |
```yml
# mosquitto labels
      - "traefik.enable=true"
      - "traefik.http.routers.mqtt.rule=Host(`mqtt.dakara.stream`)"
      - "traefik.http.services.mqtt.loadbalancer.server.port=1883"
```
- convert to custom app
- setup password
```sh
# enter container
sudo docker exec -it ix-mosquitto-mosquitto-1 /bin/sh

mosquitto_passwd -c /mosquitto/config_includes/passwordfile mqtt_user
# password: "op://Private/dakara mosquitto/password"

echo "password_file /mosquitto/config_includes/passwordfile" > /mosquitto/config_includes/passwordconfig.conf
```

#### zigbee2mqtt
requirements 
- ZigBee gateway USB

installation
- setup storage
```sh
sudo zfs create \
-o acltype=posixacl \
-o xattr=sa \
-o atime=off \
-o compression=lz4 \
"ssd-data0/app-data/zigbee2mqtt"

sudo install -d -m 776 -o apps -g apps \
  /mnt/ssd-data0/app-data/zigbee2mqtt/data
```

- identify id of ZigBee gateway
```sh
# check if usb is detected
lsusb -v -t 

# get id
ls -l /dev/serial/by-id/usb*
# /dev/serial/by-id/usb-Texas_Instruments_TI_CC2531_USB_CDC___0X00124B001CD4EA72-if00
```

   > [!info]- Steps
   > - Apps → Discover Apps → Application Name → Install
   > > [!note] Values
   > > 
   > > | | |
   > > | ---- | ---- |
   > > | Application Name | zigbee2mqtt |
   > > | Version | 1.0.56 |
   > > | Topic | `zigbee2mqtt` |
   > > | Server | `mqtt://mosquitto:1883` |
   > > | User | `mqtt_user` |
   > > | Password | `"op://Private/dakara mosquitto/password"` |
   > > | Port | `/dev/serial/by-id/usb-Texas_Instruments_TI_CC2531_USB_CDC___0X00124B001CD4EA72-if00` |
   > > | Adapter | `zstack` |
   > > | Storage and Persistence →     |                                                        |
   > > | - Data Storage →          |                                           |
   > > | Type of Storage               | Host Path                                              |
   > > | Host Path                     | `/mnt/ssd-data0/app-data/mosquitto/data`          |
   > > | Labels Configuration | {see labels below} |
```yml
# mosquitto labels
      - "traefik.enable=true"
      - "traefik.http.routers.zigbee2mqtt.rule=Host(`zigbee2mqtt.dakara.stream`)"
      - "traefik.http.services.zigbee2mqtt.loadbalancer.server.port=30065"
```
- convert to custom app

#### combine all services into one app
- merge compose file for mosquitto and zigbee2mqtt into single compose file
- add network to `ha-addons-deployment.yml`. 
```yml
configs:
  mosquitto.conf:
    content: |
    
networks:
  proxy:
    external: True
  addons:
    external: True
services:
  mosquitto:
    networks:
      - default
      - addons
  zigbee2mqtt:
    enviroment:
      ZIGBEE2MQTT_CONFIG_FRONTEND_AUTH_TOKEN: "YourSecretPasswordHere"
    networks:
      - default
      - proxy
      - addons
        
        "op://Private/dakara ZigBee2MQTT/password"
```

**result compose file:**
![[ha-addons-deployment.yaml]]
- make sure that `ha-addons-deployment.yaml` file exists and has correct values
```sh
sudo touch /mnt/ssd-data0/app-data/mosquitto/deployment.yaml
sudo chmod 660 /mnt/ssd-data0/app-data/mosquitto/deployment.yaml

# lazy person snippet
sudo vim /mnt/ssd-data0/app-data/mosquitto/deployment.yaml

# and INSTALL
sudo ~/deploy_app.py home-assistant-addons --file /mnt/ssd-data0/app-data/mosquitto/deployment.yaml --icon https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/esphome.png
```

- connect to (http://admin.dakara.stream:30065) to see onboarding
   > [!tip]- Picture reference
   > ![[conf-onboarding-zigbee2mqtt.png]]

- add new ZigBee2MQTT panel to home assistant via UI on settings page 
  https://ha.dakara.stream/config/lovelace/dashboards
- add MQTT integration to home-assistant
     > [!info]- Steps
   > - https://ha.dakara.stream/config/integrations/dashboard
   > > [!note] Values
   > > 
   > > | | |
   > > | ---- | ---- |
   > > | Broker | `mqtt://mosquitto` |
   > > | Port | `1883` |
   > > | Username | `mqtt_user` |
   > > | Password | `"op://Private/dakara mosquitto/password"` |

### Adding HACS
to use comunity addons, best way is to add HACS
#### resouces
- https://hacs.xyz/docs/use/download/download/#to-download-hacs
- https://community.home-assistant.io/t/installing-hacs-is-tricky-in-docker-but-the-documentation-is-very-straightforward-when-you-know-how-to-read/450283/2
- https://hacs.xyz/docs/use/configuration/basic/#setting-up-the-hacs-integration

#### installation
```sh
# open container shell
sudo docker exec -it ix-home-assistant-home-assistant-1 /bin/sh

# use install script
wget -O - https://get.hacs.xyz | bash -


# restart home assistant
reboot
# OR via trueNAS
exit
sudo midclt call app.redeploy home-assistant

```
- add HACS integration
  https://ha.dakara.stream/config/integrations/dashboard
- link github account

## Adding tuya
- this thing id doomed. I need to get again secrets and IDs from tuya cloud. and my licence expired again… going for the online version for now




---
## B. recreate home-assistant container
- create mount paths
```sh
sudo install -d -m 776 -o apps -g apps \
  /mnt/ssd-data0/app-data/home-assistant \
  /mnt/ssd-data0/app-data/home-assistant/media \
  /mnt/ssd-data0/app-data/home-assistant/config
  
 sudo install -d -m 776 -o 999 -g 999 \
  /mnt/ssd-data0/app-data/home-assistant/postgres_data
```

- make sure that `home-assistant-deployment.yaml` file exists and has correct values
```sh
sudo touch /mnt/ssd-data0/app-data/home-assistant/deployment.yaml
sudo chmod 660 /mnt/ssd-data0/app-data/home-assistant/deployment.yaml

# lazy person snippet
sudo vim /mnt/ssd-data0/app-data/home-assistant/deployment.yaml

# and INSTALL
sudo ~/deploy_app.py home-assistant --file /mnt/ssd-data0/app-data/home-assistant/deployment.yaml --icon https://media.sys.truenas.net/apps/home-assistant/icons/icon.png
```
![[home-assistant-deployment.yaml]]

- make sure that `ha-addons-deployment.yaml` file exists and has correct values
```sh
sudo touch /mnt/ssd-data0/app-data/mosquitto/deployment.yaml
sudo chmod 660 /mnt/ssd-data0/app-data/mosquitto/deployment.yaml

# lazy person snippet
sudo vim /mnt/ssd-data0/app-data/mosquitto/deployment.yaml

# and INSTALL
sudo ~/deploy_app.py home-assistant-addons --file /mnt/ssd-data0/app-data/mosquitto/deployment.yaml --icon https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/esphome.png
```
![[ha-addons-deployment.yaml]]


---
## Troubleshooting
### lldap user doesnt update his permisions
- wrong user group for lldap user. After updating correct user group in lldap. homeassitant doenst update. need to manualy delte entry
- shutdown home-assistant first
```sh
# edit auth file, either delete all user enries with corespoding id or update manualy the group
sudo vim /mnt/ssd-data0/app-data/home-assistant/config/.storage/auth
```

---
----
---
## used commands
- I tried using the HAAS LDAP script but it has problem with lldap
  Moved to the shell script instead
	- https://github.com/panteLx/HASS-LDAP-Auth/tree/main?tab=readme-ov-file
#### setup ldap

- https://github.com/panteLx/HASS-LDAP-Auth

- download and set permissions for script
```sh
sudo curl -L -o /mnt/ssd-data0/app-data/home-assistant/config/scripts/auth.py "https://raw.githubusercontent.com/panteLx/HASS-LDAP-Auth/main/auth.py"

sudo chown apps:apps /mnt/ssd-data0/app-data/home-assistant/config/scripts/auth.py
sudo chmod 550 /mnt/ssd-data0/app-data/home-assistant/config/scripts/auth.py

# edit values
sudo vim /mnt/ssd-data0/app-data/home-assistant/config/scripts/auth.py

# also change search attributes
# from:
search = conn.search(BASEDN, FILTER, attributes="displayName")
# to:
search = conn.search(BASEDN, FILTER, attributes=["cn"])
```

- edit script with my own values or refer to file:
   > [!note]- Values
   > 
   > | | |
   > | ---- | ---- |
   > | SERVER | `"ldap://192.168.0.21:3890"` |
   > | HELPERDN | `HELPERDN="uid=ha_helper,ou=people,dc=knourek,dc=com"` |
   > | HELPERPASS | `"op://Private/lldap ha_helper/password"` |
   > | BASEDN | `“DC=knourek,DC=com”` |
   > | ATTRS | `uid` |
   > | BASE_FILTER | `BASE_FILTER="(&(objectclass=person)(memberOf=cn=ha_users,ou=groups,DC=knourek,DC=com))"` |
![[auth.py]]
- need to install `pip install -t . ldap3` module to home-assistant
- I modified compose file to include new init service with ldap3 installing to the folder `/config/scripts`
- see snippet or refer to file: ![[home-assistant-deployment.yaml]]
```yaml
#snippet
services:
  ...
  home-assistant:
    depends_on:
      init-ldap:
        condition: service_completed_successfully
  ...
  init-ldap:
      # Install ldap3 library for the Home Assistant LDAP integration
      image: python:3.12-alpine
      container_name: ha-ldap-installer
      restart: on-failure:1
      volumes:
        - bind:
            create_host_path: False
            propagation: rprivate
          read_only: False
          source: /mnt/ssd-data0/app-data/home-assistant/config
          target: /config
          type: bind
      command: pip install -t /config --upgrade --no-cache-dir ldap3
  ...
```

- I added following to `configuration.yaml`file
```yaml
homeassistant:
    auth_providers:
        - type: command_line
          name: 'LDAP'
          command: '/usr/local/bin/python3'
          args: ['/config/scripts/auth.py']
          meta: true # Ensure this is true - otherwise you won't able to set a username/group for new created users
        - type: homeassistant
```
```sh
# lazy person snippet
sudo vim /mnt/ssd-data0/app-data/home-assistant/config/configuration.yaml

# after edit restart home-assistant (optional)
sudo midclt call app.redeploy home-assistant
```


```sh
# I wanted to see whats inside db
sudo docker exec -it ix-home-assistant-postgres-1 psql -U home-assistant -d home-assistant

#list tables
\dt
```