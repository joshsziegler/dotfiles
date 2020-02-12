#!/bin/bash

# Echo commands and expand any variables
set -x 

# Changing everything to be owned by me
chown -R $USER:$USER ~/*
# Change home dir to 700
chmod 700 ~ 
# Create Backup and Code directories
mkdir -p ~/Documents/{Backup,Code}
# Setup .bashrc
echo "source ~/Documents/Code/dotfiles/.bashrc" >> ~/.bashrc 

# Update repos...
sudo apt update
# Install packages...
sudo apt install -y \
    git \
    vim \
    tmux \
    python3 \
    python3-pip \
    build-essential \
    linkchecker \
    lnav \
    vnstat
#   krb5-user                   # Kerberos for HPC YubiKey support (HPCMP.HPC.MIL)
#   linkchecker                 # Check for dead links in HTML/websites
#   lnav                        # Fantastic CLI log viewer
#   vnstat                      # Network Stats
#   apache2 
#   apache2-utils 
#   fail2ban  
#   nmap   
#   acct                        # System resource usage by user 
#   darkstat                    # Network monitor with HTTP served graphs/stats
#   logwatch                    # Summarizes log files and can send summary via email
#   deja-dup                     backup tool
#   gparted                      disk partitioning
#   unetbootin                   create bootable USB sticks
#   guake                        Quake-style terminal
#   chromium-browser             OSS Chrome
#   xubuntu-restricted-extrax    MP3, DVD playback
#   baobab                       disk usage graphing 
#   ddclient                     Dyanmic DNS Client (e.g. for Google Domains Dynanmic DNS)
#   mumble-server                i.e. Murmur (Config via sudo dpkg-reconfigure mumble-server)  
#   goacess                      Web server log viewer
#   minidlna                     DLNA server
#   xrdp                         allows Windows users to connect via Remote Desktop
# Upgrade all packages installed...
sudo apt upgrade -y
# Clean up unused packages...
sudo apt autoremove -y

# Setup SublimeText3 configs
mkdir -p ~/.config/sublime-text-3/Packages/User/
ln -sf ~/Code/dotfiles/sublime/Go.sublime-settings  ~/.config/sublime-text-3/Packages/User/
ln -sf ~/Code/dotfiles/sublime/Preferences.sublime-settings  ~/.config/sublime-text-3/Packages/User/


# 1) Remember to update SSHD config: (/etc/ssh/sshd_config)
#    PermitRootLogin no
#    PasswordAuthentication no
# 2) Setup crontab: (sudo crontab -e)
#    30 2 * * 1 /usr/bin/letsencrypt renew >> /var/log/le-renew.log
#    0  3 * * * apt update && apt full-upgrade -y && apt autoremove && reboot
# 3) Reboot to finish upgrade process.
