THIS IS A CONTEXT FOR THIS WORKSPACE AND ITS SERVER 
THIS IS A OBSIDIAN.MD VAULT UNDESTAND AND KEEP THE STRUCTURE
# Project Context: Dakara SmartHome

## Overview
Dakara SmartHome is a self-hosted infrastructure project running on **TrueNAS Scale (Goldeye 25.10.1)**. The project is currently in a "v2" phase, migrating from Kubernetes (k3s/Truecharts) to **Docker Compose** for better stability and control.

## Core Infrastructure
- **Host OS:** TrueNAS Scale (Goldeye 25.10.1).
- **Containerization:** Docker Compose (deployed via TrueNAS "Custom App" API).
- **Deployment Tooling:** A custom CLI tool `deploy_app.py` / `deploy_app.sh` interacts with the TrueNAS middleware (`midclt`) to deploy apps, update configurations, and manage UI metadata (like icons).
- **Storage:** App data is centralized in `/mnt/ssd-data0/app-data/`.
- **Networking:**
    - **Reverse Proxy:** Traefik v3.6 (handles ingress and SSL).
    - **SSL/Certs:** Let's Encrypt via Cloudflare DNS-01 challenge.
    - **Domains:** `*.dakara.stream` (Primary), `*.knourek.com` (Secondary/Redirect).
    - **External Access:** Cloudflare Tunnels, Playit.gg (for specific services like Minecraft), and Traefik.
    - **Internal Hostname:** `dakara`
    - **Internal IP:** `192.168.0.21` (Interface: `bond0`)

## Hardware & System Specs
- **CPU:** AMD Ryzen 5 5600 (6-Core Processor)
- **RAM:** 32GB (31.3 GiB available)
- **Storage Pools:**
    - `ssd-data0`: ~180GB (ZFS Mirror/Single? - for Applications)
        - Key Datasets: `app-data`, `vm-data`
    - `ssd-data1`: ~190GB (ZFS - for Game Servers & Misc)
        - Key Datasets: Minecraft servers, Conan Exiles server
    - `HomeArchive`: ~14TB (raidz2, 6x4TB - for User Data)
        - Key Datasets: `HomeArchiveData` (Media, Downloads), `nextcloud`, `backup`
- **Network:** Bonded interface (`bond0`)

## Key Services & Apps
- **Traefik:** Ingress controller and SSL termination.
- **Home Assistant:** Central hub for smart home automation.
- **Nextcloud:** Productivity and file synchronization.
- **Jellyfin:** Media streaming server.
- **LLDAP:** Lightweight LDAP for unified authentication.
- **Playit.gg:** Used for tunneling (likely for Minecraft or cases where CGNAT/Port Forwarding is an issue).
- **Heimdall:** Web dashboard for all services.

## Critical Paths & Files
- **App Data Root:** `/mnt/ssd-data0/app-data/`
- **Traefik Config:** `/mnt/ssd-data0/app-data/traefik/`
- **Deployment Scripts:** `~/deploy_app.py` (Main deployment tool).
- **Obsidian Vault:** `d:\Projects\IT-support\dakara-SmartHome\NAS\Dakara Tasks` (Contains all setup notes and task tracking).

## Current Focus (v2 Migration)
1.  **Reproducibility:** Ensuring all apps are defined in clear `deployment.yaml` (Docker Compose) files.
2.  **Stability:** Moving away from the complexity of k3s to the simplicity of Compose on TrueNAS.
3.  **UI Polish:** Managing custom app icons and metadata in the TrueNAS web interface using API calls.
4.  **Networking Refinement:** Consolidating ingress via Traefik and handling redirects.

## Common Workflows for AI Agents
- **Deploying/Updating Apps:** Use the `deploy_app.py` script.
- **Modifying Ingress:** Update Traefik dynamic configuration or Docker labels.
- **Troubleshooting:** Check ZFS dataset permissions and Traefik logs.
- **Documentation:** Maintain the Obsidian vault with updated `v2` notes.
