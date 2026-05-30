---"\rcreated": 2023-10-14T16:23:00
updated: 2024-04-16T13:10
tags:
  - task
status: Done
depends_on:
  - "[[Have Power and internet|Have Power and internet]]"
  - "[[HOME ASSISTANT fix|HOME ASSISTANT fix]]"
  - "[[Jellyfin library structure|Jellyfin library structure]]"
dependency_completion: 33.3%
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
Blocking: write Docs - nextcloud setup [[(write Docs - nextcloud setup]], write Docs - jellyfin setup [[(write Docs - jellyfin setup]], write Docs - truecharts essentials [[(write Docs - truecharts essentials]], write Docs - certificate authority [[(write Docs - certificate authority]], write Docs - lldap [[(write Docs - lldap]]
Blocking status: 100
Created time: October 14, 2023 4:23 PM
Last edited time: October 18, 2023 6:34 PM

## Requirements

- [https://truecharts.org/manual/SCALE/guides/getting-started](https://truecharts.org/manual/SCALE/guides/getting-started)
- TrueNAS SCALE installation TrueNAS-22.12.4.2
- app-pool setup

## Installation

1. adding TrueCharts apps catalog
   
   > [!tip]- Picture reference
   > ![[conf-add-TrueCharts-catalog.png]]
    
   > [!info]- Steps
   > - Apps → Manage Catalogs → Add Catalog
   > > [!note] Values
   > > 
   >  > | | |
   > > | ---- | ---- |
   > > | Catalog Name | https://github.com/truecharts/catalog |
   > > | Repository | Truecharts |
   > > | Preferred Trains | stable, enterprise, operators, incubator |

2. adding operators apps
    
    ### 2.1 cloudnative-pg
    
   > [!tip]- Picture reference
   > ![[app-cloudnative-pg-2.0.3.png]]

   > [!info]- Steps
   > - Apps → Available Applications → Application Name → Install
   >  > [!note] Values
   >  > 
   >  > | | |
   >  > | ---- | ---- |
   >  > | Application Name | cloudnative-pg (default) |
   >  > | Version | 2.0.3 |
   
    
    ### 2.2 prometheus-operator

   > [!tip]- Picture reference
   > ![[app-prometheus-operator-1.0.5.png]]

   > [!info]- Steps
   > - Apps → Available Applications → Application Name → Install
   >  > [!note] Values
   >  > 
   >  > | | |
   >  > | ---- | ---- |
   >  > | Application Name | prometheus-operator (default) |
   >  > | Version | 1.0.5 |
    
    ### 2.3 cert-manager

   > [!tip]- Picture reference
   > ![[app-cert-manager-1.0.4.png]]
        
   > [!info]- Steps
   > - Apps → Available Applications → Application Name → Install
   >  > [!note] Values
   >  > 
   >  > | | |
   >  > | ---- | ---- |
   >  > | Application Name | cert-manager (default) |
   >  > | Version | 1.0.4 |
    
3. adding Traefik app
	- [https://truecharts.org/charts/enterprise/traefik/how-to/](https://truecharts.org/charts/enterprise/traefik/how-to/)
    
	3.1. configuring WebUI
	
      > [!tip]- Picture reference
      > ![[conf-scale-webUI.png]]

      > [!info]- Steps
      > - System Settings → General → Settings (GUI)
      > > [!note] Values
      > > 
      > > | | |
      > > | ---- | ---- |
      > > | Web Interface HTTP Port | 81 (default) |
      > > | Web Interface HTTPS Port | 444 |
    
    ### 3.2 traefik (init)

   > [!tip]- Picture reference
   > ![[app-traefik-21.0.8.png]]

   > [!info]- Steps
   > - Apps → Available Applications → Application Name → Install
   > > [!note] Values
   > > 
   > > | | |
   > > | ---- | ---- |
   > > | Application Name | traefik (default) |
   > > | Version | 21.0.8 |
   > > | Service Type | LoadBalancer (Expose Ports) |
   > > | web Entrypoint Configuration → Entrypoints Port | 80 |
   > > | websecure Entrypoints Configuration → Entrypoints Port | 443 |

1. managing certificates for all apps
    - [https://truecharts.org/charts/enterprise/clusterissuer/how-to/](https://truecharts.org/charts/enterprise/clusterissuer/how-to/)
    
    4.1. Requirements
    
    - domain on cloudflare
        - dakara.stream
    - CloudFlare API Token
        > [!info]- Steps
        > [https://dash.cloudflare.com/profile/api-tokens](https://dash.cloudflare.com/profile/api-tokens)
        > 1. Create Token
        > 2. Edit zone DNS → Use template
        > 3. Token name → “clusterissuer cf token”
        > 4. Permissions → Zone, DNS, Edit
        > 5. Permissions → Zone, Zone, Read
        > 6. Zone Resources → Include, All zones
        > 7. Continue To Summary → Create Token
    
    ### 4.2 clusterissuer

   > [!tip]- Picture reference
   > ![[app-clusterssuer-4.1.2.png]]

   > [!info]- Steps
   > - Apps → Available Applications → Application Name → Install
   > > [!note] Values
   > > 
   > > | | |
   > > | ---- | ---- |
   > > | Application Name | clusterissuer (default) |
   > > | Version | 4.1.2 |
   > > | - ACME Issuer → |  |
   > > | Name | dakara-stream-cloudflare |
   > > | Type or DNS-Provider | Cloudflare |
   > > | Server | Letsencrypt-Production |
   > > | Email | dev.danielknourek@gmail.com |
   > > | CloudFlare API Token | "op://Private/Cloudflare/Tokens/clusterissuer cf token” |
    
  4.3 Creating ACME Certificates  
    - [https://www.truenas.com/docs/scale/scaletutorials/credentials/certificates/settingupletsencryptcertificates/](https://www.truenas.com/docs/scale/scaletutorials/credentials/certificates/settingupletsencryptcertificates/)
    - [https://www.youtube.com/watch?v=TJ5fDiDRcbU](https://www.youtube.com/watch?v=TJ5fDiDRcbU)

  4.3.1 Requirements
    - domain on cloudflare
	    - dakara.stream
    - CloudFlare API Token
      > [!info]- Steps
      > [https://dash.cloudflare.com/profile/api-tokens](https://dash.cloudflare.com/profile/api-tokens)
      > 1. Create Token
      > 2. Edit zone DNS → Use template
      > 3. Token name → “dakara SCALE”
      > 4. Permissions → Zone, DNS, Edit
      > 5. Permissions → Zone, Zone, Read
      > 6. Zone Resources → Include, All zones
      > 7. Continue To Summary → Create Token
    
   4.3.2 SCALE certiface authority configuration
   > [!tip]- Picture reference - ACME DNS-Authenticators
   > ![[config-certificates-ACME.png]]

   > [!info]- Steps - ACME DNS-Authenticators
   > - Credentials → Certificates → ACME DNS-Authenticators → Add
   > > [!note] Values
   > > 
   > > | | |
   > > | ---- | ---- |
   > > | Name | Cloudflare |
   > > | Authenticator | cloudflare |
   > > | API Token | "op://Private/Cloudflare/Tokens/dakara SCALE” |
    
   > [!tip]- Picture reference - Certificate Signing Requests
   > ![[conf-certificates-csr.png]]
   
   > [!info]- Steps - Certificate Signing Requests
   > - Credentials → Certificates → Certificate Signing Requests → Add
   > > [!note] Values
   > > 
   > > | | |
   > > | --- | --- |
   > > | 1. Identifier and Type → |  |
   > > | Name | csr |
   > > | Type | Certificate Signing Request |
   > > | 2. Certificate Options → |  |
   > > | RSA | RSA |
   > > | Key Length | 2048 |
   > > | Digest Algorithm | SHA256 |
   > > | 3. Certificate Subject → |  |
   > > | Country | Czech Republic |
   > > | State | Královehradecký kraj |
   > > | Locality | Nová Paka |
   > > | Organization | dakara.stream |
   > > | Email | dev.danielknourek@gmail.com |
   > > | Subject Alternate Names | *.dakara.stream |

   > [!tip]- Picture reference - ACME Certificate
   > ![[conf-certificates-dakara-stream-cloudflare.png]]
   
   > [!info]- Steps - ACME Certificate
   > - Credentials → Certificates → Certificate Signing Requests → csr → Create ACME Certificate (wrench icon)
   > > [!note] Values
   > > 
   > > | Identifier | dakara-stream-cloudflare |
   > > | --- | --- |
   > > | Terms of Service | yes |
   > > | Renew Certificate Days | 10 |
   > > | ACME Server Directory URI | Let's Encrypt Production Directory |
   > > | - Domains → |  |
   > > | DNS:*.dakara.stream | Cloudflare |
    
 4.4. TrueNAS scale UI cert
   > [!tip]- Picture reference
   > ![[conf-scale-webUI.png]]
    
   > [!info]- Steps
   > - System Settings → Genereal → GUI → Settings
   > > [!note] Values
   > > 
   > > | | |
   > > | ---- | ---- |
   > > | GUI SSL Certificate | dakara-stream-cloudflare |
