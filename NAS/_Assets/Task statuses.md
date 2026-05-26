---
created: 2024-01-17T18:26
updated: 2024-01-17T18:26
status: Proposal
---
- Not Completed
	- Proposal
	- Not started
	- In progress
- Completed
	- Done
	- Graveyard

```meta-bind
INPUT[inlineSelect(
	defaultValue('Proposal'),
    option('Proposal'),
    option('Not started'),
    option('In Progress'),
    option('Done'),
    option('Graveyard')
    ):status]
```

```dataviewjs
dv.header(3,"parse statuses")

const getStatusCategory = (lists, statusName) => {
let status_categories = lists
	.filter(el => el.children.length > 0)
	.map(el => ({
		status_category: el.text,
		children: el.children.map((children) => ({
			status: children.text
		})),
	}))

return status_categories
	.find((category) => 
		category.children
		.find((el) => el.status == statusName)
	)
}

let status_category = getStatusCategory(
	dv.page("_Assets/Task statuses").file.lists,
	"Done"
)

window.foo = status_category;
```
