# Dspace Backup Commands 

How to Setup Automatic Daily Backup of Dspace Database & Files 


To setup **Automatic Daily DSpace Backup**, follow the steps below:

---

## 1. Create Backup Directory
First, login to root user and create a directory for backup:

```bash
$ sudo su
```
#### Enter Login password when prompted
```
$ mkdir dspace_backup
$ sudo chmod 777 dspace_backup
$ exit
```

## 2. Create Backup Script
Change directory to /usr/local/bin/ and create a script file:

```bash
$ cd /usr/local/bin/
$ nano backup.sh
```
Copy the below script into the file and save it:

```bash
#!/bin/bash

# Setup shell to use for backups
SHELL=/bin/bash

# Setup name of local server to be backed up
SERVER="%10.100.8.20%"

# Setup event stamps
DOW=`date +%a`
TIME=`date`

# Setup paths
FOLDER="/home/backup"
FILE="/var/log/backup-$DOW.log"

# Do the backups
{
echo "Backup started: $TIME"

# Make the backup folder if it does not exist
if test ! -d /home/backup
then
  mkdir -p /home/backup
  echo "New backup folder created"
else
  echo ""
fi

# Make sure we're in / since backups are relative to that
cd /

## PostgreSQL database (Needs a /root/.pgpass file)
which -a psql
if [ $? == 0 ] ; then 
    echo "SQL dump of PostgreSQL databases"
    su - postgres -c "pg_dump --inserts dspace > /tmp/dspace-db.sql"
    cp /tmp/dspace-db.sql $FOLDER/dspace-db-$DOW.sql
    su - postgres -c "vacuumdb --analyze dspace > /dev/null 2>&1"
fi

# Backup '/dspace' folder
echo "Archive '/dspace' folder"
tar czf $FOLDER/dspace-$DOW.tgz dspace/

# View backup folder
echo ""
echo "** Backup folder **"
ls -lhS $FOLDER

# Show disk usage
echo ""
echo "** Disk usage **"
df -h

TIME=`date`
echo "Backup ended: $TIME"

} > $FILE

### EOF ###
```

Alternative Script

```bash
#!/bin/bash
PGPASSWORD="dspace" pg_dump -U dspace -h localhost -Fc dspace | gzip > dspace_backup/dspace-$(date +%Y-%m-%d-%H.%M.%S).sql.gz
now=$(date +"%d_%m_%Y")
zip -r  /home/server/dspace_backup/$now-assetstore.zip /dspace/assetstore
zip -r  /home/server/dspace_backup/$now-log.zip /dspace/log
```
 Change [username] & [password] as per your DSpace Database Credentials.

## 3. Make Script Executable
``` bash
$ sudo chmod +x backup.sh
```

Test the script manually:

```bash
$ sh backup.sh
```
## 4. Schedule Automatic Backup with Cron Job
Open crontab:

```bash
$ crontab -e
```
Choose nano editor if prompted.
Add one of the following lines at the end:

```bash
55 04 * * * /usr/local/bin/backup.sh
```
or

```bash
15 13 * * * /usr/local/bin/backup.sh
00 14 * * * find dspace_backup/* -mtime +180 -exec rm {} ;
```
Save using Ctrl+O, press Enter, then exit with Ctrl+X.

## Done

Now, this cron job will:

> Take automatic daily backup of DSpace Database, Files & Logs.

> Store backups inside dspace_backup folder.

> Automatically delete backup files older than 180 days.
