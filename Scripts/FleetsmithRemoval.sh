#!/bin/bash

#This portion removes the Fleetsmith Agent

DEVICE_ID=$(/usr/bin/sqlite3 /opt/fleetsmith/data/store.db "SELECT value FROM auth WHERE name = 'device_id';")
if test ! "${DEVICE_ID}" = ""; then
	/usr/bin/security delete-identity -c "${DEVICE_ID}" /Library/Keychains/System.keychain
fi

LOGIN_UID=$(/usr/bin/stat -f "%Du" /dev/console)
/bin/launchctl bootout "gui/${LOGIN_UID}" /Library/LaunchAgents/com.fleetsmith.*

/bin/launchctl unload /Library/LaunchDaemons/com.fleetsmith.*
/bin/launchctl unload /Library/LaunchAgents/com.fleetsmith.*

/usr/bin/pkill Fleetsmith
/usr/bin/pkill fsagent
/usr/bin/pkill fsupdater

/bin/rm /Library/LaunchDaemons/com.fleetsmith.*
/bin/rm /Library/LaunchAgents/com.fleetsmith.*

/bin/rm -rf /opt/fleetsmith
/bin/rm -rf /Applications/Fleetsmith.app

/usr/sbin/pkgutil --forget com.fleetsmith.agent

#Change the profileID variable to the prefix you want to match
profileID="com.fleetsmith"

# the profiles variable will be set to an array of profiles that match the prefix in the profileID variable
profiles=$(/usr/bin/profiles list | grep "$profileID" | sed 's/.*\ //')


# if matching profiles are found, loop through the array and remove each profile
if [[ ${#profiles[@]} -eq 0 ]]; then
	echo "no profiles with ID $profileID were found"
else
	for i in ${profiles[*]}
	do
		echo "Found $i"
		/usr/bin/profiles -R -p "${i}"
		echo "Removed $i"
	done
fi
exit 0

echo "Fleetsmith cleanup done..... welcome to Kandji, the Modern MDM for Apple devices."

exit 0
