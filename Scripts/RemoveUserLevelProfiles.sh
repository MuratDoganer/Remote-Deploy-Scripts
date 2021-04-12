#!/bin/zsh

#This collects a list of all installed configuration profiles, removes the last line stating the number of profiles installed
profileDump=$(sudo /usr/bin/profiles -P | /usr/bin/grep -vw "There")

#This line filters out the computerlevel profiles, leaving only the user-level profiles in the list
profileLevel=$(echo ${profileDump} | /usr/bin/grep -vw "_computerlevel" | /usr/bin/awk '{print $1}')

#This line determines the profile(s) identifiers
profilesToRemove=$(echo "${profileDump}" | /usr/bin/grep -F "${profileLevel} attribute: profileIdentifier: " | /usr/bin/awk '{print $4}')


for profile in ${=profilesToRemove}; do
	
	#This line determines the username of the account with the user-level profile installed 
	Username=$(echo ${profileDump} | /usr/bin/grep "${profile}" | /usr/bin/grep -vw "_computerlevel" | /usr/bin/awk '{print $1}' | /usr/bin/cut -f1 -d "[")
	
	echo "Profile Identifier: ${profile} installed for User: ${Username}... removing profile"
	
	#This line removes the profile for the specific user it is installed for
	/usr/bin/profiles -R -p ${profile} -U ${Username}
	
done 

echo "Done removing User Level Profiles..."

exit 0