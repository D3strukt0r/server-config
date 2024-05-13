#!/bin/bash
set -e -u -o pipefail

# For Copilot:
# - Use bash brackets [[ ]]
# - Use $(command) instead of `command`
# - Never use 'apt', use alternatives like 'apt-get' or 'aptitude'
# - When possible use '' instead of ""

# Default values
: "${SKIP_UPDATE:=false}"
: "${VOLUME_DIR:=/mnt/volume_fra1_01}"
: "${SWAP_SIZE:=1G}"

# Custom echo function to output '*blue*[INFO]*reset* message'
function echo_info() {
    echo -e "\e[34m[INFO]\e[0m $1"
}
# Custom echo function to output '*yellow*[SKIP]*reset* message'
function echo_skip() {
     echo -e "\e[33m[SKIP]\e[0m $1"
}

# Check with /etc/os-release if the OS is using a Debian based system
if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    if [[ "$ID" != 'debian' ]] && [[ "$ID" != 'ubuntu' ]]; then
        echo_info "This script is only tested on Debian and Ubuntu. Your OS is $ID, which is not supported."
        exit 1
    fi
else
    echo_info 'This script is only tested on Debian, Ubuntu. Your OS is not supported.'
    exit 1
fi

# Check if this script is run as root
if [[ $EUID -ne 0 ]]; then
    echo_info 'This script must be run as root.'
    exit 1
fi

# https://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash
POSITIONAL_ARGS=()
while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--dir)
            VOLUME_DIR="$2"
            shift # past argument
            shift # past value
        ;;
        -l|--skip-update)
            SKIP_UPDATE=true
            shift # past argument
            ;;
        -*|--*)
            echo "Unknown option $1"
            exit 1
            ;;
        *)
            POSITIONAL_ARGS+=("$1") # save positional arg
            shift # past argument
            ;;
    esac
done
set -- "${POSITIONAL_ARGS[@]}" # restore positional parameters

