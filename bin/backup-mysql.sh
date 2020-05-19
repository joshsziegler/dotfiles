#!/bin/bash
#
# Author:  Josh Ziegler
# Date:    2020-01-31
# License: MIT
#
# This will backup all MySQL databases on this host. It also backs up each
# database to its own file. The former is more useful for cases when the
# databases server dies entirely, while the latter is more useful when you need
# to restore a single database.
#
# - This assumed your login crentials are saved on the system:
#   - In the file $HOME/.my.cnf
#   - OR preferably encrypted in $HOME/.mylogin.cnf via `mysql_config_editor
#     set --user=bob --host=mydbserver --password` (requires MySQL >= 5.6)
# - This assumed all of your databased are InnoDB. If not, you cannot use this
#   method!

# Variables
DUMP_CMD="mysqldump --single-transaction --routines --events --triggers --force --master-data=2"
FILE_PREFIX="mysql-db-backup"
BACKUP_DIR="/home/ubuntu/backups/mysql/"

# DO NOT EDIT BELOW THIS LINE
mkdir -p $BACKUP_DIR
# Backup all databases into a single file
$DUMP_CMD --all-databases > "$BACKUP_DIR/all-databases.sql"
# Backup each database to it's own file
for DB in $(mysql -e 'show databases' -s --skip-column-names); do
    if [[ $DB == "information_schema" || $DB == "mysql" || $DB == "performance_schema" || $DB == "sys" ]]; then
        continue; # Skip these meta tables. They already exist in the all-databases.sql
    fi 
    $DUMP_CMD $DB > "$BACKUP_DIR/$DB.sql";
done

