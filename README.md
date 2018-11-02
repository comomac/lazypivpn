# Lazy Pi VPN
Setup OpenVPN gateway the ~~lazy~~ easy way.  

I have been using this setup for years, but decided to put the code up to help friends who don't know how to setup VPN.  

This will allow many devices in your network to access VPN without having VPN software installed.

### Features
* Kill switch, so won't leak when VPN is down.
* DNS Leak protection (using protected internal dns server).
* Internal DNS server, allow internal DNS resolution, so you don't need to type in IP if you have machine name in local network, while external DNS will still be resolved over the VPN.

### Why another one Raspberry Pi VPN?
Why not? I've made this long time ago because none exists years ago, it was a fun project.

### Instructions

1. Create Raspbian image and put onto flash card. [instruction](https://www.raspberrypi.org/documentation/installation/installing-images/README.md).
2. Enter command to RPi `curl https://github.com/comomac/lazypivpn/install.sh | sudo bash`
3. Enter command to RPi `sudo fix-ovpn.sh <vpn provider>` replace <vpn_provider> with one of the supported provider below
4. Edit RPi network interface settings on /etc/dhcpcd.conf
   a. ip_address=<rpi ip>
   b. routers=<router ip>
5. Edit VPN username and password /etc/openvpn/client/userpass.txt
6. Edit network details on /usr/local/lib/lazypivpn/ipnet.sh
7. Reboot RPi
8. Change all device that you want to use VPN to use RPi's IP address for gateway/router and DNS
9. Test if you are indeed connected to VPN and finish


### Current supported vpn provider (case sensitive)
* pia    (private internet access)

More providers can be added if someone write shell code for download, install, configure. Or if I get a free access to VPN.