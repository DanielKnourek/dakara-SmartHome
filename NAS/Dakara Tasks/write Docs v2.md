---"\rcreated": 2024-01-17T18:21
updated: 2024-01-17T18:42
tags:
  - task
status: Done
depends_on:
  - "[[Dakara Tasks/write Docs v2 - Traefik Setup.md|write Docs v2 - Traefik Setup]]"
  - "[[write Docs v2 - HomeAssistant|write Docs v2 - HomeAssistant]]"
dependency_completion: 100%
---
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

With verison 25.10 (Electric eel?) and loss of ssd-data0 with all containers. I started migrating from k3s to docker compose. Mix of native apps and custom apps

I made custom script to deploy app and/or add icon which is missing otherwise. 
[[write Docs v2 - Custom App script]]
