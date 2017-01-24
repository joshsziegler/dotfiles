#!/bin/bash

echo "Delete standard home directory layout"
rm -rf ~/Documents ~/Downloads ~/Music ~/Pictures ~/Public ~/Templates ~/Videos


echo  "Create my standard home directory layout"
mkdir ~/code
mkdir ~/downloads
mkdir ~/virtual_machines


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
    build-essential 
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


echo "Clean up packages..."
sudo apt-get -y autoremove


echo "Upgrade all packages installed..."
sudo apt update && sudo apt -y  upgrade 


echo "1) Remember to update SSHD config: (/etc/ssh/sshd_config)"
echo "    PermitRootLogin no"
echo "    PasswordAuthentication no"
echo "2) Reboot to finish upgrade process.
