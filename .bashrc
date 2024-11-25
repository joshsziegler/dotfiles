# Prompt #########################################################################################
PROMPT_COMMAND=__prompt_command    # Function to generate PS1 after CMDs
__prompt_command() {
	if [ -z "$PS1" ]; then
		# Use a simple colorless prompt if this is not an interactive prompt
		PS1="\u@\h:\w\$"
		return
	fi
	local EXIT="$?"                # This needs to be first

	local Red='\[\e[0;31m\]'
	local Gre='\[\e[0;32m\]'
	local BYel='\[\e[1;33m\]'
	local BBlu='\[\e[1;34m\]'
	local Pur='\[\e[0;35m\]'

	local RESET='\[$(tput sgr0)\]' # Clear effects of previous SGR in data stream
	local BOLD='\[$(tput bold)\]'
	local LBLUE='\[\033[38;5;39m\]'  # Light Blue
	local LGREY='\[\033[38;5;241m\]' # Light Grey
	local BLACK='\[\033[38;5;234m\]' # Black?
	local GREEN='\[\033[38;5;35m\]'  # Green?

	# Username
	PS1="${BOLD}${LBLUE}\u${RESET}"
	# @
	PS1+="@${RESET}"
	# Hostname
	PS1+="${BOLD}${GREEN}\h${RESET}"
	# Working Directory
	PS1+="${LGRE}:${RESET}${BLACK}\w${RESET}"
	# Git Branch and status
	PS1+="\$(git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/') ${RESET}"
	# $
	if [ $EXIT != 0 ]; then
		PS1+="${BOLD}${Red}\$${RESET}" # Make red if the last command errored (returned non-zero)
	else
		PS1+="\$${RESET}"
	fi
}

# History #########################################################################################
HISTCONTROL=ignoreboth:erasedups # Don't store lines starting with a space, or duplicates.
HISTSIZE=1000
HISTFILESIZE=2000
# Append to the history file instead of overwrite
shopt -s histappend

# If Interactive Shell ############################################################################
if [ ! -z "$PS1" ]; then
    # echo "Interactive shell..."
    # Enable color prompt
    export TERM=xterm-256color # Enable color prompt
    # Check the window size after each command and, if necessary, update values for LINES and COLUMNS.
    shopt -s checkwinsize
    # Make sure auto-complete is enabled (i.e. sudo apt install bash-autocompletion)
    [ -f /etc/profile.d/bash_completion.sh ] && source /etc/profile.d/bash_completion.sh
    # Setup FZF
    [ -f ~/.fzf.bash ] && source ~/.fzf.bash
    # Alacritty completions
    [ -f ~/code/alacritty/extra/completions/alacritty.bash ] && source ~/code/alacritty/extra/completions/alacritty.bash
    # Start SSH-Agent IFF not running
    if [ -z "$SSH_AUTH_SOCK" ]; then
        echo "Starting ssh-agent..."
        eval `ssh-agent -s`
    else
        echo "ssh-agent already running"
    fi
fi

# Print string in red to stderr
error() {
 echo -e "\e[01;31m$1\e[0m" >&2;
}


# Ubuntu / APT ####################################################################################
function apt-up {
    if [ -z $1 ] ; then
        sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y
    else
        ssh -t $1 -- sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y
    fi
}

# Editor ##########################################################################################
if command -v nvim &> /dev/null
then # Use neovim if available
    export EDITOR=nvim
    export VISUAL=$EDITOR
    alias vim="$EDITOR"
elif command -v vim &> /dev/null
then # Use vim as a backup if available
    export EDITOR=vim
    export VISUAL=$EDITOR
    alias vi="$EDITOR"
fi # I give up

# Go ##############################################################################################
export GOPATH=~/go
export GOROOT=/usr/local/go
export GOBIN=$GOPATH/bin
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin

# Personal ########################################################################################
export PATH=$PATH:~/code/dotfiles/bin # My custom scripts and binaries
export NOTE_DIR=$HOME/z/notes # Setup path for notes.sh in dotfiles bin

