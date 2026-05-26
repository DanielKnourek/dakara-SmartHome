---
created: 2024-01-17T18:21
updated: 2024-04-16T13:09
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
Replace ngrok tunel with clouflared
https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/get-started/create-local-tunnel/

## Requirements

- ngrok account https://ngrok.com/docs/using-ngrok-with/docker/
- TrueNAS SCALE installation TrueNAS-22.12.4.2
- app-pool setup
## Installation 
### 1. Cloudflared (truecharts)
    
   > [!tip]- Picture reference
   > ![[____.png]]

   > [!info]- Steps
   > - Apps → Available Applications → Application Name → Install
   >  > [!note] Values
   >  > 
   >  > | | |
   >  > | ---- | ---- |
   >  > | Application Name | cloudflared (default) |
   >  > | Version | 10.0.7 |
   >  > | Image Environment → Tunnel Token | "op://Domov 1912/dakara-tcp Clouflare Tunnel/credential" |
   
