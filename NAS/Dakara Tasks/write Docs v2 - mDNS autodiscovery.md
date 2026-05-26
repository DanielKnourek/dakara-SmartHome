---
created: 2024-01-17T18:21
updated: 2024-01-17T18:42
tags:
  - task
status: Graveyard
depends_on:
  - "[[Dakara Tasks/write Docs v2 - Traefik Setup.md|write Docs v2 - Traefik Setup]]"
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

## resouces
- https://jackburgess.dev/blog/truenas-apps-access-via-mdns
- https://developers.home-assistant.io/docs/api/native-app-integration/setup/
	- https://www.home-assistant.io/integrations/zeroconf/
	- https://developers.home-assistant.io/docs/network_discovery/
- https://jellyfin.org/docs/general/post-install/networking/
- https://blog.hardill.me.uk/tag/mdns/ ✖

mDNS works on port 5353, truenas already has working instance. but dont want to brick it
I want to try make easier setup for Home-Assistant, Jellifn

|                | port  | local name                    | note            |
| -------------- | ----- | ----------------------------- | --------------- |
| Home-Assistant | 30103 | `_home-assistant._tcp.local.` | standard mDNS   |
| Jellifn        | 7359  | -                             | custom message? |



---
## used commands
```sh
# 5353 is used for mDNS

# see TCP ports on machine
sudo netstat | less
# see used UDP ports on machine
sudo netstat -upln | less

# udp    0    0 0.0.0.0:5353    0.0.0.0:*    5320/avahi-daemon:  
```