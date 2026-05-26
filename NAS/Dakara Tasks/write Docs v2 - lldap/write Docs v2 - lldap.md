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
"ssd-data0/app-data/lldap"

sudo install -d -m 770 -o apps -g apps \
  /mnt/ssd-data0/app-data/lldap/data \
  /mnt/ssd-data0/app-data/lldap/secrets
```

- folowing the guide, lets create secrets
```sh
tr -cd '[:alnum:]' < /dev/urandom | fold -w "64" | head -n 1 > /mnt/ssd-data0/app-data/lldap/secrets/JWT_SECRET
tr -cd '[:alnum:]' < /dev/urandom | fold -w "20" | head -n 1 > /mnt/ssd-data0/app-data/lldap/secrets/LDAP_USER_PASS
```

- alternatively copy is stored here
```sh
"op://Private/lldap admin/JWT_SECRET"
"op://Private/lldap admin/LDAP_USER_PASS"
```

- make sure that `lldap-deployment.yaml` file exists and has correct values
```sh
sudo touch /mnt/ssd-data0/app-data/lldap/deployment.yaml
sudo chmod 660 /mnt/ssd-data0/app-data/lldap/deployment.yaml

# lazy person snippet
sudo vim /mnt/ssd-data0/app-data/lldap/deployment.yaml

# and INSTALL
sudo ~/deploy_app.py lldap --file /mnt/ssd-data0/app-data/lldap/deployment.yaml --icon https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/lldap-dark.png
```

![[lldap-deployment.yaml]]
## list of groups

| group | notes |
| ----- | ----- |
|       |       |
### list of users

| username | groups | notes |
| -------- | ------ | ----- |
| lantean  |        |       |
| daniel   |        |       |

### common values

| field         | value                                              |
| ------------- | -------------------------------------------------- |
| BASE DN       | `DC=knourek,DC=com`                                |
| URI           | `ldap://192.168.0.21:3890`                         |
| SERVER        | `lldap.dakara.stream`                              |
| BIND DN       | `uid=nextcloud_helper,OU=people,DC=knourek,DC=com` |
| BIND PASSWORD | "op://Private/lldap nextcloud_helper/password"     |
| PORT          | 3890                                               |
