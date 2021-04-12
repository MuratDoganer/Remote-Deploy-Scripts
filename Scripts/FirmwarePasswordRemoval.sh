#!/bin/bash

#Specify your current firmware password
firmwarePasswd="FirmwarePasswordHere"

#Specify the number of seconds before the end user will be forced to restart (This interaction occurs via the Kandji menu bar app similar to other forced restarts) 
rebootDelayInSeconds="1800"

#Do not modify below this line

firmwarePasswdStatus=$(/usr/sbin/firmwarepasswd -check | /usr/bin/awk 'FNR == 1 {print $3}' )

if [ "${firmwarePasswdStatus}" = "No" ]; then
echo "Firmware password is already disabled..."
exit 0
fi 

escapedFirmwarePasswd=$(echo ${firmwarePasswd} | /usr/bin/python -c "import re, sys; print(re.escape(sys.stdin.read().strip()))")

removeCommand=$(/usr/bin/expect<<EOF

spawn /usr/sbin/firmwarepasswd -delete
expect {
	"Enter password:" {
		send "${escapedFirmwarePasswd}\r"
		exp_continue
	}
}
EOF
)

if [[ "${removeCommand}" = *"Must restart before changes will take effect"* ]]; then 
	echo "Firmware Password Removed... changes will take affect after reboot"
	/usr/local/bin/kandji reboot --delaySeconds ${rebootDelayInSeconds}
	exit 0
else
	echo "Firmware password was not removed... an unknown error occured"
	exit 1
fi