# lists of ip/net for iptable and route management

# gateway ip address
export gwip="192.168.1.1"

# external dns
#export dns_ext="8.8.8.8" # google dns
export dns_ext="1.1.1.1" # cloudflare dns

# internal dns, resolve local network name only
export dns_int="192.168.1.1"

# ip address and/or subnet that will not go through vpn
export hs=""
hs+=" 10.0.0.0/8"     # class a,
hs+=" 172.16.0.0/12"  # class b,
hs+=" 192.168.0.0/16" # class c, route add may echo    RTNETLINK answers: File exists
#hs+=" 11.22.33.44"    # example, friend's ip to directly connect
#hs+=" 33.22.11.0/26"  # example, friend internet subnet



#
# do not edit below unless you know what you are doing
#

# try to find nic
# it could be eth0, en0, em0, eno0
export nic_in=""   # nic in
export nic_out=""  # nic out
# eth0
if [ -n "$(ifconfig eth0 2>/dev/null|grep flags)" ]; then
export nic_in="eth+"
export nic_out="eth+"
fi
# en0
if [ -n "$(ifconfig en0 2>/dev/null|grep flags)" ]; then
export nic_in="en+"
export nic_out="en+"
fi
# em0
if [ -n "$(ifconfig em0 2>/dev/null|grep flags)" ]; then
export nic_in="em+"
export nic_out="em+"
fi
# eno0
if [ -n "$(ifconfig eno0 2>/dev/null|grep flags)" ]; then
export nic_in="eno+"
export nic_out="eno+"
fi
# eno0
if [ -n "$(ifconfig 2>/dev/null|grep enx|grep flags)" ]; then
export nic_in="enx+"
export nic_out="enx+"
fi
# catch
if [ -z "$nic_in" ]; then
	echo "NIC not found!"
	exit 16
fi
