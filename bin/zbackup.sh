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
                                                                                                         
#TODO: Add node-01, node-02, node-03                                                                     
for UserHost in ubuntu@srv-1 ubunt@srv-2 ubuntu@srv-3 ubuntu@code ubuntu@vm-fatigue-limesurvey ubuntu@vm-fatigue-mobile ubuntu@vm-fatigue-model-comp ubuntu@vm-ppo-mandarin root@wsu-mm;                          
  do                                                                                                     
    DATE=`date "+%Y-%m-%d-%T-%Z"` # Date and time in UTC, get at start of each host's run                
    USER=`echo $UserHost | cut -d"@" -f1`                                                                
    HOST=`echo $UserHost | cut -d"@" -f2`                                                                
    BDIR="$BACKUP_DIR/$HOST" # Base Backup Directory                                                     
    DDIR="$BDIR/daily"  # Daily Backup Directory                                                         
    WDIR="$BDIR/weekly" # Weekly Backup Directory                                                        
    MDIR="$BDIR/monthly" # Monthly Backup Directory                                                      
                                                                                                         
    echo "*** Creating daily backup for $HOST on $DATE..."                                               
    # TODO: Re-enable --ignore-missing-args to avoid non-errors for missing 
    #       directories (doesn't work with old versions of rsync)
    #rsync -aq --delete --numeric-ids --ignore-missing-args -e "ssh" --rsync-path="sudo rsync" $USER@$HOST:/$DIRS $BDIR                                                                                           
    rsync -aq --delete --numeric-ids -e "ssh" --rsync-path="sudo rsync" $USER@$HOST:/$DIRS $DDIR         
    # Create a file in the backup indicating when this back was created for easy identification          
    touch "$DDIR/BackupCreatedOn$DATE.txt"                                                               
                                                                                                         
    # Run weekly backup on Sundays (sync currently daily to the weekly directory)                        
    # TODO: Only run if the daily succeeds to avoid overwriting good data?                               
    if [ "$DOW" == "Thursday" ]; then                                                                    
        echo "*** Creating weekly backup..."                                                             
        rsync -aq --delete --numeric-ids $DDIR $WDIR                                                     
    fi                                                                                                   
                                                                                                         
    # Run monthly backup on the first day of the month (sync currently weekly to the monthly directory)  
    # TODO: Only run if the daily succeeds to avoid overwriting good data?                               
    if [ "$DOM" == "1" ]; then                                                                           
        echo "*** Creating monthly backup..."                                                            
        rsync -aq --delete --numeric-ids $WDIR $MDIR                                                     
    fi                                                                                                   
  done 
