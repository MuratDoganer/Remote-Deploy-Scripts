#!/bin/zsh
#This line checks if the folder exist 
if [ ! -e "/Library/Desktop Pictures/" ]; then
	echo "/Library/Desktop Pictures/ does not yet exist... creating now..."
	
	#This line creates the folder if it does not exist
	/bin/mkdir "/Library/Desktop Pictures/"
	/usr/sbin/chown root:wheel "/Library/Desktop Pictures/"
else
	echo "/Library/Desktop Pictures/ already exist..."
fi

exit 0
