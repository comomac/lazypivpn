#!/usr/bin/env bash

if [ `whoami` != 'root' ]; then
    echo "Must run this script as root"
    exit
fi

# set nic ip and dns
cat <<EOT >> /etc/dhcpcd.conf
interface eth0
# change ip_address to desired rpi ip and subnet
static ip_address=192.168.1.22/24
# change routers, put just one
static routers=192.168.1.1
# do not change
static domain_name_servers=127.0.0.1
EOT
