#!/bin/sh

mkdir /root/backup

# make mysql dumps
mariadb-dump -uroot -p${MARIADB_ROOT_PASSWORD} -h${MARIADB_DATABASE_HOSTNAME} -P${MARIADB_DATABASE_PORT} --all-databases > /root/backup/dump.sql

# install ghbackup if we have a github token
if [ "$GITHUB_TOKEN" != "" ] ; then go install qvl.io/ghbackup@latest ; fi

# backup github if we have a github token
if [ "$GITHUB_TOKEN" != "" ] ; then ./go/bin/ghbackup -secret ${GITHUB_TOKEN} -account ${GITHUB_ACCOUNT} /root/backup/ghbackup ; fi

# tar.gz everything
tar czfv "/root/backup_$((`date +'%u'` % 2)).tar.gz" /root/backup/**


# upload everything via ftp
sed -i "s/FTP_HOST/${FTP_HOST}/g" /root/lftp-script
sed -i "s/FTP_HOST/${FTP_HOST}/g" /root/lftp-ls-script
sed -i "s/FTP_USER/${FTP_USER}/g" /root/lftp-script
sed -i "s/FTP_USER/${FTP_USER}/g" /root/lftp-ls-script
sed -i "s/FTP_PASS/${FTP_PASS}/g" /root/lftp-script
sed -i "s/FTP_PASS/${FTP_PASS}/g" /root/lftp-ls-script

cat /root/lftp-script

lftp -f /root/lftp-script

