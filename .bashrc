# Show Current Git Branch and Status in Prompt
export GIT_PS1_SHOWDIRTYSTATE=1
export PS1='\[\033[01;32m\]\u@\h\[\033[01;34m\] \w\[\033[01;33m\]$(__git_ps1)\[\033[01;34m\] \$\[\033[00m\] '
export VISUAL=vim
export EDITOR=vim


# Personal PC/LAN related
alias zbackup="rsync -rcvPh --delete /cygdrive/c/home josh@192.168.1.2:~/backups/josh-lt/"
alias zupdate="sudo apt update && sudo apt upgrade - y && sudo apt autoremove && sudo reboot"
alias zssh="ssh josh@192.168.1.2 -t 'tmux attach || tmux new'"
alias zssh2="ssh josh@zglr.org -t 'tmux attach || tmux new'"

# Python-related 
alias pya="source venv/bin/activate"
alias pyd="deactivate"

