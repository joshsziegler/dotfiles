#!/bin/bash
#
# Author:  Josh Ziegler
# Date:    2020-05-19
# Updated: 2023-01-19
# License: MIT
#
# This script configures Ubuntu 22.04 to my baseline by installing packages and
# changing several default configs.
#
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
set -x # Echo commands and expand any variables

# Set timezone
sudo timedatectl set-timezone America/New_York

# If SSH server is installed:
#  - Disable root login (use sudoers instead)
#  - Disable X11 forwarding to reduce attack surface
if [[ -f "/etc/ssh/sshd_config" ]]; then
    sudo sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/g' /etc/ssh/sshd_config
    sudo sed -i 's/X11Forwarding yes/X11Forwarding no/g' /etc/ssh/sshd_config
    # Turn off Message of the Day News (i.e advertisements) when logging in via SSH
    # Personally, I find that they obscure the important info and are annoying.
    sudo sed -i 's/ENABLED=1/ENABLED=0/g' /etc/default/motd-news
fi

# Setup Auto-Update for Security Upgrades
#  - This is taken from two pieces of documentation and applies to Ubuntu 18.04
#    - https://help.ubuntu.com/community/AutomaticSecurityUpdates
#    - https://help.ubuntu.com/lts/serverguide/automatic-updates.html#Automatic
#  - The notifier package is required for automatic reboots!
#  - This config only applies security updates, but will auto-remove unused dependencies
sudo apt-get install unattended-upgrades
sudo dpkg-reconfigure --priority=low unattended-upgrades
echo 'APT::Periodic::Update-Package-Lists "1";' | sudo tee /etc/apt/apt.conf.d/20auto-upgrades    # Overwrite existing file
echo 'APT::Periodic::Unattended-Upgrade "1";'   | sudo tee -a /etc/apt/apt.conf.d/20auto-upgrades # Append to the newly created file
sudo sed -i 's/\/\/"${distro_id} ${distro_codename}-security";/"${distro_id} ${distro_codename}-security";/g' /etc/apt/apt.conf.d/50unattended-upgrades
sudo sed -i 's/\/\/Unattended-Upgrade::Remove-Unused-Dependencies "false";/Unattended-Upgrade::Remove-Unused-Dependencies "true";/g' /etc/apt/apt.conf.d/50unattended-upgrades
sudo sed -i 's/\/\/Unattended-Upgrade::Automatic-Reboot "false";/Unattended-Upgrade::Automatic-Reboot "true";/g' /etc/apt/apt.conf.d/50unattended-upgrades
sudo sed -i 's/\/\/Unattended-Upgrade::Automatic-Reboot-Time "02:00";/Unattended-Upgrade::Automatic-Reboot-Time "5:00";/g' /etc/apt/apt.conf.d/50unattended-upgrades


# Change home dir to 700 to prevent snoopers
chmod 700 ~
# Remove default directories -- I store everything in ~/code and ~/z
rm -rf {Documents,Downloads,Music,Pictures,Public,Templates,Videos}
# Create my default directories
mkdir -p ~/{backups,code,.ssh,z}
# Create symbolic links to dotfile configs
ln -sf ~/code/dotfiles/.bashrc ~/
ln -sf ~/code/dotfiles/.ssh/config ~/.ssh/
ln -sf ~/code/dotfiles/.gitconfig ~/
ln -sf ~/code/dotfiles/.vimrc ~/
ln -sf ~/code/dotfiles/.vim/ ~/
ln -sf ~/code/dotfiles/.tmux.conf ~/
ln -sf ~/code/dotfiles/.condarc ~/

# SublimeText3
mkdir -p ~/.config/sublime-text-3/Packages/User/
ln -sf ~/code/dotfiles/sublime/Go.sublime-settings  ~/.config/sublime-text-3/Packages/User/
ln -sf ~/code/dotfiles/sublime/Preferences.sublime-settings  ~/.config/sublime-text-3/Packages/User/
# EditorConfig
# GoFmt (with User preferences set to use `goimports`)
# GoRename
# Package Control
# TypeScript

# Update repos
sudo apt update
# Upgrade all packages installed
sudo apt upgrade -y
# Remove unused packages
sudo apt autoremove -y
# Install packages
sudo apt install -y git vim tmux atop htop lnav vnstat zeal
# atop       ~ System resource monitoring
# baobab     ~ GUI disk usage graphing
# deja-dup   ~ GUI backup tool
# fail2ban
# goacess    ~ CLI Web server log viewer
# gparted    ~ GUI disk partitioning
# krb5-user  ~ Kerberos for HPC YubiKey support (HPCMP.HPC.MIL)
# lnav       ~ CLI log viewer (e.g. terminal UI for Apache/Nginx logs)
# logwatch   ~ Summarizes log files and can send summary via email
# unetbootin ~ GUI for creating bootable USB sticks
# vnstat     ~ network stats per interface per day/week/month
# xrdp       ~ allows Windows users to connect via Remote Desktop
# zeal       ~ simple, offline programming documenation viewer

# Install Golang globally IFF not correct version
install-go(){
    GOVERSION=1.19.5
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
}
install-go
# Temporarily export GO paths so the installs below work
export GOPATH=~/go
export GOROOT=/usr/local/go
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin
# Install other Go tools IFF not found
command -v godoc &>/dev/null || go install -v golang.org/x/tools/cmd/godoc@latest
command -v goimports &>/dev/null || go install -v golang.org/x/tools/cmd/goimports@latest
