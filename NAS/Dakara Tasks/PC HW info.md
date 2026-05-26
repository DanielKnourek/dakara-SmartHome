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
Just to be sure about HW i have 
## Motherboard
```sh
[root@sysrescue ~]# dmidecode -t baseboard
# dmidecode 3.6
Getting SMBIOS data from sysfs.
SMBIOS 2.8 present.

Handle 0x0002, DMI type 2, 15 bytes
Base Board Information
        Manufacturer: Micro-Star International Co., Ltd.
        Product Name: MAG B550 TOMAHAWK (MS-7C91)
        Version: 2.0
        Serial Number: 07C9123_LC1E216592
        Asset Tag: To be filled by O.E.M.
        Features:
                Board is a hosting board
                Board is replaceable
        Location In Chassis: To be filled by O.E.M.
        Chassis Handle: 0x0003
        Type: Motherboard
        Contained Object Handles: 0

Handle 0x003C, DMI type 41, 11 bytes
Onboard Device
        Reference Designation: Realtek ALC1200
        Type: Sound
        Status: Enabled
        Type Instance: 1
        Bus Address: 0000:2d:00.4
```