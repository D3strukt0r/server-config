#!/bin/bash
set -e -u -o pipefail

# Script dir (https://stackoverflow.com/a/246128/4156752)
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# For Copilot:
# - Use bash brackets [[ ]]
# - Use $(command) instead of `command`
# - Never use 'apt', use alternatives like 'apt-get' or 'aptitude'
# - When possible use '' instead of ""

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
  if [ "$ID" != 'debian' ] && [ "$ID" != 'ubuntu' ]; then
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

# Do a full system update
echo_info 'Doing a full system update...'
apt-get update
apt-get dist-upgrade --yes

# Install utilies (in a loop, check if they are installed first (using "dpkg-query -W -f='${Status} ${Version}\n' <package>"), and then install)
# - ncdu: Manage disk usage
# - bmon, tcptrack, net-tools: Network monitoring
#     https://askubuntu.com/questions/257263/how-to-display-network-traffic-in-the-terminal
# - jq: JSON parser
# - git: Version control
# - ca-certificates, curl, gnupg: Dependencies for docker
# - docker: Container runtime
echo_info 'Installing some utilities...'

function install_package() {
  if ! dpkg-query -W -f='${Status} ${Version}\n' "$1" &> /dev/null; then
    echo_info "Installing $1..."
    apt-get install --yes "$1"
  else
    echo_skip "$1 is already installed."
  fi
}

install_package ncdu
install_package bmon
install_package tcptrack
install_package net-tools
install_package jq
install_package git
install_package ca-certificates
install_package curl
install_package gnupg

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
install_package docker-ce
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

# TODO: Check if swapsize doesn't match and update
#if [[ $(free --human --giga | grep Swap | awk '{print $2}') != "$SWAP_SIZE" ]]; then
#  echo_info 'Updating swap file size...'
#  swapoff /swapfile
#  fallocate -l "$SWAP_SIZE" /swapfile
#  mkswap /swapfile
#  swapon /swapfile
#else
#  echo_skip 'Swap file size is already correct.'
#fi

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
if [[ ! -L /usr/local/bin/ctop ]]; then
  echo_info 'Linking ctop...'
  ln --symbolic --force $SCRIPT_DIR/ctop /usr/local/bin/ctop
else
  echo_skip 'ctop is already linked.'
fi

# Login to Docker Hub
if [[ $(docker system info | grep 'Username') == '' ]]; then
  echo_info 'Logging in to Docker Hub...'
  docker login
else
  echo_skip 'Already logged in to Docker Hub.'
fi
