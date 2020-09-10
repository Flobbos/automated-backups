#!/bin/bash
if [ -f .env ]
then
    export $(cat .env | sed 's/#.*//g' | xargs)
else
    echo "No environment file present." >> /dev/stderr
    exit
fi
#------------------------------------------------#
# Variables here will be used in execution below #
#------------------------------------------------#
# Set the timestamp
TIMESTAMP=$(date '+%Y%m%d%H%M')
#------------------------------------------------#
# Actual execution                               #
#------------------------------------------------#
# Backup database
echo "Backing up $DB to db_$TIMESTAMP.sql"
# Use this line for manual backups to make them pretty
#/usr/bin/mysqldump -u $DB_USER -p$DB_PASSWORD $DB | (/usr/bin/pv --timer --rate --bytes > $BACKUP_DIR/db_$TIMESTAMP.sql)
# Use this line for cron based backups
/usr/bin/mysqldump -u $DB_USER -p$DB_PASSWORD $DB > $BACKUP_DIR/db_$TIMESTAMP.sql
# Zip sql file
echo "Zipping SQL file"
/usr/bin/gzip $BACKUP_DIR/db_$TIMESTAMP.sql
# Upload the file to Linode
echo "Uploading $BACKUP_DIR/db_$TIMESTAMP.sql"
/usr/bin/s3cmd put $BACKUP_DIR/db_$TIMESTAMP.sql.gz s3://$SQL_BUCKET -P
# Delete the file locally
/usr/bin/rm $BACKUP_DIR/db_$TIMESTAMP.sql.gz
# All done
echo "Backup complete"