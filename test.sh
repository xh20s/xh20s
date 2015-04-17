#!/bin/bash
# Interactive PoPToP install script for an OpenVZ VPS
# Tested on Debian 5, 6, and Ubuntu 11.04,12.04
# April 2, 2013 v1.11
# http://www.putdispenserhere.com/pptp-debian-ubuntu-openvz-setup-script/
echo "######################################################"
echo "Interactive PoPToP Install Script for an OpenVZ VPS"
echo
echo "Make sure to contact your provider and have them enable"
echo "IPtables and ppp modules prior to setting up PoPToP."
echo "PPP can also be enabled from SolusVM."
echo
echo "You need to set up the server before creating more users."
echo "A separate user is required per connection or machine."
echo "######################################################"
echo
echo
echo "######################################################"
echo "Select on option:"
echo "1) Set up new PoPToP server AND create one user"
echo "2) Create additional users"
echo "######################################################"
read x
if $x == 1 then
	echo "Enter username that you want to create (eg. client1 or john):"
	#read u
	echo "Specify password that you want the server to use:"
	#read p
	echo "Specify ipaddress that you want the client to use:"
	#read ip
# get the VPS IP
ip=`ifconfig venet0:0 | grep 'inet addr' | awk {'print $2'} | sed s/.*://`

echo
echo "######################################################"
echo "Remove IPtables Rules"
echo "######################################################"
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT

echo
echo "######################################################"
echo "Removing PoPToP"
echo "######################################################"
sudo apt-get remove pptpd -y

echo
echo "######################################################"
echo "Downloading and Installing PoPToP"
echo "######################################################"
apt-get update
apt-get -y install pptpd

echo
echo "######################################################"
echo "Creating Server Config"
echo "######################################################"
cat > /etc/ppp/pptpd-options <<END
name pptpd
refuse-pap
refuse-chap
refuse-mschap
require-mschap-v2
require-mppe-128
ms-dns 8.8.8.8
ms-dns 8.8.4.4
proxyarp
nodefaultroute
lock
nobsdcomp
END

# setting up pptpd.conf
echo "option /etc/ppp/pptpd-options" > /etc/pptpd.conf
echo "logwtmp" >> /etc/pptpd.conf
echo "localip 10.20.1.1" >> /etc/pptpd.conf
echo "remoteip 10.20.1.100-200" >> /etc/pptpd.conf

# adding new user
#echo "$u	*	$p	$ip" >> /etc/ppp/chap-secrets
echo "test	*	test	*" >> /etc/ppp/chap-secrets

echo
echo "######################################################"
echo "Forwarding IPv4 and Enabling it on boot"
echo "######################################################"
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
sysctl -p

echo
echo "######################################################"
echo "Updating IPtables Routing and Enabling it on boot"
echo "######################################################"

iptables -I INPUT -p tcp --dport 1723 -m state --state NEW -j ACCEPT
iptables -I INPUT -p gre -j ACCEPT
iptables -t nat -I POSTROUTING -o venet0-00 -j MASQUERADE
iptables -I FORWARD -p tcp --tcp-flags SYN,RST SYN -s 10.20.1.0/24 -j TCPMSS  --clamp-mss-to-pmtu
# saves iptables routing rules and enables them on-boot
touch /etc/iptables.conf
iptables-save > /etc/iptables.conf
touch /etc/network/if-pre-up.d/iptables
cat > /etc/network/if-pre-up.d/iptables <<END

#!/bin/sh
iptables-restore < /etc/iptables.conf
END
chmod +x /etc/network/if-pre-up.d/iptables
touch /etc/ppp/ip-up
cat >> /etc/ppp/ip-up <<END
ifconfig ppp0 mtu 1400
END

echo
echo "######################################################"
echo "Restarting PoPToP"
echo "######################################################"
sleep 5
/etc/init.d/pptpd restart

echo
echo "######################################################"
echo "Server setup complete!"
echo "Connect to your VPS at $ip with these credentials:"
echo "Username:$u ##### Password: $p"
echo "######################################################"

# runs this if option 2 is selected
elif $x == 2 then
	echo "Enter username that you want to create (eg. client1 or john):"
	read u
	echo "Specify password that you want the server to use:"
	read p
	echo "Specify ipaddress that you want the client to use:"
	read ip

# get the VPS IP
ip=`ifconfig venet0:0 | grep 'inet addr' | awk {'print $2'} | sed s/.*://`

# adding new user
echo "$u	*	$p	$ip" >> /etc/ppp/chap-secrets

echo
echo "######################################################"
echo "Addtional user added!"
echo "Connect to your VPS at $ip with these credentials:"
echo "Username:$u ##### Password: $p #### IP: $ip"
echo "######################################################"

else
echo "Invalid selection, quitting."
exit
fi
