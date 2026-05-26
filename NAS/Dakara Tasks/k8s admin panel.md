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

```dataviewjs
const {update} = this.app.plugins.plugins["metaedit"].api;
const result = {result: {}};
await dv.view('_Assets/Scripts/dv-StatusCategoryUtils', result);
update('dependency_completion', `${result.result}%`, dv.current().file.path)
```


```bash
sudo k3s kubectl create serviceaccount lantean -n kube-system

sudo k3s kubectl create clusterrolebinding lantean-binder --clusterrole=cluster-admin --serviceaccount=kube-system:lantean

sudo k3s kubectl create token lantean -n kube-system --duration=8760h
```
