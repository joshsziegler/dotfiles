#!/bin/bash
#
# Author:  Josh Ziegler
# Date:    2020-01-31
# License: MIT
#
# This script is used to restrict our backup user (which can login over SSH and
# sudo without a password) to only run rsync (this is meant to be used with the
# script `backup-servers.sh`. To use this:
#
# 1. Setup an SSH key for your backup user on the backup-server.
# 2. On the client to be backed up, add that SSH key to the appropriate user's
#    `~/.ssh/authorized_keys` file like so:
#     `command="~/dotfiles/validate-rsync-command.sh",no-agent-forwarding,no-port-forwarding,no-user-rc,no-X11-forwarding ssh-rsa YOUR-SSH-KEY-HERE YourUserName@YourHostName`
# 3. The client-side user needs to be able to sudo without a password!
# 4. Place this script into the location listed in line above (or change it).
#

case "$SSH_ORIGINAL_COMMAND" in
*\&*)
echo "Rejected"
;;
*\(*)
echo "Rejected"
;;
*\{*)
echo "Rejected"
;;
*\;*)
echo "Rejected"
;;
*\<*)
echo "Rejected"
;;
*\>*)
echo "Rejected"
;;
*\`*)
echo "Rejected"
;;
*\|*)
echo "Rejected"
;;
rsync\ --server*)
sudo $SSH_ORIGINAL_COMMAND  # Make sure this command runs via sudo so it can read all files
;;
*)
echo "Rejected"
;;
esac

