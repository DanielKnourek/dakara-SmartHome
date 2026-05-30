---"\rcreated": 2024-01-17T18:21
updated: 2024-01-17T18:42
tags:
  - task
status: Done
depends_on:
  - "[[write Docs - Nextcloud setup|write Docs - Nextcloud setup]]"
dependency_completion: 100%
---
---
created: 2024-01-17T18:21
updated: 2024-01-17T18:42
tags:
  - task
status: Not started
depends_on: []
dependency_completion: 100%
---
```meta-bind
INPUT[listSuggester(
	optionQuery(#task)
):depends_on]
```

Po přesunu z /sdilene do ~/Travels není vidět soubory i když jsou tam umísteny

```dataviewjs
const {update} = this.app.plugins.plugins["metaedit"].api;
const result = {result: {}};
await dv.view('_Assets/Scripts/dv-StatusCategoryUtils', result);
update('dependency_completion', `${result.result}%`, dv.current().file.path)
```
```sh
# get user id for vasek
php occ user:list

# scan folder for vasek
php occ files:scan --path="/vasek/files/Travels"

php occ files:scan --all
```

