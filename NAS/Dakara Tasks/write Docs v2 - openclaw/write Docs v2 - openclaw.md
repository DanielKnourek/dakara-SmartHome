---
created: 2024-01-17T18:21
updated: 2026-05-26T20:35
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

## Requirements

- **TrueNAS SCALE** version `TrueNAS-SCALE-25.10.1` and above (or generic Docker with Compose).
- Centralized storage app-pool configured on `ssd-data1` (specifically `ssd-data1/AI` dataset).
- Custom CLI deployment script `deploy_app.py` in the host home directory (`~/deploy_app.py`).
- Preconfigured **LLDAP** setup for Phase 2 authentication (see [[write Docs v2 - lldap.md|write Docs v2 - lldap]]).

---

## 1. Architectural & Security Blueprint

OpenClaw is a proactive AI agent container. Because it runs autonomous tasks, it presents unique security considerations. To prevent compromise via prompt injections or malicious execution, we deploy a layered **"Padded Room" isolation architecture**.

### 1.1 Core Threat Model
- **Threat Vector:** Malicious prompt injection could force the agent to scan internal networks, reach local APIs (e.g., Home Assistant, TrueNAS Admin Panel), or run malicious local scripts.
- **Docker vs. VM:** While Docker containers share the host kernel, exploits escaping to the host are rare. The true danger is poor volume mount isolation or loose network permissions. A strictly configured, unprivileged Docker container provides a highly efficient and safe sandbox.

### 1.2 Container & Process Isolation
To restrict the agent’s blast radius within the container, we enforce:
- **No Host Mounts:** OpenClaw only has access to its workspace dataset `/mnt/ssd-data1/AI/openclaw`. It never mounts system configs, Nextcloud, or Home Assistant directories.
- **Unprivileged Execution:** Extended privileges are strictly disabled (`privileged: false` and `cap_drop: ALL`).
- **Standard User Execution:** The application runs under UID/GID `568:568` (`apps:apps`), ensuring it cannot modify any host files outside its delegated space.
- **Local-Only Sandboxing:** Shares of `/var/run/docker.sock` are disallowed. OpenClaw runs its sandbox code execution internally/locally inside its container. If it executes a malicious script and crashes, it only destroys its own temporary shell, and TrueNAS will automatically restart it.

### 1.3 Network Isolation & The "NAT Trap"
- **The Problem:** By default, containers on the default bridge network route traffic via the TrueNAS host IP (`192.168.0.21`). This prevents router-level firewalls from identifying and blocking the agent's traffic, as it is masked behind the host.
- **The Solution (Macvlan):** We transition the Docker Compose to use a `macvlan` network driver bound directly to physical interface `bond0`. This gives the container its own distinct LAN IP (e.g., `192.168.0.250`).
- **Firewall Rules:** With a dedicated IP, we define router-level firewall rules (Unifi/pfSense):
  - **Rule 1:** Block `192.168.0.250` access to `192.168.0.0/24` (preventing any internal scanning or local API access).
  - **Rule 2:** Allow `192.168.0.250` outbound access to WAN (to call OpenAI, Anthropic, etc.).
  - *Note:* The Linux kernel natively restricts Macvlan containers from communicating directly with their parent host interface (`192.168.0.21`), providing built-in host protection.

---

## 2. Installation & Setup

### 2.1 ZFS Dataset Creation
Create isolated ZFS datasets on the `ssd-data1` pool for the application container and shared AI files:

```sh
sudo zfs create \
  -o acltype=posixacl \
  -o xattr=sa \
  -o atime=off \
  -o compression=lz4 \
  "ssd-data1/AI"

sudo zfs create \
  -o acltype=posixacl \
  -o xattr=sa \
  -o atime=off \
  -o compression=lz4 \
  "ssd-data1/AI/openclaw"

sudo zfs create \
  -o acltype=posixacl \
  -o xattr=sa \
  -o atime=off \
  -o compression=lz4 \
  "ssd-data1/AI/shared"

# Set ownership and permissions for the "apps" user and group (568:568)
sudo install -d -m 770 -o apps -g apps \
  /mnt/ssd-data1/AI/openclaw \
  /mnt/ssd-data1/AI/shared
```

### 2.2 Credentials Setup
1. Generate a secure, high-entropy password for the OpenClaw Gateway.
2. Save this password in your 1Password vault:
   - Secret URI: `op://Private/openclaw/gateway password`
3. Expose it within the Compose configuration using the environment variable:
   - `OPENCLAW_GATEWAY_PASSWORD=<password>`

### 2.3 Compose File Configuration
Create and secure the Compose definition file:

```sh
sudo touch /mnt/ssd-data1/AI/openclaw-deployment.yaml
sudo chmod 660 /mnt/ssd-data1/AI/openclaw-deployment.yaml
sudo vim /mnt/ssd-data1/AI/openclaw-deployment.yaml
```

The layout consists of a short-lived `config` task that enforces initial configuration parameters, and the primary `openclaw` application container:

![[openclaw-deployment.yaml]]

### 2.4 Deploying to TrueNAS SCALE
Deploy the application and register its custom web interface icon using the deployment helper utility:

```sh
sudo ~/deploy_app.py openclaw --file /mnt/ssd-data1/AI/openclaw-deployment.yaml --icon https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/openclaw.png
```

---

## 3. Authentication & Production Strategy

Our deployment uses a phased approach to balance easy setup with robust access control.

### 3.1 Phase 1: Password Authentication (Testing)
- **Status:** Active in current `openclaw-deployment.yaml`.
- **Details:** The initialization `config` service runs a CLI command to set `gateway.auth.mode password` and sets the gateway entrypoint. The administrator authenticates via a static password provided in `OPENCLAW_GATEWAY_PASSWORD`.

