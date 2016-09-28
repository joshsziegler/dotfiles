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
#  - xrdp                         allows Windows users to connect via Remote Desktop without any installs
# 
# Crontab -e
#   57 9 * * * python3 /home/josh/dotfiles/python/feeds.py --html > /var/www/zglr.org/news.html

echo "Clean up packages..."
sudo apt-get -y autoremove

echo "Move settings over..."
cp -r vim/.vim* ~
cp -r .gitconfig ~

echo "Add some default aliases to bash_profile?"
echo "alias backup='rsync -rcvPh --delete /cygdrive/c/home josh@192.168.1.2:~/backups/josh-lt/'"

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
echo 'alias update="sudo apt update && yes | sudo apt upgrade"' >> ~/.bash_profile

echo "Upgrade all packages installed..."
sudo apt-get upgrade
