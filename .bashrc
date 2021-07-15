# History control
# don't use duplicate lines or lines starting with space
HISTCONTROL=ignoreboth
HISTSIZE=1000
HISTFILESIZE=2000
# append to the history file instead of overwrite
shopt -s histappend

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# Color prompt
export TERM=xterm-256color
# Show Current Git Branch and Status in Prompt
export GIT_PS1_SHOWDIRTYSTATE=1
export PS1='\[\033[1;36m\]\u\[\033[0m\]@\[\033[1;34m\]\h\[\033[1;36m\] \w\[\033[1;33m\]$(__git_ps1)\[\033[1;34m\] \$\[\033[00m\] '

# Use vim
export VISUAL=vim
export EDITOR=vim
alias vi="vim"

# Aliases
alias ls="ls -AF --color=auto"
alias ll="ls -AlhF --color=auto"
alias grep='grep --color=auto'
alias mkdir='mkdir -pv'
alias mv='mv -v'

# Show contents of directory after cd 
function cd () {
    builtin cd "$1"
    ls -ACF
}

alias ls-last-updated="ls -Alrt | tail -n10"
alias find-largest="du -Sh | sort -rh | head -5"
alias find-largest-dirs="du -ah | sort -rh | head -n 5"
alias find-largest-files="find -type f -exec du -Sh {} + | sort -rh | head -n 5"
# Download a webpage (provide one after this alias) and convert to Markdown
alias html2md="pandoc -s -reference-links --atx-headers -f html -t markdown-raw_html "

# Ubuntu and Apt
alias apt-update="sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y && sudo reboot"
alias apt-history="cat /var/log/apt/history.log | grep -C 1 Commandline"

# SSH
alias ssh-zglr="ssh josh@zglr.org -t 'tmux attach || tmux new'"

# Tmux - Support better colors by using -2 option along with set -g default-terminal "screen-256color"
alias tmux="tmux -2 attach -t joshz || tmux -2 new -s joshz"

# Rsync
alias backup-zlt="rsync -avh --delete ~/{.ssh,.mylogin.cnf,z,code,Downloads} --exclude='*node_module*' --exclude='*venv/*' /media/josh/Backup_HDD_Josh_Ziegler/backups/desktop/"

# Python
alias pip="pip3"
alias pyv="python3 -m venv venv"                    # Create Python 3 virtualenv
alias pya="source venv/bin/activate"                # Active the current dir's virtualenv
alias pyd="deactivate"                              # Deactivate the current virtualenv
alias py-http="python -m http.server"               # Server the current directory with Python 3
alias py-test="python -m unittest discover"         # Run all unit tests found
alias py-dev="python setup.py develop"              # Run setup.py in developer mode
alias py-reset="gitrc && pyv3 && pya && pydev"      # Rebuild from scratch
alias py-fix="autopep8 -riav --max-line-length 120" # Auto fix most PEP8 violations

# Matlab
alias matlab-cli="matlab -nodisplay -nosplash -nodesktop"

# Git
alias gitf='git fetch --all --prune'
alias gits='git status'
alias gitrc="git reset --hard && git clean -xfd" # Reset to HEAD and remove all files that aren't checked in
alias gitl='git log --all --graph --abbrev-commit --pretty=oneline --decorate'
alias gitt='git log --since="1 week ago" --date=short --no-merges --pretty="%Cred %h %Cblue (%ar) %Creset -- %s -- %Cgreen %an"'

# Recursively search for a string in all files ending in html and replace
# find . -name '*.html' -print -exec sed -i.bak 's/foo/bar/g' {} \;

# Install Golang globally
install-go(){
    GOVERSION=1.16.5
    echo "Installing Go $GOVERSION 64-bit for Linux"
    mkdir -p ~/go
    wget https://dl.google.com/go/go$GOVERSION.linux-amd64.tar.gz
    sudo rm -rf /usr/local/go
    sudo tar -C /usr/local -xzf go$GOVERSION.linux-amd64.tar.gz
    rm go$GOVERSION.linux-amd64.tar.gz
}

# Go
export GOPATH=~/go
export GOROOT=/usr/local/go
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin

# My custom scripts and binaries
export PATH=$PATH:~/code/dotfiles/bin

# Setup path for notes.sh in dotfiles bin
export NOTE_DIR=$HOME/z/notes

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
