# Server configuration with Docker Compose

My server configuration without any secrets.

[![License -> GitHub](https://img.shields.io/github/license/D3strukt0r/server-config?label=License)](LICENSE.txt)
[![Static Badge](https://img.shields.io/badge/Contributor%20Covenant-2.0-4baaaa)](CODE_OF_CONDUCT.md)

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for deployment purposes.

### Prerequisites

What things you need to install the software and how to install them

* [Debian based OS](https://www.debian.org/)
* [Docker](https://www.docker.com/)
* [Docker Compose](https://docs.docker.com/compose/)
* [Git](https://git-scm.com/)
* [GPG](https://gnupg.org/)

### Setup

* Update the System

```shell
apt update
apt dist-upgrade -y
```

* Install Docker

```shell
apt install ca-certificates curl gnupg
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
apt update
apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

* Boot Docker on start

```shell
systemctl enable docker.service
systemctl enable containerd.service
```

* Stop existing nginx instance on host (so it doesn't interfere with Traefik)

```shell
systemctl stop nginx
systemctl disable nginx
```

* Login to Docker

```shell
docker login -u d3strukt0r
```

* Add SSH Key from 1Password Backup (SSH-Key (Ed25519)) and place in `~/.ssh/`

* Then fix the private key permissions

```shell
chmod 600 ~/.ssh/id_ed25519
```

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

### Backup

Following command backups all git ignored files (e.g. `./traefik/acme.json`)

```shell
git clean -dxn | sed 's/^Would remove \(.*\)/\1/g' | tar -czvf backup.tar.gz -T -
```

### Restore

Following command restores all git ignored files (e.g. `./traefik/acme.json`)

```shell
tar -xzvf backup.tar.gz
```

## Built With

* [Docker](https://www.docker.com/)

## Contributing

Please read [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) for details on our code of conduct, and [CONTRIBUTING.md](CONTRIBUTING.md) for the process for submitting pull requests to us.

## Versioning

We use [SemVer](https://semver.org/) for versioning. For the versions available, see the [tags on this repository][gh-tags].

## Authors

All the authors can be seen in the [AUTHORS.md](AUTHORS.md) file.

Contributors can be seen in the [CONTRIBUTORS.md](CONTRIBUTORS.md) file.

See also the full list of [contributors][gh-contributors] who participated in this project.

## License

This project is licensed under the MIT License - see the [LICENSE.txt](LICENSE.txt) file for details

## Acknowledgments

A list of used libraries and code with their licenses can be seen in the [ACKNOWLEDGMENTS.md](ACKNOWLEDGMENTS.md) file.

[gh-releases]: https://github.com/D3strukt0r/server-config/releases
[gh-tags]: https://github.com/D3strukt0r/server-config/tags
[gh-contributors]: https://github.com/D3strukt0r/server-config/graphs/contributors