# Aliases #########################################################################################
# git for this dotfiles repo
alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
# ls
alias ls="ls -F --color=auto"
alias ll="ls -lhF --color=auto"
alias ls-last-updated="ls -Alrt | tail -n10"
## Find
alias find-largest="du -Sh | sort -rh | head -5"
alias find-largest-dirs="du -ah | sort -rh | head -n 5"
alias find-largest-files="find -type f -exec du -Sh {} + | sort -rh | head -n 5"
alias grep='grep --color=auto'
alias mkdir='mkdir -pv'
alias mv='mv -v'
## Tmux - Support better colors by using -2 option along with set -g default-terminal "screen-256color"
alias tmux="tmux -2 attach -t joshz || tmux -2 new -s joshz"
# APT
alias aptu="apt-up"
alias apth="cat /var/log/apt/history.log | grep -C 1 Commandline"             # Apt History
## Gnome
alias save-gnome-term-prefs="dconf dump /org/gnome/terminal/ > ~/gterminal.preferences"
alias load-gnome-term-prefs="cat ~/gterminal.preferences | dconf load /org/gnome/terminal/legacy/profiles:/"
## HTML to Markdown: Download a webpage (provide one after this alias) and convert to Markdown
alias html2md="pandoc -s -reference-links --atx-headers -f html -t markdown-raw_html "
## Docker
alias docker-prune="docker system prune --volumes" # Prune verything, including volumes
alias docker-bash="docker run -it --entrypoint /bin/bash " # Run docker container but drop into BASH
## ZGLR Specific
alias zglr-backup="rsync -avh --delete ~/{.ssh,.mylogin.cnf,z,code,Downloads} --exclude='*node_module*' --exclude='*venv/*' /media/josh/Backup_HDD_Josh_Ziegler/backups/desktop/"
## Hashicorp Packer
alias pkri="packer init ."
alias pkrf="packer fmt ."
alias pkrv="packer validate ."
alias pkrb="packer build ."
alias pkr="packer init . && packer fmt . && packer validate . && packer build ."
## Python
alias pip="pip3"
alias pyv="python3 -m venv venv"                    # Create Python 3 virtualenv
alias pya="source venv/bin/activate"                # Active the current dir's virtualenv
alias pyd="deactivate"                              # Deactivate the current virtualenv
alias py-http="python -m http.server"               # Server the current directory with Python 3
alias py-test="python -m unittest discover"         # Run all unit tests found
alias py-dev="python setup.py develop"              # Run setup.py in developer mode
alias py-reset="gitrc && pyv3 && pya && pydev"      # Rebuild from scratch
alias py-fix="autopep8 -riav --max-line-length 120" # Auto fix most PEP8 violations
## Git
alias gitf='git fetch --all --prune'
alias gits='git status'        # Git Status
alias gitc='git checkout '     # Git Checkout BRANCH
alias gitb='git ls-remote --heads origin "*jz*"' # Git branch with my initials
alias gitbc='git checkout -b ' # Git Branch Create BRANCH
alias gitbd='git branch -D '   # Git Branch Delete BRANCH
alias gitbp='git push --set-upstream origin $(git branch --show-current)' # Git Branch Push (New)
alias gitrc="git reset --hard && git clean -xfd" # Reset to HEAD and remove all files that aren't checked in
alias gitl='git log --abbrev-commit --pretty=oneline --decorate' # Show abbreviated log for this branch only
alias gitla='git log --all --graph --abbrev-commit --pretty=oneline --decorate' # Show abbreviated log for all branches with graphing
alias gitt='git log --since="1 week ago" --date=short --no-merges --pretty="%Cred %h %Cblue (%ar) %Creset -- %s -- %Cgreen %an"'
function gitsr () { # Git Squash then Rebase on BRANCH
    # Squash merge, then rebase onto the desired branch (typically develop or master).
    local BRANCH=$1
    # Find the last common commit from the current HEAD and BRANCH.
    # Then soft reset to that point (to keep all changes staged).
    # Commit all changes as one atomic commit (i.e. squash merge).
    # Then rebase the updated HEAD onto BRANCH.
    git reset --soft $(git merge-base HEAD $BRANCH) && git commit && git rebase $BRANCH
}

# Work ############################################################################################
ssh-work() {
    local WORK_YUBIKEY_HASH="SHA256:6WAaKFoUFRDnpw1T0+1R0iMOyK+LnUwAD9TkRVDpeVA"
    (ssh-add -l | grep "${WORK_YUBIKEY_HASH}" &>/dev/null) || {
        echo "Yubikey not loaded in SSH-Agent. Please make sure the key is inserted."
        ssh-add -s /usr/lib/x86_64-linux-gnu/opensc-pkcs11.so
		if [ $? -ne 0 ]; then
			error "Error adding key"
		fi
    }
    echo "SSH-Agent Keys:"
    ssh-add -l
}
alias ag-copy-db='ssh dev.analyticsgateway.com "cp /var/ag/ag-db ag-temp.db" && rsync dev.analyticsgateway.com:ag-temp.db ag-dev-`date -uI`.db && ssh dev.analyticsgateway.com "rm ag-temp.db"'
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

# Environment Variables ###########################################################################
# From to their docs, this must be done after other shell extenstions that manipulate the prompts!
eval "$(direnv hook bash)"
