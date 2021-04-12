#!/bin/zsh

#Set this value to a domain, typically your corporate search domain would be used
DomainAppend="land.tech"

LocalHostName=$(/usr/sbin/scutil --get LocalHostName)

SetHostName="${LocalHostName}.${DomainAppend}"

HostName=$(/usr/sbin/scutil --get HostName)

echo "Current HostName is ${HostName}"

if [ "${HostName}" != "${SetHostName}" ]; then 
	echo "Current HostName ${HostName} doesnt not match desired value"
	
	#This line sets the hostname to the Mac computer's current LocalHostName appended by a domain 
	/usr/sbin/scutil --set HostName ${SetHostName}
	
	#Check Host Name
	HostName=$(/usr/sbin/scutil --get HostName)
	
	#Validates if the HostName changed
	if [ "${HostName}" != "${SetHostName}" ]; then 
		echo "Set HostName Failed..."
		echo "HostName is ${HostName}"
		exit 1
	else 
		echo "Set HostName Succeeded..."
		echo "HostName is now ${HostName}"
		exit 0
	fi
fi