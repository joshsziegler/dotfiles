#!/bin/bash
#
# Author:  Josh Ziegler
# Date:    2020-05-19
# Updated: 2024-02-20
# License: MIT
#
# This script configures Ubuntu 22.04 to my baseline by installing packages and
# changing several default configs. I use a bare Git repository to manage my
# dotfiles which can be checked out as so:
#
#     cd ~
#     git clone --bare <git-repo-url> $HOME/.cfg
#     alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
#     config checkout
#
# Notes:
#
# I use `sed -i` to replace *existing config lines* with new values. The
# example below replaces all instances of FOO with BAR in FilePath:
#
#     sudo sed -i 's/FOO/BAR/g' FilePath
#
# To create or append to files, that require sudo, the above `sed` method
# doesn't work because of the pipe/output redirection.
#
# Create NEW file with FOO at FilePath
#
#     echo 'FOO' | sudo tee FilePath #
#
# Append FOO to file at FilePath
#
#     echo 'FOO' | sudo tee FilePath
#
# For apps installed through `apt` I let it figure out what to install. For most
# others, I generally use `command -v APP` since `which` has several issues:
# https://stackoverflow.com/a/677212

set -e # Stop execution if a command errors
#set -x # Echo commands and expand any variables

# Set timezone
sudo timedatectl set-timezone America/New_York

# Change home dir to 700 to prevent snoopers
chmod 700 ~
# Remove default directories -- I store everything in ~/code and ~/z
rm -rf ~/{Documents,Music,Pictures,Public,Templates,Videos}
# Create my default directories
mkdir -p ~/{backups,code,.ssh,z}

# Update repos
sudo apt update
# Upgrade all packages installed
sudo apt upgrade -y
# Remove unused packages
sudo apt autoremove -y
# Install packages
PACKAGES=(
	"atop"            # System resource monitoring
	#"baobab"         # GUI disk usage graphing
	"ca-certificates" # Required for 3rd party APT PPAs
	"curl"
	#"deja-dup"       # GUI backup tool
	"direnv"          # load and unload environment variables depending on the current directory
	"exuberant-ctags" # Required for Vim's tag bar
	#"fail2ban"
	"fswatch"         # Used by vim and others for inotify supported file watching
	"git"
	#"goacess"        # CLI Web server log viewer
	#"gparted"        # GUI disk partitioning
	"htop"
	"krb5-user"       # Kerberos for HPC YubiKey support (HPCMP.HPC.MIL)
	"lnav"            # CLI log viewer (e.g. terminal UI for Apache/Nginx logs)
	#"logwatch"       # Summarizes log files and can send summary via email
	"ncdu"            # TUI disk usage analyzer which allows deleting (similar to baobab)
	"tmux"
	#"unetbootin"     # GUI for creating bootable USB sticks
	"vnstat"          # network stats per interface per day/week/month
	#"xrdp"           # allows Windows users to connect via Remote Desktop
	"yt-dlp"          # Download (YouTube) videos from CLI.
	"zeal"            # simple, offline programming documenation viewer
)
sudo apt install -y ${PACKAGES[@]}
# Install AWS CLI via Snap because it's the only way it will auto-update
sudo snap install aws-cli --classic

## Optional ###################################################################

# Golang (globally and IFF not correct version)
read -p "Install Go (Y or N)? " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    GOVERSION=1.23.0
    if go env | grep "${GOVERSION}"; then
        echo "Go ${GOVERSION} already installed"
    else
        echo "Installing Go ${GOVERSION} 64-bit for Linux"
        mkdir -p ~/go
        wget https://dl.google.com/go/go${GOVERSION}.linux-amd64.tar.gz
        sudo rm -rf /usr/local/go
        sudo tar -C /usr/local -xzf go${GOVERSION}.linux-amd64.tar.gz
        rm go${GOVERSION}.linux-amd64.tar.gz
    fi
    # Temporarily export GO paths so the installs below work
    export GOPATH=~/go
    export GOROOT=/usr/local/go
    export PATH=$PATH:$GOROOT/bin:$GOPATH/bin
    # Install other Go tools IFF not found
    command -v godoc &>/dev/null || go install -v golang.org/x/tools/cmd/godoc@latest
    command -v gofumpt &>/dev/null || go install -v mvdan.cc/gofumpt@latest
