# Server configuration with Docker Compose

My server configuration without any secrets.

[![License](https://img.shields.io/github/license/d3strukt0r/server-config?label=License)](LICENSE.txt)
[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-2.0-4baaaa)][code-of-conduct]

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
wget -q -O - https://raw.githubusercontent.com/D3strukt0r/server-config/master/bin/setup.sh | bash

# How to pass parameters
wget -q -O - https://raw.githubusercontent.com/D3strukt0r/server-config/master/bin/setup.sh | bash -s - <parameters>
wget -q -O - https://raw.githubusercontent.com/D3strukt0r/server-config/master/bin/setup.sh | ENV=VALUE bash

# Using curl
curl -s https://raw.githubusercontent.com/D3strukt0r/server-config/master/bin/setup.sh | bash
curl -s https://raw.githubusercontent.com/D3strukt0r/server-config/master/bin/setup.sh | bash -s - <parameters>
curl -s https://raw.githubusercontent.com/D3strukt0r/server-config/master/bin/setup.sh | ENV=VALUE bash
bash <(curl -s https://raw.githubusercontent.com/D3strukt0r/server-config/master/bin/setup.sh)
```

* Enter Git info:

```shell
git config --global user.name 'D3strukt0r'
git config --global user.email 'dev@d3strukt0r.dev'
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

#### Start/Stop

A script is installed so the system automatically starts/stops containers on boot
and shutdown. To manually run it, call `service docker-services {start|stop}`.

#### Check available file system

```shell
df -a -T -h
```

example:

```
Filesystem     Type         Size  Used Avail Use% Mounted on
...
/dev/vda1      ext4          34G  8.8G   25G  27% /
...
/dev/sda       ext4         100G   18G   77G  19% /mnt/volume_fra1_01
...
```

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

#### Using OpenTofu

When adding providers, add them for all platforms

```shell
tofu providers lock \
  -platform=linux_arm64 \
  -platform=linux_amd64 \
  -platform=darwin_amd64 \
  -platform=windows_amd64
```

## Built With

* [Docker](https://www.docker.com/)

## Contributing

Please read [CONTRIBUTING.md][contributing] for details on our code of conduct and the process for submitting pull requests.

This project uses [Conventional Commits](https://www.conventionalcommits.org/).

## Authors

### Special thanks for all the people who had helped this project so far

- **Manuele** - [D3strukt0r](https://github.com/D3strukt0r)

See also the full list of [contributors][gh-contributors] who participated in this project.

### I would like to join this list. How can I help the project?

We're currently looking for contributions for the following:

- [ ] Bug fixes
- [ ] Translations
- [ ] etc...

For more information, please refer to our [CONTRIBUTING.md][contributing] guide.

## License

This project is licensed under the MIT License - see the [LICENSE.txt](LICENSE.txt) file for details.

## Acknowledgments

This project currently uses no third-party libraries or copied code.

[gh-contributors]: https://github.com/D3strukt0r/server-config/graphs/contributors
[contributing]: https://github.com/D3strukt0r/.github/blob/master/CONTRIBUTING.md
[code-of-conduct]: https://github.com/D3strukt0r/.github/blob/master/CODE_OF_CONDUCT.md
