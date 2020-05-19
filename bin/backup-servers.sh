#!/bin/bash
#
# Author:  Josh Ziegler
# Date:    2020-01-31
# License: MIT
#
# Backup remote linux servers using a simple rsync into daily/weekly/monthly
# directories on this computer. This is meant to be simple (as compared to
# rsnapshot, etc.) so that it is more robust to certain failures. In other
# words it's meant as a *backup* backup method, in case everything else goes
# wrong!
#
# The variables below (i.e. BACKUP_DIR, DIRS, DOW, DOM, and RSYNC) are the
# only pieces that should be modified in typical use, along with the list
# of hosts in the "for UserHost in ubuntu@srv-1 ... ". This will iterate
# through the hosts, backing them up into BACKUP_DIR/daily/ via rsync. That
# directory will then be rsync'd to /weekly on Fridays, and /monthly on the
# 1st day of the month. The daily backup has a file added to the backup named
# "BackupCreatedOnYYYY-MM-DD-HHMM-Z.txt" with the current date and time. This
# is meant to make the backups vintage easily identifiable at a glance.
#
# This script assumes the UserName@ServerName has the ability to SSH in and
# use `sudo rsync`! This is dangerous, but can be locked down with SSH keys
# and a script on the Host-side to limit commands to ONLY rsync.
#
# Explanation of rsync args:
#
#     --ignore-missing-args
#         When rsync is first processing the explicitly requested
#         source files (e.g. command-line arguments or --files-from
#         entries), it is normally an error if the file cannot be
#         found.  This option suppresses that error, and does not
#         try to transfer the file.  This does not affect subsequent
#         vanished-file errors if a file was initially found to be
#         present and later is no longer there.
#

BACKUP_DIR="/srv/backups"
DIRS="{app,etc,home,opt,root,srv,usr/local,var/log,var/spool,var/www}"
DOW=$(date +"%A") # Day Of the Week (e.g. Monday, Wednesday)
DOM=$(date +"%d") # Day Of the Month (e.g. 1, 30)
RSYNC="rsync -a --delete --numeric-ids"

for UserHost in ubuntu@srv-1\
	ubuntu@srv-2\
	ubuntu@srv-3\
	ubuntu@code\
	ubuntu@vm-fatigue-mobile\
	ubuntu@vm-fatigue-model-comp\
	ubuntu@vm-ppo-mandarin\
	root@wsu-mm;
  do
    DATE=`date "+%Y-%m-%d-%T-%Z"` # Date and time in UTC, get at start of each host's run
    USER=`echo $UserHost | cut -d"@" -f1`
    HOST=`echo $UserHost | cut -d"@" -f2`
    BDIR="$BACKUP_DIR/$HOST" # Base Backup Directory
    DDIR="$BDIR/daily"  # Daily Backup Directory
    WDIR="$BDIR/weekly" # Weekly Backup Directory
    MDIR="$BDIR/monthly" # Monthly Backup Directory

    mkdir -p $DDIR

    echo "*** Creating daily backup for $HOST on $DATE..."
    $RSYNC --ignore-missing-args -e "ssh" --rsync-path="sudo rsync" $USER@$HOST:/$DIRS $DDIR
    if [ $? -ne 0 ]; then
            # Older versions of rsync will return: "rsync: on remote machine: --ignore-missing-args: unknown option"
            echo "*** Trying daily backup again, without --ignore-missing-args..."
            $RSYNC -e "ssh" --rsync-path="sudo rsync" $USER@$HOST:/$DIRS $DDIR
            if [ $? -ne 0 ]; then
                    echo "*** Error: giving up on this host"
                    continue # Skip the rest and continue with next host
            fi
    fi

    # Timestamp this backup by creating an empty plain-text file
    rm "$DDIR/BackupCreatedOn"*.txt
    touch "$DDIR/BackupCreatedOn$DATE.txt"

    # Run weekly backup on Fridays (sync currently daily to the weekly directory)
    if [ "$DOW" == "Friday" ]; then
        echo "*** Creating weekly backup..."
        $RSYNC $DDIR/ $WDIR
    fi

    # Run monthly backup on the first day of the month (sync currently weekly to the monthly directory)
    if [ "$DOM" == "01" ]; then
        echo "*** Creating monthly backup..."
        $RSYNC $WDIR/ $MDIR
    fi
  done
echo "*** Backups Complete"

