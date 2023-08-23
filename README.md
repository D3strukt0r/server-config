# Server configuration with Docker Compose

## Setup

* Add SSH Key from 1Password Backup (SSH-Key (Ed25519)) and place in `~/.ssh/`
* If not yet done, backup GPG Private key

```shell
gpg --export-secret-keys --export-options export-backup --armor --output private.gpg jane.smith@email.com
```

* Then import on the server

```shell
gpg --import-options import-restore --import private.gpg
```

* Setup Git

```shell
git config --global user.email dev@d3strukt0r.me
git config --global user.name D3strukt0r
git config --global user.signingkey C9E5AB85364CA764!
git config --global init.defaultBranch master
git config --global commit.gpgsign true
```

* Clone this repo to the server (in home directory `/root/x`)

```shell
git clone git@github.com:D3strukt0r/server-config.git ~/server
```

* Stop existing nginx instance on host (so it doesn't interfere with Traefik)

```shell
systemctl stop nginx
```

* Add Docker network for Traefik

```shell
docker network create traefik_proxy
```

* Add acme store for Let's Encrypt with Traefik (Requires 600 permission)

```shell
touch ./traefik/acme.json
chmod 600 ./traefik/acme.json
```

* Copy `.env.dist` to `.env` (`cp .env.dist .env`) and fill with info from 1Password Backup (Traefik | Prod | Config)

## Backup

Following command backups all git ignored files (e.g. `./traefik/acme.json`)

```shell
git clean -dxn | sed 's/^Would remove \(.*\)/\1/g' | tar -czvf backup.tar.gz -T -
```

## Restore

Following command restores all git ignored files (e.g. `./traefik/acme.json`)

```shell
tar -xzvf backup.tar.gz
```