#### 3.1.1 One-Time Device Pairing Approval
When connecting a new browser or device for the first time, OpenClaw demands a secure, one-time device pairing approval. 

Because the gateway runs on a customized port (`30262`) rather than the default (`18789`), the container's CLI tool must first be pointed to the active port before approving the pairing ID:

1. Open a shell inside the running `openclaw` container (**TrueNAS SCALE** -> **Apps** -> **OpenClaw** -> **Workloads** -> **Shell**).
2. Configure the local CLI tool to target the active port:
   ```sh
   openclaw config set gateway.port 30262
   ```
3. Approve the connection using the pairing ID shown in your browser interface:
   ```sh
   openclaw devices approve <YOUR_DEVICE_PAIRING_ID>
   ```
4. Return to your browser window and click **Connect** again to complete authorization.

### 3.2 Phase 2: Reverse Proxy & LLDAP Authelia Trust (Production)
- **Status:** Planned/Future Architecture (Not yet active).
- **Details:** For long-term security, we migrate authentication from a single static password to a trusted, identity-aware reverse proxy linked with our centralized directory (**LLDAP**).

1. **Proxy Trust:** We configure the gateway to trust headers passed by the frontend reverse proxy (Traefik v3.6):
   ```sh
   node dist/index.js config set gateway.auth.mode header
   ```
2. **Authelia Integration:**
   - Traefik intercepts incoming requests to `openclaw.dakara.stream` and forwards them to Authelia.
   - Authelia authenticates the user against LLDAP (`ldap://192.168.0.21:3890`), checking membership in an approved group (e.g., `cn=ai_operators,ou=groups,DC=knourek,DC=com`).
   - On success, Authelia/Traefik injects secure identity headers (`Remote-User`, `Remote-Groups`) and forwards the request to the OpenClaw container.
3. **Spoof Protection:** Once header auth is active, direct access to the container port (`30262`) is blocked using firewalling and Docker network restrictions, preventing unauthenticated clients from spoofing these headers.

---

## 4. Active Centralized Sandbox: Squid Proxy Firewall

- **Status:** Fully Implemented (Active in `openclaw-deployment.yaml`).
- **Details:** To achieve absolute network sandboxing without configuring router rules or host firewalls on individual devices, the container uses a centralized **Squid Forward Proxy** container that acts as a local network firewall.

### 4.1 The Routing Architecture
*   **No Direct Physical LAN & No Default Bridge:** The `openclaw` container is completely disconnected from `macvlan_net` and standard docker bridge networks. It is attached solely to a custom isolated `sandbox_net` (an `internal: true` private network) and the Traefik `proxy` network (for ingress `openclaw.dakara.stream` traffic).
*   **The Squid Gateway:** A dedicated `squid` container runs in the same stack. It has access to the physical LAN via `macvlan_net` (holding IP `192.168.0.250` and the static MAC `fe:75:22:9b:89:fd`) and connects to `sandbox_net` to act as the sole outbound gateway.
*   **Centralized Firewall Rules:** Squid uses a self-contained, zero-cache configuration (`squid_config` under docker `configs`) to filter all outbound requests:
    *   **Block** any target matching local network IP ranges: `192.168.0.0/16`, `172.16.0.0/12`, `10.0.0.0/8`.
    *   **Allow** all public internet outbound connections (e.g. Anthropic, OpenAI, etc.).
*   **Integration:** Standard `HTTP_PROXY` and `HTTPS_PROXY` environment variables are injected into OpenClaw. OpenClaw automatically routes all API outbound requests through Squid, ensuring strict sandbox filtering at the proxy level.

### 4.2 Active Network & Proxy Configurations
Below is the configuration currently implemented in our active `openclaw-deployment.yaml`:

```yaml
configs:
  squid_config:
    content: |
      acl localnet dst 192.168.0.0/16
      acl localnet dst 172.16.0.0/12
      acl localnet dst 10.0.0.0/8
      http_access deny localnet
      http_access allow localhost
      http_access allow all
      http_port 3128
      cache deny all
      pid_filename none

services:
  squid:
    cap_drop:
      - ALL
    cap_add:
      - SETGID
      - SETUID
    configs:
      - mode: 292
        source: squid_config
        target: /etc/squid/squid.conf
    image: ubuntu/squid:latest
    init: True
    platform: linux/amd64
    privileged: False
    restart: unless-stopped
    security_opt:
      - no-new-privileges=true
    networks:
      sandbox_net: {}
      macvlan_net:
        ipv4_address: 192.168.0.250
        mac_address: fe:75:22:9b:89:fd
        gw_priority: 10

  openclaw:
    # ...
    environment:
      HTTP_PROXY: http://squid:3128
      HTTPS_PROXY: http://squid:3128
      NO_PROXY: localhost,127.0.0.1,config
      http_proxy: http://squid:3128
      https_proxy: http://squid:3128
      no_proxy: localhost,127.0.0.1,config
    networks:
      sandbox_net: {}
      proxy: {}
    ports: []

networks:
  sandbox_net:
    internal: true
  macvlan_net:
    driver: macvlan
    driver_opts:
      parent: bond0
    ipam:
      config:
        - subnet: 192.168.0.0/24
          gateway: 192.168.0.1
          ip_range: 192.168.0.240/28
  proxy:
    external: True
```

> [!important]
> **Action Completed:** The sandbox is fully self-contained. No additional physical gateway firewall configurations or host-based firewall configurations are required to secure your other local devices (like printers, computers, and smart hubs). Outbound local traffic is permanently rejected at the proxy.
