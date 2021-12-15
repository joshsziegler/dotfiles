#!/bin/bash
set -e # Stop execution if a command errors
set -x # Echo commands and expand any variables

# Update repos
sudo apt update
# Install packages
sudo apt install -y vim 
# Setup .ssh/config for office git repo
cat << EOF >> /home/vscode/.ssh/config
# Dev or Remote .ssh/config
Host office.infinitetactics.com
    User joshz
Host gitlab.infinitetactics.com
    HostName gitlab    
    ProxyJump office.infinitetactics.com
    User git
EOF
# Fix ownership of Go binaries and directories
sudo chown vscode:vscode -R /usr/local/go
sudo chown vscode:vscode -R /go
# Setup bash aliases IFF they aren't in the file already
grep -qxF 'alias gitf="git fetch --all --prune"' ~/.bashrc || echo 'alias gitf="git fetch --all --prune"' >> ~/.bashrc
grep -qxF 'alias gitl="git log --all --oneline --graph"' ~/.bashrc || echo 'alias gitl="git log --all --oneline --graph"' >> ~/.bashrc
# Don't forget to run 'make develop' in repo 
