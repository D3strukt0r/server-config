# Networking Server (Ansible)

Ansible playbooks for configuring the home networking server VM (Debian on Proxmox VE).

## Prerequisites

- Lenovo ThinkCentre M720q or similar
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/) installed on your local machine
  - On Windows, use WSL: `wsl --install --distribution Debian` & `sudo apt update && sudo apt install -y ansible`
  - Then adjust permissions, since the `ansible.cfg` cannot be world-writable (777). `printf '\n[automount]\noptions = "metadata,umask=022"\n' | sudo tee -a /etc/wsl.conf` & `wsl --shutdown` to apply.
- SSH key access to the VM (see [Home Server Setup](../README.md))

## Setup Lenovo ThinkCentre M720q

Ensure latest BIOS is installed from [Lenovo Support](https://pcsupport.lenovo.com/ch/de/products/desktops-and-all-in-ones/thinkcentre-m-series-desktops/m720q/downloads/ds503907?category=BIOS) (currently M1UKT78A/1.0.0.120/05.01.2026) ([Instructions and Changelog](https://download.lenovo.com/pccbbs/thinkcentre_bios/m1ujy78usa.txt)) and ensure Intel VT-d is enabled in the BIOS.

Install Proxmox VE from [Proxmox VE Download](https://www.proxmox.com/en/downloads/category/iso-images-pve) and set up the home server with Proxmox VE.

For a Mirrored Boot Drive either use a PCIe card with a M.2 slot, or get the M920q instead.

During setup in networking insert following:

- Management Interface: `nic0/eno1` (Wired)
- Hostname (FQDN): `network-server.local`
- IP Address: `192.168.1.12/24`
- Gateway: `192.168.1.1`
- DNS Server: `192.168.1.1`

Run `PVE Post Install` from Proxmox VE Helper-Scripts from [Proxmox VE Helper-Scripts](https://github.com/community-scripts/ProxmoxVE) to setup the node.

```shell
bash -c "$(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/tools/pve/post-pve-install.sh)"
```

Add one VM for Home Assistant and one VM for all the other Docker containers including Pi-hole.

Check the [latest Debian ISO](https://cdimage.debian.org/debian-cd/current/amd64/iso-dvd/) (or [Switzerland mirror](https://debian.ethz.ch/debian-cd/13.3.0/amd64/iso-dvd/)) for the VMs and download the ISO to the `local` storage in Proxmox VE.

In the `System` step: Also check the `Qemu Agent` checkbox for better reporting of the VMs in Proxmox VE.

In the `Disks` step: Enable `Discard` for better performance and less wear on the SSD, as well as `SSD emulation` for better performance.

In the `CPU` step: Set Cores to `5`, (Maybe) Set the `Type` to `host` for better performance (if the VM is never migrated to other Hardware).

In the `Memory` step: Set Memory to `10240` MiB and minimum memory to `2048` MiB.

In the `Network` step: Set the `Multiqueue` option to `5` for better performance (might be negligible).

During setup only have one ext4 disk and remove Swap, we will handle it later with a swapfile on the root disk.

During installation of Debian, select `SSH server` and `standard system utilities` in the software selection step.

Install sudo and add the user to the sudo group for easier administration.

```shell
su -
apt update
apt install -y sudo
usermod -aG sudo d3strukt0r
```

Send ssh keys to the VM for easier access and better security.

```shell
ssh-copy-id d3strukt0r@192.168.1.73
# or on Windows with PowerShell
type $env:USERPROFILE\.ssh\id_ed25519.pub | ssh d3strukt0r@192.168.1.73 "mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat >> .ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
```

## Usage

Run from this directory:

```shell
ansible-playbook playbook.yml --ask-become-pass
```

To check what would change without applying:

```shell
ansible-playbook playbook.yml --ask-become-pass --check --diff
```

## What it configures

- **Swap**: Creates a 2GB swapfile at `/swapfile` and adds it to `/etc/fstab`
