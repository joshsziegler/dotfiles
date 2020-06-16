#!/bin/bash
#
# Author:  Josh Ziegler
# Date:    2020-05-19
# License: MIT
#
# This script configures Ubuntu 18.04 to my baseline by installing packages and
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
fi

# Setup Auto-Update for Security Upgrades
#  - This is taken from two pieces of documentation and applies to Ubuntu 18.04
#    - https://help.ubuntu.com/community/AutomaticSecurityUpdates
#    - https://help.ubuntu.com/lts/serverguide/automatic-updates.html#Automatic
#  - The notifier package is required for automatic reboots!
#  - This config only applies security updates, but will auto-remove unused dependencies
sudo apt-get install unattended-upgrades update-notifier-common
echo 'APT::Periodic::Update-Package-Lists "1";' | sudo tee /etc/apt/apt.conf.d/20auto-upgrades    # Overwrite existing file
echo 'APT::Periodic::Unattended-Upgrade "1";'   | sudo tee -a /etc/apt/apt.conf.d/20auto-upgrades # Append to the newly created file
sudo sed -i 's/\/\/"${distro_id} ${distro_codename}-security";/"${distro_id} ${distro_codename}-security";/g' /etc/apt/apt.conf.d/50unattended-upgrades
sudo sed -i 's/\/\/Unattended-Upgrade::Remove-Unused-Dependencies "false";/Unattended-Upgrade::Remove-Unused-Dependencies "true";/g' /etc/apt/apt.conf.d/50unattended-upgrades
sudo sed -i 's/\/\/Unattended-Upgrade::Automatic-Reboot "false";/Unattended-Upgrade::Automatic-Reboot "true";/g' /etc/apt/apt.conf.d/50unattended-upgrades
sudo sed -i 's/\/\/Unattended-Upgrade::Automatic-Reboot-Time "02:00";/Unattended-Upgrade::Automatic-Reboot-Time "5:00";/g' /etc/apt/apt.conf.d/50unattended-upgrades

# Turn off Message of the Day News (i.e advertisements) when logging in via SSH
# Personally, I find that they obscure the important info and are annoying.
sudo sed -i 's/ENABLED=1/ENABLED=0/g' /etc/default/motd-news

# Changing everything to be owned by me
chown -R $USER:$USER ~/*
# Change home dir to 700 to prevent snoopers
chmod 700 ~
# Create my default directories
mkdir -p ~/Documents/{backups,code,.ssh,z}
# Create symbolic links to dotfile configs
ln -sf ~/code/dotfiles/.ssh/config ~/.ssh/
ln -sf ~/code/dotfiles/.gitconfig ~/
ln -sf ~/code/dotfiles/.vimrc ~/
ln -sf ~/code/dotfiles/.vim/ ~/
ln -sf ~/code/dotfiles/.tmux.conf ~/

# SublimeText3
mkdir -p ~/.config/sublime-text-3/Packages/User/
ln -sf ~/code/dotfiles/sublime/Go.sublime-settings  ~/.config/sublime-text-3/Packages/User/
ln -sf ~/code/dotfiles/sublime/Preferences.sublime-settings  ~/.config/sublime-text-3/Packages/User/
# EditorConfig                                                                             
# GoImports                                                                                
# Golang Build                                                                             
# GoRename
# Mustache
# Package Control
# TypeScript  

# Update repos
sudo apt update
# Install packages
sudo apt install -y git vim tmux htop python3 python3-pip lnav vnstat zeal  
# lnav       ~ CLI log viewer (e.g. terminal UI for Apache/Nginx logs)
# vnstat     ~ network stats per interface per day/week/month
# zeal       ~ simple, offline programming documenation viewer
# krb5-user  ~ Kerberos for HPC YubiKey support (HPCMP.HPC.MIL)
# fail2ban  
# logwatch   ~ Summarizes log files and can send summary via email
# deja-dup   ~ GUI backup tool
# gparted    ~ GUI disk partitioning
# unetbootin ~ GUI for creating bootable USB sticks
# baobab     ~ GUI disk usage graphing
# goacess    ~ CLI Web server log viewer
# xrdp       ~ allows Windows users to connect via Remote Desktop

# Upgrade all packages installed
sudo apt upgrade -y
# Remove unused packages
sudo apt autoremove -y

