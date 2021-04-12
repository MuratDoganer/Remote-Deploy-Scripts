#!/bin/bash

#Gets the current value for the timestamp_timeout value
timestampTimeoutCurrenState=$(/bin/cat "/etc/sudoers" | /usr/bin/grep 'Defaults timestamp_timeout=')

#Checks if the current value is already set to 5
if [ "${timestampTimeoutCurrenState}" = "Defaults timestamp_timeout=5" ]; then
	echo "timestamp_timeout is already set to 5 minutes... no changed needed..."
	exit 0
else 
	echo "timestamp_timeout is not set to 5 minutes...changes needed..."
fi 
	
#Copies the current sudoers file
/bin/cp /etc/sudoers /tmp/sudoers-tmp

#Uses sed to find and replace the default timestamp line
/usr/bin/sed -i -backup 's/Defaults timestamp\_timeout\=0/Defaults timestamp\_timeout\=5/g' /tmp/sudoers-tmp

#Uses visudo to validate the syntax of the new file prior to copying
/usr/sbin/visudo -cf /tmp/sudoers-tmp

attempt="1"

fCopyModifiedFile ()
{
	while [ ${attempt} -lt 4 ]
	do
		
		if [ ${attempt} -gt 1 ]; then 
			sleep 10
		fi
	
			echo "Starting copy attempt number ${attempt}"
			/bin/cp /tmp/sudoers-tmp /etc/sudoers
			
			if [ $? -eq 0 ]; then
				echo "Sudoers file replaced successfully."
				fDeleteTmpFiles
				exit 0
			else
				echo "Failed to copy the new file ${attempt} times... Attempting recovery..."
				attempt=$[${attempt}+1]
				fCopyModifiedFile
			fi
	done
	
	echo "Max copy attempts reached. Please restore the backup manually from /tmp/sudoers-backup"
	exit 2
}

fDeleteTmpFiles ()
{
	echo "Deleting /tmp/sudoers-backup-modified & /tmp/sudoers-backup"
	/bin/rm -f "/tmp/sudoers-tmp-backup"
	/bin/rm -f "/tmp/sudoers-tmp"
}

##Checks if the validation was successful; if so, proceeds with copying the new file.
if [ $? -eq 0 ]; then
	echo "Sudoers file validated... attempting copy"
	fCopyModifiedFile
else
	echo "Syntax validation failed. Please edit the file manually using visudo... removing backup and modified files since nothing was changed..."
	fDeleteTmpFiles
	exit 1
fi