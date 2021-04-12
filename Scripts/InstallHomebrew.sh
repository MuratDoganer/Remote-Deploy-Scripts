#!/bin/bash

mostCommonUser=$(/usr/bin/last -t console | awk '!/_mbsetupuser|root|wtmp/' | /usr/bin/cut -d" " -f1 | /usr/bin/uniq -c | /usr/bin/sort -nr | /usr/bin/head -n1 | /usr/bin/grep -o '[a-zA-Z].*')

if [ -e "/usr/local/bin/brew" ]; then 
	echo "Brew is already installed..."
	exit 0
else 
	echo "Brew is not yet installed..."
fi

if [ "${mostCommonUser}" = "" ]; then
	echo "There is no common user other than root or _mbsetupuser... try again later"
	exit 0
fi

echo "${mostCommonUser} is the most common console user... installing homebrew as this user"

export HOME=$(/usr/bin/mktemp -d)
export USER=root
export PATH="/usr/local/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
BREW_INSTALL_LOG=$(/usr/bin/mktemp)

# Install Homebrew | removes all interactive prompts
/bin/bash -c "$(/usr/bin/curl -fsSL \
	https://raw.githubusercontent.com/Homebrew/install/master/install.sh | \
	sed "s/abort \"Don't run this as root\!\"/\
	echo \"WARNING: Running as root...\"/" | \
	sed 's/  wait_for_user/  :/')" 2>&1 | /usr/bin/tee ${BREW_INSTALL_LOG}

# Reset Homebrew permissions for target user
brew_file_paths=$(/usr/bin/sed '1,/==> This script will install:/d;/==> /,$d' \
	${BREW_INSTALL_LOG})
	
brew_dir_paths=$(/usr/bin/sed '1,/==> The following new directories/d;/==> /,$d' \
	${BREW_INSTALL_LOG})
	
/usr/sbin/chown -R "${mostCommonUser}":admin ${brew_file_paths} ${brew_dir_paths}

/usr/bin/chgrp admin /usr/local/bin/

/bin/chmod g+w /usr/local/bin

# Unset home/user environment variables
unset HOME
unset USER

# Finish brew installation by forcing an update 
/usr/bin/su - "${mostCommonUser}" -c "/usr/local/bin/brew update --force"

# Run brew cleanup prior to checking install status
/usr/bin/su - "${mostCommonUser}" -c "/usr/local/bin/brew cleanup"

# Check brew install status
/usr/bin/su - "${mostCommonUser}" -c "/usr/local/bin/brew doctor"

# Checks the exit status of the brew doctor to command to ensure it exited 0, indicating a successful install
if [[ $? -eq 0 ]]; then
	echo "Homebrew installation successful..."
	exit 0
else
	echo "Homebrew installation failed..."
	exit 1
fi