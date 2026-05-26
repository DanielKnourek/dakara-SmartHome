---
created: 2024-01-17T18:21
updated: 2024-01-17T18:42
tags:
  - task
status: In progress
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

## Requirements
- TrueNAS version TrueNAS-SCALE-25.10.1 and above 
  OR docker with compose
- app-pool setup

### resources
- lldap in docker 
  https://helgeklein.com/blog/authelia-lldap-authentication-sso-user-management-password-reset-for-home-networks/
## Installation
### 1. creating data-pools
```sh
sudo zfs create \
-o acltype=posixacl \
-o xattr=sa \
-o atime=off \
-o compression=lz4 \
"ssd-data0/app-data/playitgg"

sudo install -d -m 770 -o apps -g apps \
  /mnt/ssd-data0/app-data/playitgg \
  /mnt/ssd-data0/app-data/playitgg/config
```


 make sure that `playitgg-deployment.yaml` file exists and has correct values
```sh
sudo touch /mnt/ssd-data0/app-data/playitgg/deployment.yaml
sudo chmod 660 /mnt/ssd-data0/app-data/playitgg/deployment.yaml

# lazy person snippet
sudo vim /mnt/ssd-data0/app-data/playitgg/deployment.yaml

# and INSTALL
sudo ~/deploy_app.py playitgg --file /mnt/ssd-data0/app-data/playitgg/deployment.yaml --icon https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/playit-gg.png
```

![[playitgg-deployment.yaml]]
