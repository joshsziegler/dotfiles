#!/bin/bash

echo "Update repos..."
sudo apt-get update

echo "Remove crap I don\'t want..."
sudo apt-get -y remove thunderbird xfburn xchat aisleriot gnome-games \
    epiphany-browser gnomine gnome-mahjongg quadrapassel gnome-sudoku

# xubuntu-restricted-extrax ~ MP3, DVD playback`
# baobab ~ disk usage graphing
echo "Installing base packages..."
sudo apt-get -y install -y git gitk vim chromium-browser guake nmap \
     python-pip python-dev build-essential \
     deja-dup baobab gparted unetbootin \
     xubuntu-restricted-extras 

echo "Clean up packages..."
sudo apt-get -y autoremove

echo "Move settings over..."
cp -r vim/.vim* ~
cp -r .gitconfig ~

echo "Delete standard home directory layout"
rm -rf ~/Desktop ~/Documents ~/Downloads ~/Music ~/Pictures ~/Public ~/Templates ~/Videos

echo  "Create my standard home directory layout"
mkdir ~/programming
mkdir ~/downloads
mkdir ~/virtual_machines
mkdir ~/documents

echo "Setting up DVD Playback..."
sudo /usr/share/doc/libdvdread4/install-css.sh

echo "Cleaning directory..."
git clean -xfd 
git clean -f

echo "Changing everything to be owned by jz..."
sudo chown -R jz:jz /home/jz/*

echo "Upgrade all packages installed..."
sudo apt-get upgrade