if [ -f "${HOME}/.bashrc" ] ; then
  source "${HOME}/.bashrc"
fi


alias backup_lan="rsync -rcvPh --delete /cygdrive/c/home josh@192.168.1.2:~/backups/josh-lt/"
alias backup_zglr="rsync -rcvPh --delete /cygdrive/c/home josh@zglr.org:~/backups/josh-lt/"
alias d_update="sudo apt update && sudo apt upgrade - y && sudo apt autoremove && sudo reboot"
alias zssh="ssh josh@192.168.1.2 -t 'tmux attach || tmux new'"
alias zssh2="ssh josh@zglr.org -t 'tmux attach || tmux new'"
alias zdeploy="git push && ssh josh@zglr.org -t 'cd ~/zglr_org && git pull'"

# Python-related 
alias pya="source venv/bin/activate"
alias pyd="deactivate"

