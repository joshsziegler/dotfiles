#!/bin/bash

echo "Update repos..."
sudo apt-get update

#echo "Remove crap I don\'t want..."
#sudo apt-get -y remove thunderbird \
    

# xubuntu-restricted-extrax ~ MP3, DVD playback`
# baobab ~ disk usage graphing
echo "Installing base packages..."
sudo apt-get -y install -y git gitk vim chromium-browser guake nmap \
     python-pip python-dev build-essential \
     deja-dup baobab gparted unetbootin \
     xubuntu-restricted-extras 

# Other packages that are maybes:
#  - ddclient		Dyanmic DNS Client (e.g. for Google Domains Dynanmic DNS)
#  - mumble-server	i.e. Murmur 
#  	- Config via sudo dpkg-reconfigure mumble-server

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

echo "Upgrade all packages installed..."
sudo apt-get upgrade
