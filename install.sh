#!/usr/bin/env bash

if [ `whoami` != 'root' ]; then
    echo "Must run this script as root"
    exit 11
fi

# install necessary bits
apt-get -y update
apt-get -y install ruby2.3 ruby2.3-dev openvpn
gem install rubydns rake process-daemon envbash

# download codes
cd /usr/local/sbin
XURL="https://raw.githubusercontent.com/comomac/lazypivpn/master/"
curl ${XURL}/dnsd.rb > dnsd.rb
curl ${XURL}/fix-ovpn.sh > fix-ovpn.sh
curl ${XURL}/setup_nic.sh > setup_nic.sh
curl ${XURL}/iptables-novpn > iptables-novpn
curl ${XURL}/iptables-vpn > iptables-vpn
curl ${XURL}/vpn-link-setup > vpn-link-setup

# set executable
chmod +x dnsd.rb fix-ovpn.sh setup_nic.sh iptables-vpn iptables-novpn vpn-link-setup

# download vpn providers
mkdir -p /usr/local/lib/lazypivpn/providers
cd /usr/local/lib/lazypivpn/providers
curl ${XURL}/providers/pia.sh > pia.sh

# download lib
curl ${XURL}/ipnet.sh > /usr/local/lib/lazypivpn/ipnet.sh

# setup network card
/usr/local/sbin/setup_nic.sh

# add boot up code
if [[ -z "$(grep 'Start DNS daemon' /etc/rc.local)" ]]; then
echo "# VPN Protect Link
/usr/local/sbin/iptables-vpn
# Start DNS daemon
/usr/local/sbin/dnsd.rb start" > /tmp/insert.txt
sed -i '$e cat /tmp/insert.txt' /etc/rc.local
rm /tmp/insert.txt
fi

# set crontab
crontab -l > /tmp/mycron
if [[ -z "$(grep 'make sure dns' /tmp/mycron)" ]]; then
echo "# make sure dns is setup immediately
@reboot /usr/local/sbin/vpn-link-setup > /dev/null 2>&1
# if vpn is down, reinitiate openvpn
#* * * * * /usr/local/sbin/vpn-link-setup > /dev/null 2>&1" >> /tmp/mycron
crontab /tmp/mycron
fi
rm /tmp/mycron

# all done
echo 'Nearly done, please follow rest of the instructions on the README.md'

exit 0

