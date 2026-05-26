---
created: 2024-01-17T18:21
updated: 2024-01-17T18:42
tags:
  - task
status: Proposal
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

- prepare storage first
```sh
sudo zfs create \
-o acltype=posixacl \
-o xattr=sa \
-o atime=off \
-o compression=lz4 \
"ssd-data0/app-data/homepage"

sudo install -d -m 776 -o apps -g apps \
  /mnt/ssd-data0/app-data/homepage \
  /mnt/ssd-data0/app-data/homepage/config
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
   > > | Application Name | homepage (default) |
   > > | Version | 1.2.25 |
   > > | Timezone | 'Europe/Prague' timezone |
   > > | Database Password | "op://Domov 1912/HomeAssistant admin/password"                     |
   > > | Storage and Persistence →     |                                                        |
   > > | - Config Storage →          |                                           |
   > > | Type of Storage               | Host Path                                              |
   > > | Host Path                     | /mnt/ssd-data0/app-data/homepage/config          |
```yml
# homepage labels
      - "traefik.enable=true"
      - "traefik.http.routers.homepage.rule=Host(`home.dakara.stream`)"
      - "traefik.http.services.homepage.loadbalancer.server.port=30054" 

```

- convert to custom app
- edit deployment.yaml
 ```yaml
 networks:
  proxy:
    external: True
services:
# ...
  homepage:
# ...
 # enviroment variables
    environment:
      HOMEPAGE_ALLOWED_HOSTS: 'home.dakara.stream,192.168.0.21:30054'
# ...  
# x-portals      
x-portals:
  - host: home.dakara.stream
    name: 1. Open Homepage
    path: /
    port: 443
    scheme: https
  - host: 0.0.0.0
    name: X1 Local
    path: /
    port: 30054
    scheme: http
 ```
- fix icon using deploy_app script
```sh
sudo bash ~/deploy_app.sh home-assistant  --icon https://media.sys.truenas.net/apps/home-assistant/icons/icon.png
```


**result compose file:**
![[homepage-deployment.yaml]]

- make sure that `homepage-deployment.yaml` file exists and has correct values
```sh
sudo touch /mnt/ssd-data0/app-data/homepage/deployment.yaml
sudo chmod 660 /mnt/ssd-data0/app-data/homepage/deployment.yaml

# lazy person snippet
sudo vim /mnt/ssd-data0/app-data/homepage/deployment.yaml

# and INSTALL
sudo ~/deploy_app.py homepage --file /mnt/ssd-data0/app-data/homepage/deployment.yaml --icon https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/homepage.png
```