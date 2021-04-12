#!/bin/sh
# Check if there is a line in /etc/hosts containing "ocsp.apple.com".
# If it doesn't then add it, else it if exists replace it with new line.

if grep -q "ocsp.apple.com" /etc/hosts; then
    echo "Redirect exists for ocsp.apple.com, replacing with new..."
    # Remove line
    /usr/bin/sed -i_bak -e '/ocsp.apple.com/d' /etc/hosts
    # Add redirect
    echo "0.0.0.0 ocsp.apple.com" >> /etc/hosts
    # Reset Hosts
    sudo dscacheutil -flushcache
else
    echo "Redirect does not exist for ocsp.apple.com, adding it now..."
    # Add redirect
    echo "0.0.0.0 ocsp.apple.com" >> /etc/hosts
    # Reset DNS
    sudo dscacheutil -flushcache
fi

exit 0