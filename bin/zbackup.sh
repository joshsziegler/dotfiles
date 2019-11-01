#!/bin/bash

# A simple rsync over SSH backup script for multiple hosts.
#
# - Stores a single full daily, weekly, and monthly backup in /srv/backups/
#   - Example: If host is foo then daily would be in /srv/backups/foo/daily/
# - Handles multiple hosts with per-host usernames over SSH
# - Stores a "backed up on" text file in the directory to make identification easier
#

BACKUP_DIR="/srv/backups"
DIRS="{app,etc,home,opt,root,srv,usr/local,var/log,var/spool,var/www}"
DOW=$(date +"%A") # Day Of the Week (e.g. Monday, Wednesday)
DOM=$(date +"%d") # Day Of the Month (e.g. 1, 30)
RSYNC="rsync -a --delete --numeric-ids"

#TODO: Add node-01, node-02, node-03, ubuntu@srv-3
for UserHost in ubuntu@srv-1\
         ubuntu@srv-2\
         ubuntu@code ubuntu@vm-fatigue-limesurvey ubuntu@vm-fatigue-mobile ubuntu@vm-fatigue-model-comp ubuntu@vm-ppo-mandarin root@wsu-mm;
  do
    DATE=`date "+%Y-%m-%d-%T-%Z"` # Date and time in UTC, get at start of each host's run
    USER=`echo $UserHost | cut -d"@" -f1`
    HOST=`echo $UserHost | cut -d"@" -f2`
    BDIR="$BACKUP_DIR/$HOST" # Base Backup Directory
    DDIR="$BDIR/daily"  # Daily Backup Directory
    WDIR="$BDIR/weekly" # Weekly Backup Directory
    MDIR="$BDIR/monthly" # Monthly Backup Directory

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

#  Examplantion of rsync args:
#
#    --ignore-missing-args
#         When rsync is first processing the explicitly requested
#         source files (e.g. command-line arguments or --files-from
#         entries), it is normally an error if the file cannot be
#         found.  This option suppresses that error, and does not
#         try to transfer the file.  This does not affect subsequent
#         vanished-file errors if a file was initially found to be
#         present and later is no longer there.

