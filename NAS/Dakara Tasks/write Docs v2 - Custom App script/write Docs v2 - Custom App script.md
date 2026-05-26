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

Script that gem created which allows creating custom app from yaml using commandline to be asily replicable. I am using the api for calls via terminals ``` midclt call app.create ```
- using api docs to see methods
- http://192.168.0.112:81/api/docs/current/api_methods_app.create.html
- 

>> longer files doesnt work with shell script refer to [[#Python version]]!

![[deploy_app.sh]]

```sh
# Usage: 
sudo ./deploy_app.sh <APP_NAME> <PATH_TO_COMPOSE_FILE>
# or: 
sudo bash ./deploy_app.sh <APP_NAME> <PATH_TO_COMPOSE_FILE>

# example
sudo bash ./deploy_app.sh traefik --file /mnt/ssd-data0/app-data/traefik/deployment.yaml --icon https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/traefik.png

# update icon only
sudo bash ./deploy_app.sh home-assistant  --icon https://media.sys.truenas.net/apps/home-assistant/icons/icon.png
```

after that it does not have icon. Easiest think to do is open metadata.yml file in .ix-apps dataset

```sh
sudo vim /mnt/.ix-apps/metadata.yaml
# example snippet for home assistant
```
```yml
"home-assistant":
  "custom_app": true
  "human_version": "1.0.0_custom"
  "metadata":
    "icon": "https://media.sys.truenas.net/apps/home-assistant/icons/icon.png"
    "app_version": "custom"
    "capabilities": []
    "home": ""
    ...
    ...
```

```yml
services:
  metadata-refresh:
    image: alpine
```
used icons
- alpine 
	- https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/alpine-linux.png
- home-assistant
	- https://media.sys.truenas.net/apps/home-assistant/icons/icon.png
- traefik
	- https://icon.icepanel.io/Technology/svg/Traefik-Proxy.svg

- missing icons guide
https://www.reddit.com/r/truenas/comments/1pb8wdz/finally_solved_the_last_thing_stopping_me_from/


---
## Python version
#### resources
- icons https://dashboardicons.com/
- https://github.com/truenas/api_client
- http://admin.dakara.stream:81/api/docs/current/api_methods.html

![[deploy_app.py]]

```sh
# Usage: 
sudo ~/deploy_app.py [-h] [-f FILE] [-i ICON] [-v] [-d] app_name

# example
sudo ~/deploy_app.py traefik --file /mnt/ssd-data0/app-data/traefik/deployment.yaml --icon https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/traefik.png

# update icon only
sudo ~/deploy_app.py traefik --icon https://media.sys.truenas.net/apps/home-assistant/icons/icon.png
```