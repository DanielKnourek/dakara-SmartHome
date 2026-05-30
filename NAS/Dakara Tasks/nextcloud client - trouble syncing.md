---"\rcreated": 2024-01-17T18:21
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

- I cannot sync my folder with local nextcloud. 
- account `vaclav` is OK

- vscode regex to hilight all non-ino rows
```regex
^[\d\-:]{10} [\d\-:]{12} \[ (?!info)

# simplified
\[ (?!info)
```