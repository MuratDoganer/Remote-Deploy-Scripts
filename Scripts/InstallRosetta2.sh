#!/bin/zsh

#Determine the processor brand
processorBrand=$(/usr/sbin/sysctl -n machdep.cpu.brand_string)

if [[ "${processorBrand}" = *"Apple"* ]]; then
  echo "Apple Processor is present..."
else
  echo "Apple Processor is not present... rosetta not needed"
  exit 0
fi

#Check if the Rosetta service is running
checkRosettaStatus=$(/bin/launchctl list | /usr/bin/grep "com.apple.oahd-root-helper")

if [[ "${checkRosettaStatus}" != "" ]]; then
  echo "Rosetta is installed... no action needed"
  exit 0
else
  echo "Rosetta is not installed... installing now"
fi

#Installs Rosetta
/usr/sbin/softwareupdate --install-rosetta --agree-to-license

#Checks the outcome of the Rosetta install
if [[ $? -eq 0 ]]; then
  echo "Rosetta installed... exiting"
  exit 0
else
  echo "Rosetta install failed..."
  exit 1
fi

exit 0