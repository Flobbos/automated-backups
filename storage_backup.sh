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
# Zip files
echo "Backing up directory: $BACKUP_TARGET"
cd $BACKUP_DIR && /usr/bin/tar -czf storage_$TIMESTAMP.tar.gz $BACKUP_TARGET
# Upload the file to Linode
echo "Uploading storage_$TIMESTAMP.tar.gz"
/usr/bin/s3cmd put $BACKUP_DIR/storage_$TIMESTAMP.tar.gz s3://$BUCKET -P
# Delete the file locally
rm $BACKUP_DIR/storage_$TIMESTAMP.tar.gz
echo "Backup complete"