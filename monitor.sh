#!/bin/bash

function sendMail() {
	SUBJECT="[$1] nomad-server backup result"
	printf "Subject: ${SUBJECT}\nFrom: Nomad Backupper\n\n%s" "$2" | ssmtp -vvv MONITORING_EMAIL
}


# list the ftp content
FTP_OUTPUT=`lftp -f lftp-ls-script`

# build todays backup file name for comparison
DOY=`awk '{print intval $1}' <<<\`date +'%j'\``
TODAYS_FILENAME="backup_$(($DOY % 2)).tar.gz"


# check for our two backup files
while read line ; do
   FILENAME=`echo $line | awk '{print $9}'`
   FILEDATE=`echo $line | awk '{print $6 " " $7 " " $8}'`
   FILEDATE_UNIX=`date '+%s' -d "${FILEDATE}"`


   if [[ "$FILENAME" =~ ^backup_[01]\.tar\.gz$ ]]
   then
   	if [ $FILENAME = $TODAYS_FILENAME ] 
   	then
   		  FILESIZE_TODAY=`echo $line | awk '{print $5}'`
		  FILEAGE_TODAY=$((`date '+%s'` - $FILEDATE_UNIX))
   	else
   		  FILESIZE_YESTERDAY=`echo $line | awk '{print $5}'`
		  FILEAGE_YESTERDAY=$((`date '+%s'` - $FILEDATE_UNIX))
   	fi
   fi	
done <<< "$(echo -e "$FTP_OUTPUT")"


# if we don't have found sizes for both backup files we exit here
if [ -z $FILESIZE_TODAY ] || [ -z $FILESIZE_YESTERDAY ]
then
	echo "Did not found both files"
	sendMail "WARNING" "Did not found two backup files. This is okay, if the backupper runs for the first time or you switched to a new backup location"
	exit;
fi

# if todays backup file is older than 12hrs something went wrong
if [ $AGE_TODAY -gt 43200 ]
then
	sendMail "ERROR" "Age of todays backup file is ${AGE_TODAY} seconds, therefore it seems the backup has not been run"
	exit;
fi

# if yesterdays backup is older than 30hrs or younger than 20hrs something went also wrong
if [ $AGE_YESTERDAY -gt 108000 ] || [ $AGE_YESTERDAY -lt 72000 ]
then
	sendMail "ERROR" "Age of yesterdays backup file is ${AGE_YESTERDAY} seconds, therefor it seems yesterdays backup did not run or there is some mismatch with the filenames (could happen on first/last day of a switching-year)"
	exit;
fi



# calculate difference in percent
DIFFERENCE=`awk '{print ($1/$2*100)-100}' <<<"${FILESIZE_TODAY} ${FILESIZE_YESTERDAY}"`
DIFFERENCE_INT=`awk '{print int($1)}' <<< $DIFFERENCE`


# warn if difference between todays and yesterdays backup is more than 5%
if [ $DIFFERENCE_INT -gt 5 ] || [ $DIFFERENCE_INT -lt -5 ]
then
	SUBJECT_PREFIX="LARGE DIFFERENCE"
else
	SUBJECT_PREFIX="OKAY"
fi

DIFF_PREFIX='+';
if [ $DIFFERENCE_INT -lt 0 ] 
then 
	DIFF_PREFIX = '-' 
fi

sendMail $SUBJECT_PREFIX "`printf "Backup was done and the new file size is $(( $FILESIZE_TODAY / 1025 / 1024 ))MB ${DIFF_PREFIX}${DIFFERENCE}%%"`"
