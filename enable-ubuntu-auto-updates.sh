#!/bin/bash
# Enable Auto Updates for Ubuntu 20.04
# This config applies security updates, removes unused dependencies, and reboots at 5AM UTC if needed.
# Adapted from https://www.digitalocean.com/community/tutorials/how-to-keep-ubuntu-20-04-servers-updated
sudo apt-get install unattended-upgrades
sudo systemctl status unattended-upgrades.service
sudo cat /etc/apt/apt.conf.d/50unattended-upgrades
sudo sed -i 's/\/\/"${distro_id}:${distro_codename}-security";/"${distro_id}:${distro_codename}-security";/g' /etc/apt/apt.conf.d/50unattended-upgrades
sudo sed -i 's/\/\/Unattended-Upgrade::Remove-Unused-Dependencies "false";/Unattended-Upgrade::Remove-Unused-Dependencies "true";/g' /etc/apt/apt.conf.d/50unattended-upgrades
sudo sed -i 's/\/\/Unattended-Upgrade::Automatic-Reboot "false";/Unattended-Upgrade::Automatic-Reboot "true";/g' /etc/apt/apt.conf.d/50unattended-upgrades
sudo sed -i 's/\/\/Unattended-Upgrade::Automatic-Reboot-Time "02:00";/Unattended-Upgrade::Automatic-Reboot-Time "5:00";/g' /etc/apt/apt.conf.d/50unattended-upgrades