fi

# VS Code
read -p "Install VS Code (Y or N)? " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    curl -Lo vscode.deb "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64"
    sudo dpkg -i vscode.deb
    rm vscode.deb
fi

# Sublime Text
read -p "Install Sublime Text (Y or N)? " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/sublimehq-archive.gpg > /dev/null
    echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
    sudo apt update
    sudo apt install sublime-text
fi

# Slack
read -p "Install Slack (Y or N)? " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    SLACK_V="4.29.149"
    curl -Lo slack.deb "https://downloads.slack-edge.com/releases/linux/${SLACK_V}/prod/x64/slack-desktop-${SLACK_V}-amd64.deb"
    sudo dpkg -i slack.deb
    rm slack.deb
fi

# YubiKey / PIV
read -p "Install OpenSC for YubiKey (Y or N)?" -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo apt install -y opensc
    sudo systemctl enable pcscd # If not running, PIV will not work
fi

# WireGuard
read -p "Install WireGuard (Y or N)?" -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo apt install wireguard
    # If the VPN config has DNS entry, it will try to use resolvconf which doesn't exist on Ubuntu
    # (use SystemD instead). See https://superuser.com/a/1544697
    sudo ln -sf /usr/bin/resolvectl /usr/local/bin/resolvconf
fi

# HashiCorp Packer
read -p "Install HashiCorp Packer (Y or N)?" -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    # This method was take from hashicorp.com on 2024.04.04
    curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
    sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
    sudo apt-get update && sudo apt-get install packer
fi

# HashiCorp Terraform
read -p "Install HashiCorp Terraform (Y or N)?" -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    # This method was take from hashicorp.com on 2024.04.04
    curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
    sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
    sudo apt-get update && sudo apt-get install terraform
fi

# Docker
read -p "Install Docker (Y or N)?" -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    # This method was take from docker.com on 2024.04.29
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
fi


# Enable Auto Updates for Ubuntu 20.04
# This config applies security updates, removes unused dependencies, and reboots at 5AM UTC if needed.
# Adapted from https://www.digitalocean.com/community/tutorials/how-to-keep-ubuntu-20-04-servers-updated
read -p "Auto-install security updates (recommended for servers only) (Y or N)?" -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo apt-get install unattended-upgrades
    sudo systemctl status unattended-upgrades.service
    sudo sed -i 's/\/\/"${distro_id}:${distro_codename}-security";/"${distro_id}:${distro_codename}-security";/g' /etc/apt/apt.conf.d/50unattended-upgrades
    sudo sed -i 's/\/\/Unattended-Upgrade::Remove-Unused-Dependencies "false";/Unattended-Upgrade::Remove-Unused-Dependencies "true";/g' /etc/apt/apt.conf.d/50unattended-upgrades
    sudo sed -i 's/\/\/Unattended-Upgrade::Automatic-Reboot "false";/Unattended-Upgrade::Automatic-Reboot "true";/g' /etc/apt/apt.conf.d/50unattended-upgrades
    sudo sed -i 's/\/\/Unattended-Upgrade::Automatic-Reboot-Time "02:00";/Unattended-Upgrade::Automatic-Reboot-Time "5:00";/g' /etc/apt/apt.conf.d/50unattended-upgrades
fi

# If SSH server is installed AND the user says so, configure it.
if [[ -f "/etc/ssh/sshd_config" ]]; then
    read -p "Configure SSH server (disable root login, x11 forwarding, and MotD news) (Y or N)?" -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        #  - Disable root login (use sudoers instead)
        sudo sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/g' /etc/ssh/sshd_config
        sudo sed -i 's/#PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
        #  - Disable X11 forwarding to reduce attack surface
        sudo sed -i 's/X11Forwarding yes/X11Forwarding no/g' /etc/ssh/sshd_config
        # Turn off Message of the Day News (i.e advertisements) when logging in via SSH
        # Personally, I find that they obscure the important info and are annoying.
        sudo sed -i 's/ENABLED=1/ENABLED=0/g' /etc/default/motd-news
    fi
fi

echo "Setup Complete."
