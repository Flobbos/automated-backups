# Automated Backups

The following shell scripts can be used to backup MySQL databases and any folders thrown at it.

### Docs

-   [Prerequisites](#prerequisites)
-   [Buckets](#buckets)
-   [Configuration](#configuration)
-   [Cron](#cron)
-   [Manual backups](#manual-backups)

## Prerequisites

### Object Storage

Any AWS S3 compatible object storage can hold storage buckets that will be used to store the backups. You need to configure your s3cmd installation for use with the respective object storage. You can either create new buckets from the CLI or create them from the your online management console.

Naming suggesions are:

SQL
account-sql for SQL backups. Where account is the user's account you want the backup to be made from.

Files
account-storage for files you want backed up.

Object storage works differently from other types of storage so think of a bucket as a folder where you put your stuff.

### Server (s3cmd)

All API integration is done via s3cmd, an oder but simple CLI for S3 comaptible cloud storage APIs. You need to install this on the server either under root or for every user. It needs to be configured for every user in a CageFS/Cloudlinux scenario anyways.

### CentOS installation

```bash
yum install s3cmd
```

### Ubuntu installation

```bash
apt-get install s3cmd
```

After the installation you need to configure s3cmd for every account you want to use it under. Go into the root folder of the account on the server via ssh and run the following:

```bash
s3cmd --configure
```

This will result in a .s3cfg file being written to the root folder of the user account.

```bash
Access Key: youraccesskey
Secret Key: enteryoursecretkeyhere
Default Region: US
S3 Endpoint: eu-central-1.linodeobjects.com
DNS-style bucket+hostname:port template for accessing a bucket: us-east-1.linodeobjects.com
Encryption password:
Path to GPG program:
Use HTTPS protocol: False
HTTP Proxy server name:
HTTP Proxy server port: 0
host_base = eu-central-1.linodeobjects.com
host_bucket = %(bucket).website-eu-central-1.linodeobjects.com/
website_endpoint = http://%(bucket)s.website-eu-central-1.linodeobjects.com/
```

You will most likely need to set the last 3 entries manually after the configuration process because these values default to
Amazon S3 but this depends on which object storage you're using.

### Backup folder

To work with backups I suggest you add a folder called backups in the root folder of the account where you run the backups.

## Configuration

In order for the scripts to work you need to change a few variables inside the .env file provided with this repo.

```env
DB='db_blah'
DB_USER='db_user'
DB_PASSWORD='supersecret'
BUCKET='your-bucket'
BACKUP_DIR='/home/account/backups'
BACKUP_TARGET='/home/account/folder/to/backup'
```

Update the above values to match the settings you need for the current account you're running backups in.

## Buckets

### Creating a bucket

If you haven't created new buckets in the your console you can create buckets right from the CLI.

```bash
s3cmd mb s3://my-bucket-name
```

### Removing a bucket

Sometimes you may want to remove an entire bucket. You can't do this from the control panel when the bucket still contains
files. This is at least true for Linode object storage. In order to get rid of a bucket and all its contents you can use the following command.

```bash
s3cmd rb -r -f s3://my-bucket-name/
```

WARNING: There is no confirmation for doing this or any other safety net. What is deleted is deleted forever!

### Life cycle policy

In order to have Linode manage the life cycle of your backups you nee to set a life cycle policy in XML format. A file with
a working sample configuration is provided for sql and file buckets. The important part is the expiration setting in days. This defines how long files will be kept in storage after they have been created.

### SQL life cycle

File: lifecycle-sql.xml

```xml
<LifecycleConfiguration>
    <Rule>
        <ID>delete-old-sql</ID>
        <Prefix></Prefix>
        <Status>Enabled</Status>
        <Expiration>
            <Days>7</Days>
        </Expiration>
    </Rule>
</LifecycleConfiguration>
```

### Storage life cycle

File: lifecycle-storage.xml

```xml
<LifecycleConfiguration>
    <Rule>
        <ID>delete-old-files</ID>
        <Prefix></Prefix>
        <Status>Enabled</Status>
        <Expiration>
            <Days>14</Days>
        </Expiration>
    </Rule>
</LifecycleConfiguration>
```

You can set a life cycle policy for every bucket individually.

```bash
s3cmd setlifecycle lifecyle-whatever.xml s3://my-bucket-name
```

To check if your life cycle policy is set or to check the settings run:

```bash
s3cmd getlifecycle s3://my-bucket-name
```

There are many options you can set for controlling storage life cycles. A detailed description about life cycle options can be found on the Linode website [here](https://www.linode.com/docs/platform/object-storage/how-to-manage-objects-with-lifecycle-policies)

## Cron

To automate the process you need to setup a cronjob to take care of running the scripts.

### Script permissions

The scripts need to have executable permissions set to them like so:

```bash
chmod +x mysql_backup.sh
chmod +x storage_backup.sh
```

### Cronjobs

You can either go into cPanel and set the cronjob there or manually do this by running:

```bash
crontab -e
```

This will open Vim that lets you edit the crontab. Add the following line for the daily MySQL backup.

```vim
SHELL="/bin/bash"
0 0 * * * cd /home/account/backups && ./mysql_backup.sh
```

Add this line if you want to backup files once a week.

```vim
SHELL="/bin/bash"
0 0 * * 0 cd /home/account/backups && ./storage_backup.sh
```

## Manual backups

You also have the option to run backups manually by just executing the backup scripts via ssh.

```bash
cd /home/account/backups
./mysql_backup.sh
```

You will get output from this operation as it runs.
