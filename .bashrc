# Define colors for easy use with echo -e "Foo ${LIGHT_RED}This will be red${NO_COLOR} and back to normal"
NO_COLOR='\033[0m'
LIGHT_RED='\033[1;31m'
LIGHT_GREEN='\033[1;32m'
LIGHT_BLUE='\033[1;34m'
LIGHT_PURPLE='\033[1;35m'
LIGHT_CYAN='\033[1;36m'

# Helper functions
color(){
    # This can be used to run a command (with positional arguments) and will print all stderr output in RED
    #
    # Use it like this: 
    #     color rsync -a /some/file /new/location 
    #
    # This *excellent* solution is from https://serverfault.com/a/502019
    (set -o pipefail;"$@" 2>&1>&3|sed $'s,.*,\e[31m&\e[m,'>&2)3>&1 
}

# Update my dotfiles
dotfiles(){
    git -C ~/Code/dotfiles/ pull 
    source ~/.bashrc 
    ln -sf ~/Code/dotfiles/.gitconfig ~/ 
    mkdir -p ~/.ssh/ 
    ln -sf ~/Code/dotfiles/.ssh/config ~/.ssh/ 
    ln -sf ~/Code/dotfiles/.vimrc ~/ 
    ln -sf ~/Code/dotfiles/.vim/ ~/ 
    ln -sf ~/Code/dotfiles/.pypirc ~/
    ln -sf ~/Code/dotfiles/.tmux.conf ~/
}

# Show Current Git Branch and Status in Prompt
export GIT_PS1_SHOWDIRTYSTATE=1
export PS1='\[\033[1;36m\]\u\[\033[0m\]@\[\033[1;34m\]\h\[\033[1;36m\] \w\[\033[1;33m\]$(__git_ps1)\[\033[1;34m\] \$\[\033[00m\] '
export VISUAL=vim
export EDITOR=vim
alias vi="vim"

# Ubuntu and Apt
alias apt-update="sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y && sudo reboot"
alias apt-history="cat /var/log/apt/history.log | grep -C 1 Commandline"

# SSH 
alias ssh-zglr="ssh josh@zglr.org -t 'tmux attach || tmux new'"
alias ssh-zglr2="ssh josh@192.168.1.2 -t 'tmux attach || tmux new'"
## SSH - Work
alias ssh-pk="/usr/local/ossh/bin/ssh"

# Tmux - Support better colors by using -2 option along with set -g default-terminal "screen-256color" 
alias tmux="tmux -2 attach -t joshz || tmux -2 new -s joshz"

# Rsync
alias backup-zlt="rsync -avh --delete ~/{.ssh,.mylogin.cnf,Code,Documents,Downloads,Music,Pictures,Videos} /media/joshz/Backup_HDD_Josh_Ziegler/backups/joshz-lt/"

# Python
alias pyv3="python3 -m venv venv"                       # Create Python 3 virtualenv
alias pya="source venv/bin/activate"                    # Active the current dir's virtualenv
alias pyd="deactivate"                                  # Deactivate the current virtualenv
alias pys2="python -m SimpleHTTPServer"                 # Serve the current directory with Python 2
alias pys="python -m http.server"                       # Server the current directory with Python 3
alias pyt="python -m unittest discover"                 # Run all unit tests found
alias pydev="python setup.py develop"                   # Run setup.py in developer mode
alias pyr="gitrc && pyv3 && pya && pydev"               # Rebuild from scratch
alias pyf="autopep8 -riav --max-line-length 120"        # Auto fix most PEP8 violations

# Git
alias gitf='git fetch --all --prune'
alias gits='git status'
alias gitrc="git reset --hard && git clean -xfd" # Reset to HEAD and remove all files that aren't checked in
alias gitl='git log --all --graph --abbrev-commit --pretty=oneline --decorate'
alias gitt='git log --since="4 week ago" --date=short --no-merges --pretty="%Cred %h %Cblue (%ar) %Creset -- %s -- %Cgreen %an"'

# Misc
alias ls-last-updated="ls -Alrt | tail -n10"
alias exit-code="echo $?"  # I can never remember this...
alias find-largest="du -Sh | sort -rh | head -5"
alias find-largest-dirs="du -ah | sort -rh | head -n 5"
alias find-largest-files="find -type f -exec du -Sh {} + | sort -rh | head -n 5"
# Update date and time using Google's server (only useful is NTP is botched)
alias update-time="sudo date -s \"$(wget -qSO- --max-redirect=0 google.com 2>&1 | grep Date: | cut -d' ' -f5-8)Z\" && sudo hwclock --systohc"


# Download a offline and windows-safe version of a website
zarchive(){
    wget \
     --recursive \
     --no-clobber \
     --page-requisites \
     --html-extension \
     --convert-links \
     --restrict-file-names=windows \
     --domains `echo "$1" | awk -F/ '{print $3}'` \
     --no-parent \
         $1 
}

# Linux binaries
PATH=$PATH:~/Code/dotfiles/bin
# Work-related Paths
PATH=$PATH:/usr/local/krb5/bin:/usr/local/ossh/bin

# Golang
install-go(){
    mkdir -p ~/go                # Create the GOPATH dir if it doesn't exist
    rm -rf ~/go1.9 || true       # Remove the old Go 1.9 install if it exists
    rm -rf ~/go1.10 || true      # Remove the old Go 1.10 install if it exists
    echo "Installing Go 1.13 64-bit for Linux"
    wget https://dl.google.com/go/go1.13.3.linux-amd64.tar.gz 
    sudo rm -rf /usr/local/go
    sudo tar -C /usr/local -xzf go1.13.3.linux-amd64.tar.gz  
}
# Go-related Paths
export GOPATH=~/go
export GOROOT=/usr/local/go
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin
