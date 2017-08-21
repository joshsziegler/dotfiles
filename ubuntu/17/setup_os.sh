#!/bin/bash

echo "Delete standard home directory layout"
rm -rf ~/Documents ~/Downloads ~/Music ~/Pictures ~/Public ~/Templates ~/Videos

echo  "Create my standard home directory layout"
mkdir ~/code
mkdir ~/downloads
mkdir ~/vm
mkdir -p ~/code/gocode/src  # My Go source directory
mkdir ~/go  # Go install location (so I don't have to install it system-wide)

echo "Move settings over..."
cp -r vim/.vim* ~/
cp -r .gitconfig ~/

echo "Changing everything to be owned by josh..."
sudo chown -R josh:josh /home/josh/*

echo "Change home dir to 700..."
sudo chmod 700 /home/josh

echo "Setup .bashrc"
echo "source ~/code/dotfiles/.bashrc-zglr" >> ~/.bashrc 

echo "Update repos..."
sudo apt update

echo "Install packages..."
suod apt install \
    git \ 
    gitk \ 
    vim \ 
    nmap \  
    tmux \ 
    python3 \
    python3-pip \
    python-dev \
    apache2 \
    apache2-utils \ 
    build-essential \
    fail2ban
    linkchecker                   
#   vnstat                      # Network Stats
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

# Setup RSS-to-Email script  
# Crontab -e
#   57 9 * * * cd /home/josh/code/dotfiles/python/ && echo "Starting news run `date`" >> news_feed_errors.txt && source venv/bin/activate && python feeds.py --html > /var/www/home.zglr.org/news.html 2>> news_feed_errors.txt 

echo "Upgrade all packages installed..."
sudo apt -y  full-upgrade

echo "Clean up packages..."
sudo apt-get -y autoremove

echo "1) Remember to update SSHD config: (/etc/ssh/sshd_config)"
echo "    PermitRootLogin no"
echo "    PasswordAuthentication no"
echo "2) Setup crontab: (sudo crontab -e)"
echo "  30 2 * * 1 /usr/bin/letsencrypt renew >> /var/log/le-renew.log"
echo "  0  3 * * * apt update && apt full-upgrade -y && apt autoremove && reboot"
echo "3) Reboot to finish upgrade process.
