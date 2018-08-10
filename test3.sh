#!/bin/bash
# get the VPS IP
ip=`ifconfig eth0 | grep 'inet addr' | awk {'print $2'} | sed s/.*://`

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
sudo yum remove pptpd -y

echo
echo "######################################################"
echo "Downloading and Installing PoPToP"
echo "######################################################"
mknod /dev/ppp c 108 0
yum update
yum -y install ppp pptp pptp-setup pptpd

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
ms-dns 208.67.222.222
ms-dns 208.67.220.220
proxyarp
nodefaultroute
lock
nobsdcomp
END

# setting up pptpd.conf
echo "option /etc/ppp/pptpd-options" > /etc/pptpd.conf
# echo "logwtmp" >> /etc/pptpd.conf # <~~ log
echo "localip 192.168.10.0" >> /etc/pptpd.conf
echo "remoteip 192.168.10.1-235" >> /etc/pptpd.conf

# adding new user
cat > /etc/ppp/chap-secrets <<END
test	*	1234	*
END


echo
echo "######################################################"
echo "Forwarding IPv4 and Enabling it on boot"
echo "######################################################"
echo 1 > /proc/sys/net/ipv4/ip_forward
sysctl -p

echo
echo "######################################################"
echo "Updating IPtables Routing and Enabling it on boot"
echo "######################################################"
iptables -I INPUT -p tcp --dport 1723 -m state --state NEW -j ACCEPT
iptables -P FORWARD ACCEPT
iptables -t nat -A POSTROUTING -j SNAT --to-source $ip
iptables -I FORWARD -p tcp --tcp-flags SYN,RST SYN -s 192.168.10.0/24 -j TCPMSS  --clamp-mss-to-pmtu

# saves iptables routing rules and enables them on-boot
touch /etc/iptables.conf
iptables-save > /etc/iptables.conf
service iptables save
touch /etc/ppp/ip-up
cat >> /etc/ppp/ip-up <<END
ifconfig ppp0 mtu 1400
END

echo
echo "######################################################"
echo "Restarting PoPToP"
echo "######################################################"
sleep 5
/bin/systemctl restart pptpd.service

echo
echo "######################################################"
echo "Server setup complete!"
echo "Connect to your VPS at $ip with these credentials:"
echo "Username:$u ##### Password: $p"
echo "######################################################"