# Check BASH_SOURCE as it might be wrong when using curl or wget
if [[ -z ${BASH_SOURCE+x} ]] || [[ $BASH_SOURCE == /dev/fd/* ]]; then
    # wget -q -O - <url>.sh | bash -s - <parameters>
    # wget -q -O - <url>.sh | ENV=VALUE bash
    # curl -s <url>.sh | bash -s - <parameters>
    # will result in: BASH_SOURCE: unbound variable
    # bash <(curl -s <url>.sh)
    # will result in: BASH_SOURCE = /dev/fd/<number>

    if [[ -z "$VOLUME_DIR" ]]; then
        echo_info "We cant figure out where to save the repository. Please provide the directory with -d or --dir"
        exit 1
    else
        SCRIPT_DIR=$VOLUME_DIR/server/bin
    fi
else
    # Script dir (https://stackoverflow.com/a/246128/4156752)
    SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
fi

# Helper functions to reduce code duplication
function install_package() {
    if ! dpkg-query -W -f='${Status} ${Version}\n' "$1" &> /dev/null; then
        echo_info "Installing $1..."
        apt-get install --yes "$1"
    else
        echo_skip "$1 is already installed."
    fi
}
function ensure_in_group() {
    if [[ $(groups $1 | grep $2) == '' ]]; then
        echo_info "Adding $1 to $2 group..."
        usermod --append --groups $2 $1
    else
        echo_skip "$1 is already in $2 group."
    fi
}

### BEGIN SETUP ###

# Do a full system update (unless --skip-update is given)
if [[ "$SKIP_UPDATE" == 'false' ]]; then
    echo_info 'Doing a full system update...'
    apt-get update
    apt-get dist-upgrade --yes
else
    echo_skip 'Skipping system update.'
fi

# Install utilies (in a loop, check if they are installed first (using "dpkg-query -W -f='${Status} ${Version}\n' <package>"), and then install)
# - bmon, tcptrack, net-tools: Network monitoring
#     https://askubuntu.com/questions/257263/how-to-display-network-traffic-in-the-terminal
install_package ncdu # Manage disk usage
install_package bmon
install_package tcptrack
install_package net-tools
install_package jq # JSON parser
install_package git # Version control
install_package ca-certificates # Dependency for docker
install_package curl # Dependency for docker
install_package gnupg # To verify git commits, Dependency for docker
install_package apache2-utils # for htpasswd command to add users to .htpasswd file
install_package unzip # Was needed for setting up bitwarden first time
install_package htop # Better top

# Clone from GitHub (D3strukt0r/server-config) to $VOLUME_DIR/server
if [[ -f ~/.ssh/id_ed25519 ]] && [[ -f ~/.ssh/id_ed25519.pub ]]; then
    if [[ ! -d "$VOLUME_DIR/server" ]]; then
        echo_info 'Cloning server-config...'
        git clone git@github.com:D3strukt0r/server-config.git "$VOLUME_DIR/server"
    else
        echo_skip 'server-config is already cloned.'
    fi
else
    echo_info 'SSH key is not set up, skipping cloning server-config.'
fi

# If '/etc/apt/keyrings/docker.gpg' doesn't exist, set it up
if [[ ! -f /etc/apt/keyrings/docker.gpg ]]; then
  echo_info 'Setting up docker keyring...'
  install -m 0755 -d /etc/apt/keyrings
  curl --fail --silent --show-error --location https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor >/etc/apt/keyrings/docker.gpg
  chmod a+r /etc/apt/keyrings/docker.gpg
else
  echo_skip 'Docker keyring is already set up.'
fi
# If '/etc/apt/sources.list.d/docker.list' doesn't exist, set it up
if [[ ! -f /etc/apt/sources.list.d/docker.list ]]; then
  echo_info 'Setting up docker sources...'
  echo \
    "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
    tee /etc/apt/sources.list.d/docker.list >/dev/null
  apt-get update
else
  echo_skip 'Docker sources are already set up.'
fi
install_package docker-ce # Container runtime
install_package docker-ce-cli
install_package containerd.io
install_package docker-buildx-plugin
install_package docker-compose-plugin

# Create '/etc/docker/daemon.json' if it doesn't exist
if [[ ! -f /etc/docker/daemon.json ]]; then
  echo_info 'Creating docker daemon config...'
  mkdir --parents /etc/docker
  echo '{}' | tee /etc/docker/daemon.json >/dev/null
else
  echo_skip 'Docker daemon config is already set up.'
fi
# Check if '/etc/docker/daemon.json' has no content, because jq requires at least a '{}'
if [[ $(cat /etc/docker/daemon.json) == '' ]]; then
  echo_info 'Docker daemon config is empty, setting up...'
  echo '{}' | tee /etc/docker/daemon.json >/dev/null
else
  echo_skip 'Docker daemon config is not empty.'
fi

# Using jq add 'data-root => $VOLUME_DIR/docker-data'
if [[ ! -d "$VOLUME_DIR/docker-data" ]]; then
  echo_info 'Creating docker data root...'
  mkdir --parents "$VOLUME_DIR/docker-data"
else
  echo_skip 'Docker data root is already created.'
fi
if [[ $(jq '.["data-root"]' /etc/docker/daemon.json) != "\"$VOLUME_DIR/docker-data\"" ]]; then
  echo_info 'Setting up docker data root...'
  jq ".[\"data-root\"] = \"$VOLUME_DIR/docker-data\"" /etc/docker/daemon.json | tee /etc/docker/daemon.json.tmp >/dev/null
  mv /etc/docker/daemon.json.tmp /etc/docker/daemon.json
  systemctl restart docker
else
  echo_skip 'Docker data root is already set up.'
fi

# Boot docker and containerd on startup
if [[ $(systemctl is-enabled docker) != 'enabled' ]]; then
  echo_info 'Enabling docker on startup...'
  systemctl enable docker
else
  echo_skip 'Docker is already enabled on startup.'
fi
if [[ $(systemctl is-enabled containerd) != 'enabled' ]]; then
  echo_info 'Enabling containerd on startup...'
  systemctl enable containerd
else
  echo_skip 'Containerd is already enabled on startup.'
fi

# https://www.digitalocean.com/community/tutorials/how-to-add-swap-space-on-debian-11
# Setup Swap file it not yet done
if [[ ! -f '/swapfile' ]]; then
  # TODO: Check if we have enough space using df
  #if [[ $(df --output=avail --human / | tail -n 1) -lt "$SWAP_SIZE" ]]; then
  #  echo_info "Not enough space on $VOLUME_DIR to create a swap file of $SWAP_SIZE."
  #  exit 1
  #fi

  echo_info 'Setting up swap file...'
  fallocate --length "$SWAP_SIZE" /swapfile
  chmod 600 /swapfile
  mkswap /swapfile
  swapon /swapfile
  echo '/swapfile none swap sw 0 0' | tee -a /etc/fstab >/dev/null
else
  echo_skip 'Swap file is already set up.'
fi

# Check if swapsize doesn't match and update
# Read manual https://linuxhandbook.com/increase-swap-ubuntu/
# Issue: fallocate uses G while free prints X.0Gi
_target_swap_size=$(echo "$SWAP_SIZE" | grep -o '[0-9.]\+')
_target_swap_size=$(bc -l <<< "scale=1; ${_target_swap_size} * 1.0")
_current_swap_size=$(free --human --gibi | grep Swap | awk '{print $2}' | grep -o '[0-9.]\+')
_current_swap_size=$(bc -l <<< "scale=1; ${_current_swap_size} * 1.0")
if [[ "$_current_swap_size" != "$_target_swap_size" ]]; then
    echo_info 'Updating swap file size...'
    swapoff /swapfile
    rm /swapfile # Decreasing swap requires deleting the file
    fallocate --length "$SWAP_SIZE" /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    # Check with `free -h`
else
    echo_skip 'Swap file size is already correct.'
fi

# Check swapiness, and recude value to only use it when absolutely necessary
if [[ $(cat /proc/sys/vm/swappiness) != '10' ]]; then
  echo_info 'Setting up swapiness...'
  sysctl vm.swappiness=10 >/dev/null
  echo 'vm.swappiness=10' | tee -a /etc/sysctl.conf >/dev/null
  #sysctl --load /etc/sysctl.conf
else
  echo_skip 'Swapiness is already set up.'
fi
# Reduce cache pressure to 50%
if [[ $(cat /proc/sys/vm/vfs_cache_pressure) != '50' ]]; then
  echo_info 'Setting up vfs cache pressure...'
  sysctl vm.vfs_cache_pressure=50 >/dev/null
  echo 'vm.vfs_cache_pressure=50' | tee -a /etc/sysctl.conf >/dev/null
  #sysctl --load /etc/sysctl.conf
else
  echo_skip 'Vfs cache pressure is already set up.'
fi

# Setup Git parameters if not set already
# Check user.email and ask from user
if [[ $(git config --global user.email) == '' ]]; then
  echo_info 'Setting up git user.email...'
  read -p 'Enter your git user.email: ' git_user_email
  git config --global user.email "$git_user_email"
else
  echo_skip 'Git user.email is already set up.'
fi
# Check user.name and ask from user
if [[ $(git config --global user.name) == '' ]]; then
  echo_info 'Setting up git user.name...'
  read -p 'Enter your git user.name: ' git_user_name
  git config --global user.name "$git_user_name"
else
  echo_skip 'Git user.name is already set up.'
fi
# Check init.defaultBranch and set to master
if [[ $(git config --global init.defaultBranch) != 'master' ]]; then
  echo_info 'Setting up git init.defaultBranch...'
  git config --global init.defaultBranch master
else
  echo_skip 'Git init.defaultBranch is already set up.'
fi

# Check if GPG key has been imported
if [[ ! -f ~/private.gpg ]] && [[ $(gpg --list-secret-keys | grep 'sec') == '' ]]; then
  echo_info 'Importing GPG key...'
  gpg --import-options import-restore --import ~/private.gpg
else
  echo_skip 'GPG key is already imported.'
fi
if [[ $(gpg --list-secret-keys | grep 'sec') != '' ]]; then
  # Check commit.gpgsign and set to true
  if [[ $(git config --global commit.gpgsign) != 'true' ]]; then
    echo_info 'Setting up git commit.gpgsign...'
    git config --global commit.gpgsign true
  else
    echo_skip 'Git commit.gpgsign is already set up.'
  fi
  # Check user.signingkey and ask from user
  if [[ $(git config --global user.signingkey) == '' ]]; then
    echo_info 'Setting up git user.signingkey...'
    read -p 'Enter your git user.signingkey: ' git_user_signingkey
    git config --global user.signingkey "$git_user_signingkey"
  else
    echo_skip 'Git user.signingkey is already set up.'
  fi
else
  echo_info 'GPG key is not imported, skipping git commit.gpgsign and git user.signingkey.'
fi

# Link ../backup to $VOLUME_DIR/backup
if [[ ! -L "$SCRIPT_DIR/../backup" ]]; then
  echo_info 'Linking backup folder...'
  ln --symbolic --force "$VOLUME_DIR/backup" "$SCRIPT_DIR/../backup"
else
  echo_skip 'Backup folder is already linked.'
fi

# Add 'backup-daily.sh', 'backup-weekly.sh' and 'backup-monthly.sh' to crontab
# - Execute the daily backup script everyday at 12:15 AM
# - Execute the weekly backup script every Monday at 12:30 AM
# - Execute the monthly backup script the 1st of every month at 12:45 AM
# - Execute the docker prune script everyday at 12:10 AM
# The first one must check for the 'no crontab for root' error
if [[ $(crontab -l 2>/dev/null | grep 'backup-daily.sh') == '' ]]; then
  echo_info 'Adding daily backup to crontab...'
  (crontab -l 2>/dev/null || true; echo '15 0 * * * '"$SCRIPT_DIR/backup-daily.sh 2>&1 | tee -a $SCRIPT_DIR/../backup/cron.log") | crontab -
else
  echo_skip 'backup-daily.sh is already added to crontab.'
fi
if [[ $(crontab -l | grep backup-weekly.sh) == '' ]]; then
  echo_info 'Adding backup-weekly.sh to crontab...'
  (crontab -l 2>/dev/null; echo '30 0 * * 1 '"$SCRIPT_DIR/backup-weekly.sh 2>&1 | tee -a $SCRIPT_DIR/../backup/cron.log") | crontab -
else
  echo_skip 'backup-weekly.sh is already in crontab.'
fi
if [[ $(crontab -l | grep backup-monthly.sh) == '' ]]; then
  echo_info 'Adding backup-monthly.sh to crontab...'
  (crontab -l 2>/dev/null; echo '45 0 1 * * '"$SCRIPT_DIR/backup-monthly.sh 2>&1 | tee -a $SCRIPT_DIR/../backup/cron.log") | crontab -
else
  echo_skip 'backup-monthly.sh is already in crontab.'
fi
if [[ $(crontab -l | grep docker-prune.sh) == '' ]]; then
  echo_info 'Adding docker-prune.sh to crontab...'
  (crontab -l 2>/dev/null; echo '10 0 * * * '"$SCRIPT_DIR/docker-prune.sh 2>&1 | tee -a $SCRIPT_DIR/../backup/cron.log") | crontab -
else
  echo_skip 'docker-prune.sh is already in crontab.'
fi

# Link ctop to /usr/local/bin/ctop (https://github.com/bcicen/ctop)
CTOP_SHIM_CONTENT=$(cat <<"EOF"
#!/bin/sh
set -e -u
docker run --rm -ti \
  --name=ctop \
  --volume /var/run/docker.sock:/var/run/docker.sock:ro \
  quay.io/vektorlab/ctop:latest
EOF
)
if [[ ! -f /usr/local/bin/ctop ]] || [[ $(cat /usr/local/bin/ctop) != "$CTOP_SHIM_CONTENT" ]]; then
  echo_info 'Creating ctop shim...'
  echo "$CTOP_SHIM_CONTENT" | tee /usr/local/bin/ctop >/dev/null
  chmod +x /usr/local/bin/ctop
else
  echo_skip 'ctop shim is already created.'
fi

# Hadolint script (https://github.com/hadolint/hadolint)
HADOLINT_SHIM_CONTENT=$(cat <<"EOF"
#!/bin/sh
set -e -u
dockerfile="$1"
shift
docker run --rm -i hadolint/hadolint hadolint "$@" - < "$dockerfile"
EOF
)
if [[ ! -f /usr/local/bin/hadolint ]] || [[ $(cat /usr/local/bin/hadolint) != "$HADOLINT_SHIM_CONTENT" ]]; then
  echo_info 'Creating hadolint shim...'
  echo "$HADOLINT_SHIM_CONTENT" | tee /usr/local/bin/hadolint >/dev/null
  chmod +x /usr/local/bin/hadolint
else
  echo_skip 'hadolint shim is already created.'
fi

# Login to Docker Hub
if [[ $(docker system info | grep 'Username') == '' ]]; then
  echo_info 'Logging in to Docker Hub...'
  docker login
else
  echo_skip 'Already logged in to Docker Hub.'
fi

# Install start/stop script for services in /etc/init.d/
if [[ ! -f /etc/init.d/docker-services ]]; then
  echo_info 'Installing docker-services script...'
  cp "$SCRIPT_DIR/docker-services.sh" /etc/init.d/docker-services
  update-rc.d docker-services defaults
else
  echo_skip 'docker-services script is already installed.'
fi
# If script content change (check with cmp), update the script and systemctl
if [[ $(cmp /etc/init.d/docker-services "$SCRIPT_DIR/docker-services.sh") ]]; then
  echo_info 'Updating docker-services script...'
  cp "$SCRIPT_DIR/docker-services.sh" /etc/init.d/docker-services
  systemctl daemon-reload
else
  echo_skip 'docker-services script is already up-to-date.'
fi

# Ensure defaults config is correctly configured (/etc/default/docker-services)
SERVICE_DEFAULTS_CONTENT=$(cat <<"EOF"
# Create defaults file for service
# Docker SysVinit configuration file

#
# THIS FILE DOES NOT APPLY TO SYSTEMD
#
#   Please see the documentation for "systemd drop-ins":
#   https://docs.docker.com/engine/admin/systemd/
#

# To manage different subsets of services on different machines
SERVER_ENVIRONMENT="digitalocean"

# Where is this repo on the system
REPO_DIR="$REPO_DIR"
EOF
)
SERVICE_DEFAULTS_CONTENT="${SERVICE_DEFAULTS_CONTENT/\$REPO_DIR/$(dirname "$SCRIPT_DIR")}"
if [[ ! -f /etc/default/docker-services ]] || [[ $(cat /etc/default/docker-services) != "$SERVICE_DEFAULTS_CONTENT" ]]; then
  echo_info 'Setting up docker-services defaults...'
  echo "$SERVICE_DEFAULTS_CONTENT" | tee /etc/default/docker-services >/dev/null
else
  echo_skip 'docker-services defaults are already set up.'
fi

# Create a new personal user
if [[ $(id -u d3strukt0r 2>/dev/null) == '' ]]; then
  echo_info 'Creating a new user (d3strukt0r)...'
  useradd --create-home --shell /bin/bash d3strukt0r
  passwd d3strukt0r
else
  echo_skip 'User d3strukt0r is already created.'
fi
# Ensure that user belongs to sudo and docker group
ensure_in_group d3strukt0r sudo
ensure_in_group d3strukt0r docker

# Gitea Setup (requires git user)
# https://docs.gitea.com/installation/install-with-docker#sshing-shim-with-authorized_keys
# Check git user exists
if [[ $(id -u git 2>/dev/null) == '' ]]; then
  echo_info 'Creating a new user (git)...'
  useradd --create-home --shell /bin/bash git
  passwd git
else
  echo_skip 'User git is already created.'
fi
# Ensure that user belongs to docker group
ensure_in_group git docker
# Check SSH key for talking between host and container (no password!)
if [[ ! -f /home/git/.ssh/id_ed25519 ]]; then
  echo_info 'Setting up Gitea SSH key...'
  sudo -u git ssh-keygen -f /home/git/.ssh/id_ed25519 -t ed25519 -C "Gitea Host Key"
else
  echo_skip 'Gitea SSH key is already set up.'
fi
# Ensure the generated ssh key is contained the authorized_keys with grep or if file doesn't exist
if [[ ! -f /home/git/.ssh/authorized_keys ]] || [[ $(cat /home/git/.ssh/authorized_keys | grep "$(cat /home/git/.ssh/id_ed25519.pub)") == '' ]]; then
  echo_info 'Adding Gitea public key to authorized_keys...'
  sudo -u git cat /home/git/.ssh/id_ed25519.pub | sudo -u git tee -a /home/git/.ssh/authorized_keys >/dev/null
else
  echo_skip 'Gitea public key is already in authorized_keys.'
fi

# Save file content in variable and check if SSHing Shim in /usr/local/bin/gitea
# doesn't exist yet or if content doesn't match
GITEA_SHIM_CONTENT=$(cat <<"EOF"
#!/bin/sh
set -e -u
ssh -p 2222 -o StrictHostKeyChecking=no git@127.0.0.1 "SSH_ORIGINAL_COMMAND=\"$SSH_ORIGINAL_COMMAND\" $0 $@"
EOF
)
if [[ ! -f /usr/local/bin/gitea ]] || [[ $(cat /usr/local/bin/gitea) != "$GITEA_SHIM_CONTENT" ]]; then
  echo_info 'Creating Gitea SSHing Shim...'
  echo "$GITEA_SHIM_CONTENT" | sudo tee /usr/local/bin/gitea >/dev/null
  chmod +x /usr/local/bin/gitea
else
  echo_skip 'Gitea SSHing Shim is already created.'
fi
