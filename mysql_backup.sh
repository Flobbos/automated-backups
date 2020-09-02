#!/bin/bash
#------------------------------------------------#
# Variables here will be used in execution below #
#------------------------------------------------#
# Set the timestamp
TIMESTAMP=$(date '+%Y%m%d%H%M')
# Database
DB="db_to_backup"
# Database user
DB_USER="user_for_db"
# Database password
DB_PASSWORD='supersecret'
# Linode bucket
BUCKET="account-sql"
# Path for backup file
BACKUP_DIR="/home/account/backups"
#------------------------------------------------#
# Actual execution                               #
#------------------------------------------------#
# Backup database
echo "Backing up $DB to db_$TIMESTAMP.sql"
# Use this line for manual backups to make them pretty
#/usr/bin/mysqldump -u $DB_USER -p$DB_PASSWORD $DB | (/usr/bin/pv --timer --rate --bytes > $BACKUP_DIR/db_$TIMESTAMP.sql)
# Use this line for cron based backups
/usr/bin/mysqldump -u $DB_USER -p$DB_PASSWORD $DB > $BACKUP_DIR/db_$TIMESTAMP.sql
# Upload the file to Linode
echo "Uploading $BACKUP_DIR/db_$TIMESTAMP.sql"
/usr/bin/s3cmd put $BACKUP_DIR/db_$TIMESTAMP.sql s3://$BUCKET -P
# Delete the file locally
/usr/bin/rm $BACKUP_DIR/db_$TIMESTAMP.sql
# All done
echo "Backup complete"