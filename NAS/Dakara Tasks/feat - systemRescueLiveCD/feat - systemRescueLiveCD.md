---"\rcreated": 2024-01-17T18:21
updated: 2024-01-17T18:42
tags:
  - task
status: Done
depends_on:
  - "[[fix - drive recovery|fix - drive recovery]]"
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

How did I edited and used SystemRescue LiveCD

## configuration
- Ventoy doesnt seem to work
- I want ssh with my public key
- display flickers, set refreshrate to 60Hz from 70Hz
- https://www.system-rescue.org/manual/Configuring_SystemRescue_sysconfig/

![[200-configuration.yaml]]

- start-off point is this guide for creating yaml
	- https://www.system-rescue.org/manual/Configuring_SystemRescue_sysconfig/
- after that I made clean USB
- opened it in windwos explorer and added yml files to the USB
- save with “LF” not with “CRLF”
