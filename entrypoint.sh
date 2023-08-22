#!/bin/bash

mkdir /root/backup

# make mysql dumps
mariadb-dump -uroot -p${MARIADB_ROOT_PASSWORD} -h${MARIADB_DATABASE_HOSTNAME} -P${MARIADB_DATABASE_PORT} --all-databases > /root/backup/dump.sql

# install ghbackup if we have a github token
if [ "$GITHUB_TOKEN" != "" ] ; then go install qvl.io/ghbackup@latest ; fi

# backup github if we have a github token
if [ "$GITHUB_TOKEN" != "" ] ; then ./go/bin/ghbackup -secret ${GITHUB_TOKEN} -account ${GITHUB_ACCOUNT} /root/backup/ghbackup ; fi

# tar.gz everything
DOY=`awk '{print intval $1}' <<<\`date +'%j'\``
TODAYS_FILENAME="backup_$(($DOY % 2)).tar.gz"
tar czfv "/root/${TODAYS_FILENAME}" /root/backup/**


# upload everything via ftp
sed -i "s/FTP_HOST/${FTP_HOST}/g" /root/lftp-script
sed -i "s/FTP_HOST/${FTP_HOST}/g" /root/lftp-ls-script
sed -i "s/FTP_USER/${FTP_USER}/g" /root/lftp-script
sed -i "s/FTP_USER/${FTP_USER}/g" /root/lftp-ls-script
sed -i "s/FTP_PASS/${FTP_PASS}/g" /root/lftp-script
sed -i "s/FTP_PASS/${FTP_PASS}/g" /root/lftp-ls-script
sed -i "s/FTP_DIR/${FTP_DIR}/g" /root/lftp-script
sed -i "s/FTP_DIR/${FTP_DIR}/g" /root/lftp-ls-script

cat /root/lftp-script

lftp -f /root/lftp-script

# check if everything worked well
if [ "$MONITORING_EMAIL" != "" ] && [ "$SMTP_HOST" != "" ] && [ "$SMTP_USER" != "" ] && [ "$SMTP_PASS" != "" ]
then
  sed -i "s/SMTP_HOST/${SMTP_HOST}/g" /etc/ssmtp/ssmtp.conf
  sed -i "s/SMTP_USER/${SMTP_USER}/g" /etc/ssmtp/ssmtp.conf
  sed -i "s/SMTP_PASS/${SMTP_PASS}/g" /etc/ssmtp/ssmtp.conf
  sed -i "s/MONITORING_EMAIL/${MONITORING_EMAIL}/g" /root/lftp-ls-script
  ./monitor.sh
fi
