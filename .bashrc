# Make sure auto-complete is enabled (i.e. sudo apt install bash-autocompletion)
source /etc/profile.d/bash_completion.sh

# History control
# don't use duplicate lines or lines starting with space; remove prior duplicates
HISTCONTROL=ignoreboth:erasedups
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
export PS1="\[$(tput bold)\]\[\033[38;5;39m\]\u\[$(tput sgr0)\]\[\033[38;5;241m\]@\[$(tput sgr0)\]\[$(tput bold)\]\[\033[38;5;35m\]\h\[$(tput sgr0)\]\[\033[38;5;241m\]:\[$(tput sgr0)\]\[\033[38;5;234m\]\w\[$(tput sgr0)\] \$(git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/') \[$(tput sgr0)\]\[\033[38;5;234m\]\\$\[$(tput sgr0)\]"

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
function ssht () {
    /usr/bin/ssh -t "$@" "tmux attach || tmux new";
}
ssh-work() {
    local WORK_YUBIKEY_HASH="SHA256:TG92bMtGBbmFXY8yWS3o5VBH3oEEQwTlsJJKLZIWdgY"
    (ssh-add -l | grep "${WORK_YUBIKEY_HASH}" &>/dev/null) || {
        echo "Yubikey not loaded in SSH-Agent. Please make sure the key is inserted."
        ssh-add -s /usr/lib/x86_64-linux-gnu/opensc-pkcs11.so 
    }
    echo "SSH-Agent Keys:"
    ssh-add -l
}

# Tmux - Support better colors by using -2 option along with set -g default-terminal "screen-256color"
alias tmux="tmux -2 attach -t joshz || tmux -2 new -s joshz"

# Rsync
alias backup-zlt="rsync -avh --delete ~/{.ssh,.mylogin.cnf,z,code,Downloads} --exclude='*node_module*' --exclude='*venv/*' /media/josh/Backup_HDD_Josh_Ziegler/backups/desktop/"
alias backup-staging="rsync -aP staging.analyticsgateway.com:/p/staging/patches/* /p/staging/patches/"

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
alias gitc='git checkout '
alias gitbc='git checkout -b ' # Git Branch Create
alias gitbd='git branch -D '   # Git Branch Delete
alias gitbp='git push --set-upstream origin $(git branch --show-current)' # Git Branch Push (New)
alias gitrc="git reset --hard && git clean -xfd" # Reset to HEAD and remove all files that aren't checked in
alias gitl='git log --all --graph --abbrev-commit --pretty=oneline --decorate'
alias gitt='git log --since="1 week ago" --date=short --no-merges --pretty="%Cred %h %Cblue (%ar) %Creset -- %s -- %Cgreen %an"'
function git-squash-then-rebase-on () {
    # Squash merge, then rebase onto the desired branch (typically develop or master).
    local BRANCH=$1
    # Find the last common commit from the current HEAD and BRANCH.
    # Then soft reset to that point (to keep all changes staged).
    # Commit all changes as one atomic commit (i.e. squash merge).
    # Then rebase the updated HEAD onto BRANCH.
    git reset --soft $(git merge-base HEAD $BRANCH) && git commit && git rebase $BRANCH 
}

# Docker
alias docker-clean='docker container prune -f && docker volume prune -f'

# Recursively search for a string in all files ending in html and replace
# find . -name '*.html' -print -exec sed -i.bak 's/foo/bar/g' {} \;

# Go
export GOPATH=~/go
export GOROOT=/usr/local/go
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin

# My custom scripts and binaries
export PATH=$PATH:~/code/dotfiles/bin

# Setup path for notes.sh in dotfiles bin
export NOTE_DIR=$HOME/z/notes

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# Work-Related
function deploy-ag() {
    set +x
    if [ -z "$1" ]
    then
        echo "Target host is required."
        echo "Usage: deploy-ag HOST [AG_VERSION]"
        exit 1
    fi
    local HOST=$1
    local AG_ARCH="amd64"
    ssh-work
    if [ -z "$2" ]
    then
        local AG_VERSION="$2-${AG_ARCH}"
        ssh staging.analyticsgateway.com "cd ~/code/ag/ && git checkout develop && git pull && git checkout ${AG_VERSION} && cd deploy && ansible-playbook playbooks/deployment.yml -e target_host=${HOST}.analyticsgateway.com -e hub_version=${HUB_VERSION}-amd64"
    else 
        ssh staging.analyticsgateway.com "cd ~/code/ag/ && git checkout develop && git pull && cd deploy && ansible-playbook playbooks/deployment.yml -e target_host=${HOST}.analyticsgateway.com"
    fi
}
