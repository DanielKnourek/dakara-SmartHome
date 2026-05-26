---
created: 2023-11-10T16:00
updated: 2024-03-14T02:36
tags:
  - task
status: Proposal
---
Summary: Proposal to link various apps in HEIMDALL: Home assistant, Nextcloud (archive.dakara.stream), jellyfin (watch.dakara.stream), button to restart TrueNAS webgui service, and TrueNAS scale panel (admin.dakara.stream).
Blocking status: 100
Created time: October 10, 2023 4:24 PM
Last edited time: October 15, 2023 5:00 AM
Parent task: TrueNAS scale [[(TrueNAS scale]]

- Link these apps
    - Home assistant
    - Nextcloud - [archive.dakara.stream](http://archive.dakara.stream)
    - jellyfin - [watch.dakara.stream](http://watch.dakara.stream)
    - button to restart TrueNAS webgui service
        - 
        
        ```bash
        systemctl restart middlewared
        ```
        
    - TrueNAS scale panel - [admin.dakara.stream](http://admin.dakara.stream)
