---
created: 2024-01-17T18:21
updated: 2024-01-17T18:42
tags:
  - task
status: Done
depends_on:
  - "[[Dakara Tasks/write Docs v2 - Custom App script/write Docs v2 - Custom App script.md|write Docs v2 - Custom App script]]"
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
---
## prepare storage
```sh
sudo zfs create \
-o acltype=posixacl \
-o xattr=sa \
-o atime=off \
-o compression=lz4 \
"ssd-data0/app-data"

sudo zfs create \
-o acltype=posixacl \
-o xattr=sa \
-o atime=off \
-o compression=lz4 \
"ssd-data0/app-data/traefik"
```

## create necessary files
```sh
sudo touch /mnt/ssd-data0/app-data/traefik/deployment.yaml
sudo chmod 600 /mnt/ssd-data0/app-data/traefik/deployment.yaml

sudo touch /mnt/ssd-data0/app-data/traefik/acme.json
sudo chmod 600 /mnt/ssd-data0/app-data/traefik/acme.json

sudo touch /mnt/ssd-data0/app-data/traefik/cloudflare.env
sudo chmod 600 /mnt/ssd-data0/app-data/traefik/cloudflare.env

sudo install -d -m 655 /mnt/ssd-data0/app-data/traefik/dynamic

sudo touch /mnt/ssd-data0/app-data/traefik/dynamic/dynamic.yaml
sudo chmod 600 /mnt/ssd-data0/app-data/traefik/dynamic/dynamic.yaml

sudo install -d -m 600 /mnt/ssd-data0/app-data/traefik/letsencrypt
```

```yml
# /mnt/ssd-data0/app-data/traefik/deployment.yaml
version: "3.9"
services:
  traefik:
    image: traefik:v3.6
    container_name: traefik
    restart: unless-stopped
    env_file: "/mnt/ssd-data0/app-data/traefik/cloudflare.env"
    security_opt:
      - no-new-privileges:true
    command:
      # EntryPoints
      - "--entryPoints.web.address=:80"
      - "--entryPoints.websecure.address=:443"
      - "--entrypoints.websecure.asDefault=true"
      - "--entrypoints.websecure.http.tls.certResolver=cloudflare"
    
      # Providers 
      - "--providers.docker=true"
      # - "--providers.docker.exposedbydefault=false"
      - "--providers.docker.network=proxy"
      - "--providers.file.watch=true" # TODO: remove Hot-reload changes
      - "--providers.file.directory=/etc/traefik/dynamic"
    
      # Cloudflare DNS Challenge
      - "--certificatesresolvers.cloudflare.acme.dnsChallenge=true"
      - "--certificatesresolvers.cloudflare.acme.dnsChallenge.provider=cloudflare"
      - "--entrypoints.web.http.redirections.entryPoint.to=websecure"
      - "--entrypoints.web.http.redirections.entryPoint.scheme=https"
      - "--certificatesresolvers.cloudflare.acme.storage=/acme.json"
      
      # API & Dashboard 
      - "--api.dashboard=true"
      - "--api.insecure=true"

      # Observability 
      #- "--log.level=INFO"
      - "--log.level=DEBUG"
      - "--accesslog=true"
      - "--metrics.prometheus=true"
    ports:
      - "80:80"
      - "443:443"
      - "8080:8080"
    volumes:
      - "/var/run/docker.sock:/var/run/docker.sock:ro"
      - "/mnt/ssd-data0/app-data/traefik/acme.json:/acme.json"
      - "/mnt/ssd-data0/app-data/traefik/dynamic:/etc/traefik/dynamic"
    labels:
      # Enable self‑routing
      - "traefik.enable=true"
    networks:
      - proxy
# Define the shared proxy network used by Traefik and all routed services
networks:
  proxy:
    name: proxy
    driver: bridge
    
# --- TrueNAS Metadata Extensions ---
x-portals:
  - host: 0.0.0.0
    name: "Traefik Dashboard"
    path: /
    port: 8080
    scheme: http

x-notes: >
  ## Traefik Reverse Proxy
  **Status:** Custom Configuration  
  
  - **Dashboard:** Port 8080  
  - **HTTP:** Port 80  
  - **HTTPS:** Port 443  
  
  Managed via external `docker-compose.yaml`.
```

```yml
# /mnt/ssd-data0/app-data/traefik/dynamic/dynamic.yaml
http:
  routers:
    truenas-dashboard:
      rule: "Host(`admin.dakara.stream`)"
      service: truenas-service
      entryPoints:
        - websecure
      tls:
        certResolver: cloudflare
        
  services:
    truenas-service:
      loadBalancer:
        servers:
          - url: "http://192.168.0.21:81"
        passHostHeader: true
```

```sh dotenv
# /mnt/ssd-data0/app-data/traefik/cloudflare.env
TRAEFIK_CERTIFICATESRESOLVERS_CLOUDFLARE_ACME_EMAIL=dev.danielknourek@gmail.com
CF_DNS_API_TOKEN="op://Private/Cloudflare/Tokens/dakara SCALE"
```


