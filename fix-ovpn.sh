#!/usr/bin/env bash

if [ `whoami` != 'root' ]; then
    echo "Must run this script as root"
    exit 13
fi

if [ -z "$1" ]; then
	echo "Require vpn provider name"
	echo "Example $0 foo"
	exit 14
fi


export OV=/etc/openvpn
export OVC=$OV/client

if [ ! -e "/usr/local/lib/lazypivpn/providers/$1.sh" ]; then
	echo "Error, $1 provider not exist!"
	exit 15
fi

# execute openvpn setup for specific provider
bash /usr/local/lib/lazypivpn/providers/$1.sh -s $1

# prepare vpn user/pass file
echo "username
password
" >> $OVC/userpass.txt
chmod 600 $OVC/userpass.txt

# link because systemctl and openvpn client/server pathing
ln -f -s $OVC/client.conf $OV/client.conf

exit 0