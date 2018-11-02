if [ -z "$OVC" ] || [ -z "$OV" ]; then
	echo "Path $OVC and/or $OV not provided, please start from fix-ovpn.sh"
	exit 51
fi

cd $OVC
rm -fr ca.rsa.4096.crt crl.rsa.4096.pem client.conf pia
if [ ! -f openvpn-strong.zip ] || [ $1 == "-f" ]; then
    wget "https://www.privateinternetaccess.com/openvpn/openvpn-strong.zip"
fi
unzip -d pia openvpn-strong.zip
cd pia

# Delete all trailing blank lines at end of file (only).
for file in *.ovpn; do
	# remove empty lines at end
	sed -i -e :a -e '/^\n*$/{$d;N;};/\n$/ba' "$file"
	# replace with correct file path
	sed -i 's,auth-user-pass,auth-user-pass '"$OVC"'/userpass.txt,' "$file"
	sed -i 's,crl-verify crl,crl-verify '"$OVC"'/crl,' "$file"
	sed -i 's,ca ca,ca '"$OVC"'/ca,' "$file"

	echo -n "keepalive 30 120
auth-nocache
script-security 2
up $OV/update-resolv-conf
down $OV/update-resolv-conf
" >> "$file"
done

cd $OVC
# pick hong kong as default, change this for favourite location
ln -s pia/Hong\ Kong.ovpn client.conf
ln -s pia/ca.rsa.4096.crt .
ln -s pia/crl.rsa.4096.pem .

# set vpn dns bypass for provider
sed -i -E "s/(export vpn_dns_regex=).+/\1\"(aus-melbourne|aus|brazil|ca|ca-toronto|denmark|fi|france|germany|hk|in|ireland|israel|italy|japan|mexico|nl|nz|no|ro|sg|kr|sweden|swiss|turkey|uk-london|uk-southampton|us-california|us-chicago|us-east|us-florida|us-midwest|us-newyorkcity|us-seattle|us-siliconvalley|us-texas|us-west)\\\.privateinternetaccess\\\.com\"/" /usr/local/lib/lazypivpn/ipnet.sh

exit 0
