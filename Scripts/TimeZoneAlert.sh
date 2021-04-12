#!/bin/zsh

# Set the value of this variable to the expected time zone, you can find this value by running this command in terminal on a Mac set to your expected time zone
# Example command: /usr/sbin/systemsetup -gettimezone | awk '{ print $3 }'

expectedTimeZone="Europe/London"

# Do not modify below this line 
currentTimeZone=$(/usr/sbin/systemsetup -gettimezone | /usr/bin/awk '{ print $3 }')

echo "Current time zone is ${currentTimeZone}...desired time zone is ${expectedTimeZone}"

if [[ "${currentTimeZone}" != "${expectedTimeZone}" ]]; then
	echo "Time Zone does not match desired time zone... throwing an alert now"
	exit 1
else
	echo "Time Zone is as expected... no notification needed..."
	exit 0
fi

echo "unexpected error"
exit 1