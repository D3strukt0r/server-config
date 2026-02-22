# network-docker

Rootless Podman Quadlet deployment for the networking server (`network-docker`), managed with a two-tier architecture:

- **Tier 1** (Ansible) — Bootstrap infrastructure: proxy network, Vault, Vault Agent, Materia, system prerequisites (sysctl, kernel modules)
- **Tier 2** (Materia GitOps) — All application services: Traefik, Certbot, Portainer, Watchtower, Omada, Pi-hole, Mosquitto, Zigbee2MQTT, OpenThread Border Router (OTBR), Matter Server, Home Assistant

## Directory Structure

```
network-docker/
  tier1/                               # Ansible-deployed Quadlet files
    proxy.network                      # Shared bridge network for Traefik-proxied services
    vault/
      vault.container                  # HashiCorp Vault (secret store)
      vault-data.volume                # Persistent volume for Vault data
      vault.env.dist                   # Vault env template (copied to target on first run)
    vault-agent/
      vault-agent.container            # Vault Agent (renders secrets from Vault to disk)
      vault-agent-sync.timer           # Periodic secret refresh (every 6h)
      vault-agent-config.hcl           # Agent config (token auth, template stanzas)
      templates/
        certbot-cloudflare.ini.ctmpl   # Cloudflare API token for Certbot
        pihole-web-password.env.ctmpl  # Pi-hole web password
        zigbee2mqtt-secret.yaml.ctmpl  # MQTT password for Zigbee2MQTT
    materia/
      materia.container                # Materia GitOps agent (pulls tier2 from Git)
      materia-update.timer             # Daily timer for automatic updates (04:00 UTC)
  tier2/                               # Materia-managed components
    MANIFEST.toml                      # Maps host "network-docker" to its components
    attributes/
      network-docker.toml              # Age-encrypted config for this host (non-sensitive only)
    components/
      traefik/                         # Reverse proxy with TLS
      certbot/                         # DNS-01 certificate renewal via Cloudflare
      portainer/                       # Container management UI
      watchtower/                      # Automatic container image updates
      omada/                           # TP-Link Omada SDN controller
      pihole/                          # DNS ad blocker + wildcard *.network-docker.local
      mosquitto/                       # Eclipse Mosquitto MQTT broker
      zigbee2mqtt/                     # Zigbee2MQTT bridge (SLZB-MR4U via TCP)
      openthread-border-router/        # OpenThread Border Router (rootless privileged, host network)
      matter-server/                   # Python Matter Server
      homeassistant/                   # Home Assistant Core
```

## Prerequisites

