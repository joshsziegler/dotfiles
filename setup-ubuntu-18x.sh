#!/bin/bash

# Echo commands and expand any variables
set -x 

echo "Changing everything to be owned by me" 
sudo chown -R $USER:$USER ~/*
echo "Change home dir to 700"
sudo chmod 700 ~ 
echo "Delete standard folders I don't use"
rm -rf ~/{Music,Pictures,Public,Templates,Video} 
echo  "Create Code directory"
mkdir -p ~/Documents/Code
echo "Setup .bashrc"
echo "source ~/Documents/Code/dotfiles/.bashrc" >> ~/.bashrc 

echo "Update repos..."
sudo apt update
echo "Install packages..."
suod apt install \
    git \ 
    vim \ 
    tmux \ 
    python3 \
    python3-pip \
    python-dev \
    build-essential \
    linkchecker \               # Check for dead links in HTML/websites
    lnav \                      # Fantastic CLI log viewer
    vnstat                      # Network Stats
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
echo "Upgrade all packages installed..."
sudo apt upgrade -y
echo "Clean up packages..."
sudo apt autoremove -y

# Setup RSS-to-Email script  
# Crontab -e
#   57 9 * * * cd /home/josh/code/dotfiles/python/ && echo "Starting news run `date`" >> news_feed_errors.txt && source venv/bin/activate && python feeds.py --html > /var/www/home.zglr.org/news.html 2>> news_feed_errors.txt 

echo "1) Remember to update SSHD config: (/etc/ssh/sshd_config)"
echo "    PermitRootLogin no"
echo "    PasswordAuthentication no"
echo "2) Setup crontab: (sudo crontab -e)"
echo "  30 2 * * 1 /usr/bin/letsencrypt renew >> /var/log/le-renew.log"
echo "  0  3 * * * apt update && apt full-upgrade -y && apt autoremove && reboot"
echo "3) Reboot to finish upgrade process.
