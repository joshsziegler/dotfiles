#!/bin/bash

echo "Update repos..."
sudo apt update

# Packages:
#  - git
#  - gitk
#  - vim
#  - nmap
#  - tmux
#  - python3
#  - python3-pip
#  - python-pip  
#  - python-dev
#  - build-essential
#  - deja-dup                     backup tool
#  - gparted                      disk partitioning
#  - unetbootin                   create bootable USB sticks
#  - guake                        Quake-style terminal
#  - chromium-browser             OSS Chrome
#  - xubuntu-restricted-extrax    MP3, DVD playback
#  - baobab                       disk usage graphing 
#  - ddclient                     Dyanmic DNS Client (e.g. for Google Domains Dynanmic DNS)
#  - mumble-server                i.e. Murmur (Config via sudo dpkg-reconfigure mumble-server)  
#  - goacess                      Web server log viewer
#  - minidlna                     DLNA server
#  - xrdp                         allows Windows users to connect via Remote Desktop
# 
# Crontab -e
#   57 9 * * * cd /home/josh/code/dotfiles/python/ && echo "Starting news run `date`" >> news_feed_errors.txt && source venv/bin/activate && python feeds.py --html > /var/www/home.zglr.org/news.html 2>> news_feed_errors.txt 

echo "Clean up packages..."
sudo apt-get -y autoremove

echo "Move settings over..."
cp -r vim/.vim* ~
cp -r .gitconfig ~

echo "Add some default aliases to bash_profile?"
echo "alias backup='rsync -rcvPh --delete /cygdrive/c/home josh@192.168.1.2:~/backups/josh-lt/'"
echo "alias zssh='ssh josh@192.168.1.2 -t 'tmux attach || tmux new'"

echo "Remember to update SSHD config:"
echo "PermitRootLogin no"
echo "PasswordAuthentication no"


echo "Delete standard home directory layout"
rm -rf ~/Desktop ~/Documents ~/Downloads ~/Music ~/Pictures ~/Public ~/Templates ~/Videos

echo  "Create my standard home directory layout"
mkdir ~/code
mkdir ~/downloads
mkdir ~/virtual_machines

#echo "Setting up DVD Playback..."
#sudo /usr/share/doc/libdvdread4/install-css.sh

echo "Cleaning directory..."
git clean -xfd 
git clean -f

echo "Changing everything to be owned by josh..."
sudo chown -R jz:jz /home/josh/*

echo "Change home dir to 700..."
sudo chmod 700 /home/josh

echo "Add Bash Aliases..."
echo 'alias backup="rsync -rcvPh --delete /cygdrive/c/home/ josh@192.168.1.2:~/backups/josh-lt/"' >> ~/.bash_profile
echo 'alias update="sudo apt update && sudo apt upgrade - y && sudo apt autoremove && sudo reboot"' >> ~/.bash_profile

echo "Upgrade all packages installed..."
sudo apt update && sudo apt -y  upgrade && sudo reboot