- I have used script for custom app [[write Docs v2 - Custom App script]]
```sh
sudo bash ~/deploy_app.sh traefik --file /mnt/ssd-data0/app-data/traefik/deployment.yaml --icon https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/traefik.png
```

- optional, secondary domain
```yaml
# /mnt/ssd-data0/app-data/traefik/dynamic/redirect-knourek.com-dakara.stream.yaml
http:
  middlewares:
    redirect-knourek-to-dakara:
      replacePathRegex:
        # Regex: Optional scheme, Capture subdomain (2), Capture path (3)
        regex: "^(https?://)?([^.]+)\\.1912\\.knourek\\.com(.*)"
        replacement: "https://${2}.dakara.stream${3}"

  routers:
    wildcard-redirect:
      # SIMPLIFIED RULE: Standard Regex with start (^) and end ($) anchors
      rule: "HostRegexp(`^.+\\.1912\\.knourek\\.com$`)"

      # CHANGE SERVICE: Use a real service that we know works
      service: noop@internal

      entryPoints:
        - websecure
      middlewares:
        - redirect-knourek-to-dakara
      tls:
        certResolver: cloudflare
        domains:
          - main: "*.1912.knourek.com"
            sans:
              - "1912.knourek.com"
```
---
## used resouces
- https://doc.traefik.io/traefik/expose/docker/#generate-certificates-with-lets-encrypt
- https://forums.truenas.com/t/switching-to-traefik-in-dockge-on-truenas-scale-after-nginx-stopped-working/47503
- https://doc.traefik.io/traefik/setup/docker/

---
## Used commands while debugging

```sh
# used command archive
sudo bash ./deploy_app.sh traefik --icon https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/traefik.png

#alternative icon
sudo bash ./deploy_app.sh traefik --icon https://icon.icepanel.io/Technology/svg/Traefik-Proxy.svg

sudo bash ./deploy_app.sh metadata-refresh --file deployment_test.yaml

sed -i "/^metadata:/a \  \"icon\": \"https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/traefik.png\"" "/mnt/.ix-apps/app_configs/traefik/metadata.yaml"

# call api directly via terminal
midclt call app.config traefik
```

```yaml
# TODO: remove, old file
        ...
    container_name: traefik
    restart: unless-stopped
    security_opt:
      - no-new-privileges:true
    ports:
      - 80:80      # HTTP
      - 443:443    # HTTPS
      - 8080:8080  # Dashboard (Internal only)
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - /var/run/docker.sock:/var/run/docker.sock:ro
      # 3. Map the file you created in Step 2
      - /mnt/ssd-data0/app-data/traefik/acme.json:/acme.json
    command:
      - "--api.insecure=true" # Enable Dashboard
      - "--providers.docker=true"
      - "--providers.docker.exposedbydefault=false" # Don't expose containers unless I say so
      - "--entrypoints.web.address=:80"
      - "--entrypoints.websecure.address=:443"
      # Redirect HTTP to HTTPS automatically
      - "--entrypoints.web.http.redirections.entryPoint.to=websecure"
      - "--entrypoints.web.http.redirections.entryPoint.scheme=https"
      # Cloudflare DNS Challenge Settings
      - "--certificatesresolvers.myresolver.acme.dnschallenge=true"
      - "--certificatesresolvers.myresolver.acme.dnschallenge.provider=cloudflare"
      - "--certificatesresolvers.myresolver.acme.email=your-email@example.com"
      - "--certificatesresolvers.myresolver.acme.storage=acme.json"
```

```yml

services:
  traefik:
    image: traefik:v3.6
    container_name: traefik
    command:
      - "--api.insecure=true"  # Enables Traefik dashboard on a local network (not recommended for production)
      - "--providers.docker=true"  # Use Docker as the provider
      - "--entryPoints.web.address=:80"  # HTTP entry point
      - "--entryPoints.websecure.address=:443"  # HTTPS entry point
      - "--certificatesresolvers.cloudflare.acme.dnsChallenge=true"  # Use Cloudflare for ACME
      - "--certificatesresolvers.cloudflare.acme.dnsChallenge.provider=cloudflare"  # Set up DNS challenge
    ports:
      - "80:80"  # HTTP port
      - "443:443"  # HTTPS port
    volumes:
      - "/var/run/docker.sock:/var/run/docker.sock"  # Needed for Docker integration
      - "/mnt/ssd-data0/app-data/traefik/acme.json:/letsencrypt/acme.json"  # Mount acme.json for SSL certificates
      - "/mnt/ssd-data0/app-data/traefik/cloudflare.env:/etc/traefik/cloudflare.env"  # Mount Cloudflare credentials
    labels:
      - "traefik.enable=true"
x-notes: >
  # Traefik 3.6
```