- A Debian-based target machine with SSH access
- Ansible installed on your local (control) machine (WSL users: see [WSL setup](#wsl-setup) below)
- An [age](https://github.com/FiloSottile/age) keypair for encrypting non-sensitive config
- An SSH key deployed to the target (for Materia to clone from GitHub)
- A Cloudflare API token (for Certbot DNS-01 challenges on `*.d3strukt0r.dev`)
- An SLZB-MR4U coordinator connected via Ethernet/PoE, reachable at `slzb-mr4u.local` via mDNS (for Thread + Zigbee)

## WSL Setup

If running Ansible from WSL, Windows-mounted paths (`/mnt/c/...`) default to 777 permissions. Ansible refuses to load `ansible.cfg` from world-writable directories, breaking inventory discovery. Fix this by adding to `/etc/wsl.conf` inside your WSL instance:

```bash
sudo tee -a /etc/wsl.conf <<'EOF'
[automount]
enabled = true
options = "metadata,umask=22,fmask=11"
EOF
```

Then restart WSL from PowerShell:

```powershell
wsl --shutdown
```

This sets directories to 755 and files to 644 on Windows mounts.

### 1Password SSH Agent

If your SSH keys are stored in 1Password, configure Ansible and Git to use the Windows SSH client (`ssh.exe`), which has native access to the 1Password SSH agent:

```bash
# Ansible (already configured in ansible.cfg)
# [ssh_connection]
# ssh_executable = ssh.exe

# Git (for cloning/pushing via SSH)
git config --global core.sshCommand ssh.exe
```

## Setup

### 1. Generate an Age Keypair

```bash
age-keygen -o age-key.txt
# Output: Public key: age1abc123...
```

This creates `age-key.txt` (private key) and prints the public key to stdout. Store the private key securely (password manager, encrypted drive) — do **not** commit it to the repo. Ansible deploys it to the server via `--extra-vars "materia_age_private_key=$(cat /path/to/age-key.txt)"`.

To re-extract the public key later:

```bash
age-keygen -y age-key.txt
```

### 2. Add Your Public Key to the Recipients File

Paste the public key from step 1 into `tier2/attributes/recipients` (one key per line):

```bash
echo "age1abc123..." >> tier2/attributes/recipients
```

### 3. Configure Attributes

Edit `tier2/attributes/network-docker.toml` with your values. This file holds **non-sensitive** configuration only — actual secrets (API tokens, passwords) are stored in Vault.

```toml
[globals]
domain = "network-docker.local"
proxy_network = "proxy"
container_data_dir = "/home/d3strukt0r/container-data"
server_ip = "192.168.1.13"

[components.traefik]
containerTag = "3"

[components.certbot]
containerTag = "latest"
certbot_email = "dev@d3strukt0r.dev"

[components.portainer]
containerTag = "alpine"

[components.watchtower]
containerTag = "latest"

[components.omada]
containerTag = "latest"

[components.pihole]
containerTag = "latest"

[components.mosquitto]
containerTag = "latest"

[components.zigbee2mqtt]
containerTag = "latest"
slzb_host = "slzb-mr4u.local"
slzb_zigbee_port = "6638"

[components.openthread-border-router]
containerTag = "latest"
slzb_host = "slzb-mr4u.local"
slzb_thread_port = "9999"
backbone_interface = "ens18"

[components.matter-server]
containerTag = "stable"

[components.homeassistant]
containerTag = "stable"
```

### 4. Encrypt the Attributes File

```bash
cd tier2/attributes
age -e -R recipients -o network-docker.toml.age network-docker.toml
mv network-docker.toml.age network-docker.toml
```

The encrypted file replaces the plaintext one. Do not commit the unencrypted version.

### 5. Commit and Push

```bash
git add tier2/attributes/recipients
git add tier2/attributes/network-docker.toml
git push
```

### 6. Run the Ansible Playbook (First Run)

```bash
cd server-ansible/network-docker

ansible-playbook playbook.yml \
  --extra-vars "materia_age_private_key=$(cat ../../server-container/network-docker/tier2/attributes/age-key.txt)"
```

This deploys the full stack:

1. **Base system** — packages, networking, podman, SSH, GPG, swap, sysctl (incl. Thread prerequisites), kernel modules
2. **Tier 1** — proxy network, self-signed certs, Vault, Vault Agent (with placeholder secrets), Materia
3. **Materia runs** — clones the repo, decrypts attributes, templates Quadlets, starts all Tier 2 services (including OTBR, Matter Server, Home Assistant, Mosquitto, Zigbee2MQTT)

At this point services are running with placeholder secrets. Certbot won't have a valid Cloudflare token yet, Pi-hole will have a dummy password, and Zigbee2MQTT will have a placeholder MQTT password. The next steps fix that.

### 7. Initialize Vault (One-Time)

```bash
ssh d3strukt0r@network-docker.local

# Initialize Vault
podman exec vault vault operator init

# SAVE the 5 unseal keys and root token somewhere safe (e.g., password manager)

# Unseal Vault (repeat with 3 of the 5 keys)
podman exec vault vault operator unseal <key1>
podman exec vault vault operator unseal <key2>
podman exec vault vault operator unseal <key3>

# Login with root token
podman exec -it vault vault login <root-token>
```

### 8. Configure Vault Secrets (One-Time)

```bash
# Enable KV v2 secrets engine
podman exec vault vault secrets enable -version=2 -path=secret kv

# Write the actual secrets
podman exec vault vault kv put secret/network-docker \
  cloudflare_api_token="your-real-cloudflare-token" \
  pihole_web_password="your-real-pihole-password" \
  mqtt_password="your-mqtt-password"

# Create a read-only policy for Vault Agent
podman exec vault vault policy write vault-agent-readonly - <<'EOF'
path "secret/data/network-docker" {
  capabilities = ["read"]
}
EOF

# Create a periodic token for Vault Agent
podman exec vault vault token create \
  -policy=vault-agent-readonly \
  -period=24h \
  -orphan \
  -display-name="vault-agent"

# SAVE the token value (starts with hvs.)
```

### 9. Deploy the Token and Activate Vault Agent

**Option A** — Re-run Ansible with the token:

```bash
ansible-playbook playbook.yml \
  --extra-vars "materia_age_private_key=$(cat ../../server-container/network-docker/tier2/attributes/age-key.txt)" \
  --extra-vars "vault_agent_token=hvs.YOUR_TOKEN_HERE"
```

**Option B** — Deploy manually on the server:

```bash
ssh d3strukt0r@network-docker.local

echo -n "hvs.YOUR_TOKEN_HERE" > ~/.config/vault-agent/token/vault-agent-token
chmod 600 ~/.config/vault-agent/token/vault-agent-token

# Render secrets from Vault
systemctl --user start vault-agent

# Restart services to pick up real secrets
systemctl --user start materia
```

### 10. Verify

```bash
# Check rendered secrets exist
cat ~/container-data/vault-secrets/certbot-cloudflare.ini
cat ~/container-data/vault-secrets/pihole-web-password.env
cat ~/container-data/vault-secrets/zigbee2mqtt-secret.yaml

# Check Pi-hole has the password
podman exec pihole printenv WEBPASSWORD

# Check HA stack services
systemctl --user status openthread-border-router matter-server homeassistant

# Check timers are active
systemctl --user list-timers
```

## Secrets Management

Sensitive values are managed by HashiCorp Vault and rendered to disk by Vault Agent.

### Architecture

```
Vault (KV v2)                          Source of truth for secrets
    |
Vault Agent (oneshot, every 6h)         Authenticates + renders templates
    |
~/container-data/vault-secrets/         Rendered secret files on disk
    |
Tier 2 containers                       Mount files read-only
```

Non-sensitive config (domains, IPs, container tags) remains in the age-encrypted attributes file managed by Materia.

### Current Secrets

| Secret | Vault Key | Rendered File | Used By |
|--------|-----------|---------------|---------|
| Cloudflare API token | `cloudflare_api_token` | `vault-secrets/certbot-cloudflare.ini` | Certbot (DNS-01) |
| Pi-hole web password | `pihole_web_password` | `vault-secrets/pihole-web-password.env` | Pi-hole |
| MQTT password | `mqtt_password` | `vault-secrets/zigbee2mqtt-secret.yaml` | Zigbee2MQTT |

### Rotating Secrets

```bash
ssh d3strukt0r@network-docker.local

# Update in Vault
podman exec vault vault kv put secret/network-docker \
  cloudflare_api_token="new-token" \
  pihole_web_password="new-password" \
  mqtt_password="new-mqtt-password"

# Re-render
systemctl --user start vault-agent

# Restart affected services
systemctl --user restart pihole
```

### Adding a New Secret

1. Add the key to Vault: `vault kv put secret/network-docker ... new_key=value`
2. Create a `.ctmpl` template in `tier1/vault-agent/templates/`
3. Add a `template {}` stanza to `vault-agent-config.hcl`
4. Re-run Ansible to deploy the updated config and template
5. Update the Tier 2 `.gotmpl` file to mount/reference the new rendered file
6. Commit and push; Materia picks it up on next run

## Deployment Flow

```
Local machine (Ansible control)
  |
  |-- ansible-playbook --extra-vars "materia_age_private_key=... vault_agent_token=..."
  |     |
  |     |-- Base system: packages, networking, podman, sysctl (Thread), kernel modules
  |     |-- Tier 1 (rootless): proxy.network, Vault, Vault Agent + token, Materia + age key
  |     |
  |     '-- materia update (triggered by Ansible)
  |           |
  |           |-- git clone git@github.com:D3strukt0r/server-config.git
  |           |-- Decrypt attributes/network-docker.toml (age, non-sensitive config)
  |           |-- Template *.gotmpl files with attribute values
  |           |-- Install Quadlets to ~/.config/containers/systemd/
  |           '-- Start all services (OTBR, Matter, HA, Traefik, Pi-hole, etc.)
  |
  |-- Every 6h: vault-agent-sync.timer renders fresh secrets from Vault
  '-- Daily at 04:00: materia-update.timer pulls & applies Git changes
```

## Making Changes

### Tier 2 services (all application services including HA stack)

Edit the component files locally, commit, and push. Changes are applied automatically on the next timer run (daily at 04:00), or manually:

```bash
ssh d3strukt0r@network-docker.local
systemctl --user start materia
```

### Tier 1 services (Vault, Vault Agent, Materia, proxy network)

Re-run the Ansible playbook — these are not managed by Materia.

### Updating non-sensitive config (age attributes)

```bash
# Decrypt
cd tier2/attributes
age -d -i /path/to/age-key.txt -o network-docker.toml.plain network-docker.toml

# Edit
vi network-docker.toml.plain

# Re-encrypt
age -e -R recipients -o network-docker.toml network-docker.toml.plain
rm network-docker.toml.plain

git add network-docker.toml && git commit -m "Update config" && git push
```

## Certificates

Two types of TLS certificates are used:

- **Self-signed** for `*.network-docker.local` — generated by Ansible during setup (valid 10 years), stored at `~/container-data/traefik/certs/selfsigned/`
- **Let's Encrypt** for `*.d3strukt0r.dev` — managed by Certbot via DNS-01 challenge with Cloudflare, stored at `~/container-data/traefik/certs/letsencrypt/`, renewed twice daily by `certbot-renew.timer`

## Networking

All web-facing services join the `proxy` bridge network and are accessed through Traefik. Pi-hole provides DNS resolution for the local network, including a wildcard record for `*.network-docker.local` pointing to `192.168.1.13`.

| Service       | URL                                           |
|---------------|-----------------------------------------------|
| Traefik       | `https://traefik.network-docker.local`        |
| Vault         | `https://vault.network-docker.local`          |
| Portainer     | `https://portainer.network-docker.local`      |
| Pi-hole       | `https://pihole.network-docker.local`         |
| Omada         | `https://omada.network-docker.local`          |
| Home Assistant| `https://ha.network-docker.local`             |
| OTBR          | `https://otbr.network-docker.local`           |
| Zigbee2MQTT   | `https://z2m.network-docker.local`            |

## Home Assistant Stack

The Home Assistant stack provides smart home automation with Matter-over-Thread and Zigbee support via the SLZB-MR4U dual-radio coordinator (connected via Ethernet/PoE).

### Architecture

```
ROOTLESS (Tier 2, Materia — host network)   ROOTLESS (Tier 2, Materia — proxy network)
  OTBR (:8081/:8080)                          Mosquitto (:1883)
    |                                           |
  Matter Server (:5580)                       Zigbee2MQTT (z2m.network-docker.local)
    |                                           |
  Home Assistant (:8123)  <-- MQTT/WS -->     (both connect to Mosquitto)
```

- **All services run rootless**, managed by Materia as Tier 2 components.
- **OTBR** runs with `--privileged`, `NET_ADMIN`/`SYS_ADMIN` capabilities, and `/dev/net/tun` device access. In rootless Podman, `--privileged` is safely scoped to the user namespace.
- **OTBR, Matter Server, Home Assistant** use host networking for Thread/Matter protocols.
- **Mosquitto and Zigbee2MQTT** use the proxy bridge network.
- **Traefik** routes to HA and OTBR via its file provider using `server_ip`.

### Systemd Ordering

```
User-level:  network-online.target → openthread-border-router → matter-server → homeassistant
User-level:  proxy-network → mosquitto → zigbee2mqtt
```

### Post-Deployment Setup

After the initial Ansible run and Vault initialization:

1. **Store MQTT password in Vault**:
   ```bash
   podman exec vault vault kv put secret/network-docker \
     cloudflare_api_token="..." \
     pihole_web_password="..." \
     mqtt_password="your-mqtt-password"
   ```

2. **Run Vault Agent** to render the MQTT secret:
   ```bash
   systemctl --user start vault-agent
   ```

3. **Create Mosquitto users**:
   ```bash
   podman exec -it mosquitto mosquitto_passwd -c /mosquitto/config/password_file homeassistant
   podman exec -it mosquitto mosquitto_passwd /mosquitto/config/password_file zigbee2mqtt
   systemctl --user restart mosquitto
   ```

4. **Configure Zigbee2MQTT** — edit `~/container-data/zigbee2mqtt/data/configuration.yaml`:
   ```yaml
   serial:
     port: tcp://slzb-mr4u.local:6638
   mqtt:
     server: mqtt://192.168.1.13:1883
     user: zigbee2mqtt
     password: '!secret mqtt_password'
   frontend:
     port: 8080
   ```

5. **Configure Home Assistant integrations** (in order):
   - OTBR (http://localhost:8081)
   - Thread (auto-discovered)
   - Matter (sync Thread credentials from OTBR)
   - MQTT (server: `mqtt://192.168.1.13:1883`, user: `homeassistant`)
   - Commission Matter/Thread devices via the HA mobile app

## Notes

- **Vault seals on reboot.** After a server restart, you must SSH in and unseal Vault manually. Services keep running with the last-rendered secret files on disk.
- **Vault Agent token auto-renews.** The periodic token renews each time it is used. The 6h timer schedule stays well within the 24h period.
- **Placeholder secrets on first boot.** Before Vault is initialized, Pi-hole starts with a dummy password, Certbot has a placeholder token, and Zigbee2MQTT has a dummy MQTT password. Initialize Vault and run Vault Agent to replace them with real values.
- **OTBR runs rootless with privileged hacks.** Thread mesh networking needs `NET_ADMIN`, `SYS_ADMIN`, and `/dev/net/tun`. These are granted via `--privileged` in rootless Podman (safely scoped to user namespace). System-level prerequisites (IPv6 forwarding sysctl, `ip6table_filter` module) are set up by Ansible before Materia runs.
- **Vault must be unsealed before HA stack secrets work.** After a reboot, unseal Vault first, then run `systemctl --user start vault-agent` to re-render secrets.

## Troubleshooting

```bash
# Check Vault Agent logs
journalctl --user -u vault-agent -n 50

# Check Materia logs
journalctl --user -u materia -n 50

# Check a specific service
systemctl --user status traefik
journalctl --user -u traefik -f

# List all Quadlet-managed services (rootless)
systemctl --user list-units 'traefik*' 'vault*' 'materia*' 'certbot*' 'portainer*' 'watchtower*' 'omada*' 'pihole*' 'mosquitto*' 'zigbee2mqtt*' 'openthread-border-router*' 'matter-server*' 'homeassistant*'

# Check HA stack services
systemctl --user status openthread-border-router matter-server homeassistant
journalctl --user -u openthread-border-router -n 50
journalctl --user -u matter-server -n 50
journalctl --user -u homeassistant -n 50

# List active timers
systemctl --user list-timers

# Re-run Vault Agent manually
systemctl --user start vault-agent

# Re-run Materia manually
systemctl --user start materia

# Dry-run Materia (plan without applying)
podman run --rm \
  -v ~/.local/share/materia:/var/lib/materia \
  -v ~/.config/containers/systemd:/etc/containers/systemd \
  ghcr.io/stryan/materia:stable plan
```
