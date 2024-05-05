# Server configuration with Docker Compose

My server configuration without any secrets.

[![License -> GitHub](https://img.shields.io/github/license/D3strukt0r/server-config?label=License)](LICENSE.txt)
[![Static Badge](https://img.shields.io/badge/Contributor%20Covenant-2.0-4baaaa)](CODE_OF_CONDUCT.md)

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for deployment purposes.

### Prerequisites

What things you need to install the software and how to install them

* [Debian based OS](https://www.debian.org/)

### Setup

* Add SSH Key from 1Password Backup (SSH-Key (Ed25519)) and place in `~/.ssh/`

* If not yet done, backup GPG Private key and place in `~/private.gpg`

```shell
gpg --export-secret-keys --export-options export-backup --armor --output private.gpg jane.smith@email.com
```

* Download and run script from GitHub (repo: D3strukt0r/server-config, branch: master, path: bin/setup.sh)

```shell
wget -O - https://raw.githubusercontent.com/D3strukt0r/server-config/master/bin/setup.sh | bash
```

* Enter Git info:

```shell
git config --global user.name 'D3strukt0r'
git config --global user.email 'dev@d3strukt0r.me'
git config --global user.signingkey 'C9E5AB85364CA764!'
```

* Login to Docker

```shell
echo '<Personal Access Token (PAT)>' | docker login --username d3strukt0r --password-stdin
```

### Verify downloaded images with cosign (example)

```shell
wget https://artifacts.elastic.co/cosign.pub
cosign verify --key cosign.pub docker.elastic.co/elasticsearch/elasticsearch:8.10.2
```

### Maintenance

#### Clear storage

```shell
docker system prune
```

#### Backup

Following command backups all git ignored files (e.g. `./traefik/acme.json`)

```shell
git clean -dxn | sed 's/^Would remove \(.*\)/\1/g' | tar -czvf backup.tar.gz -T -
```

#### Restore

Following command restores all git ignored files (e.g. `./traefik/acme.json`)

```shell
tar -xzvf backup.tar.gz
```

#### Complete Start/Stop

Start and stop all services except fluentd which is started first and stopped last.

```shell
(cd fluentd && docker compose up -d)
for dir in $(ls -d */ | grep -v -E '^(\.git|\.github|backup|bin|fluentd)'); do
  (cd $dir && docker compose up -d)
done
```

```shell
for dir in $(ls -d */ | grep -v -E '^(\.git|\.github|backup|bin|fluentd)'); do
  (cd $dir && docker compose down)
done
(cd fluentd && docker compose down)
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
