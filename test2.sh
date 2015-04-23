#!/bin/bash
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
mknod /dev/ppp c 108 0
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
UserSpot001	*	PassSpot001	192.168.10.1
UserSpot002	*	PassSpot002	192.168.10.2
UserSpot003	*	PassSpot003	192.168.10.3
UserSpot004	*	PassSpot004	192.168.10.4
UserSpot005	*	PassSpot005	192.168.10.5
UserSpot006	*	PassSpot006	192.168.10.6
UserSpot007	*	PassSpot007	192.168.10.7
UserSpot008	*	PassSpot008	192.168.10.8
UserSpot009	*	PassSpot009	192.168.10.9
UserSpot010	*	PassSpot010	192.168.10.10
UserSpot011	*	PassSpot011	192.168.10.11
UserSpot012	*	PassSpot012	192.168.10.12
UserSpot013	*	PassSpot013	192.168.10.13
UserSpot014	*	PassSpot014	192.168.10.14
UserSpot015	*	PassSpot015	192.168.10.15
UserSpot016	*	PassSpot016	192.168.10.16
UserSpot017	*	PassSpot017	192.168.10.17
UserSpot018	*	PassSpot018	192.168.10.18
UserSpot019	*	PassSpot019	192.168.10.19
UserSpot020	*	PassSpot020	192.168.10.20
UserSpot021	*	PassSpot021	192.168.10.21
UserSpot022	*	PassSpot022	192.168.10.22
UserSpot023	*	PassSpot023	192.168.10.23
UserSpot024	*	PassSpot024	192.168.10.24
UserSpot025	*	PassSpot025	192.168.10.25
UserSpot026	*	PassSpot026	192.168.10.26
UserSpot027	*	PassSpot027	192.168.10.27
UserSpot028	*	PassSpot028	192.168.10.28
UserSpot029	*	PassSpot029	192.168.10.29
UserSpot030	*	PassSpot030	192.168.10.30
UserSpot031	*	PassSpot031	192.168.10.31
UserSpot032	*	PassSpot032	192.168.10.32
UserSpot033	*	PassSpot033	192.168.10.33
UserSpot034	*	PassSpot034	192.168.10.34
UserSpot035	*	PassSpot035	192.168.10.35
UserSpot036	*	PassSpot036	192.168.10.36
UserSpot037	*	PassSpot037	192.168.10.37
UserSpot038	*	PassSpot038	192.168.10.38
UserSpot039	*	PassSpot039	192.168.10.39
UserSpot040	*	PassSpot040	192.168.10.40
UserSpot041	*	PassSpot041	192.168.10.41
UserSpot042	*	PassSpot042	192.168.10.42
UserSpot043	*	PassSpot043	192.168.10.43
UserSpot044	*	PassSpot044	192.168.10.44
UserSpot045	*	PassSpot045	192.168.10.45
UserSpot046	*	PassSpot046	192.168.10.46
UserSpot047	*	PassSpot047	192.168.10.47
UserSpot048	*	PassSpot048	192.168.10.48
UserSpot049	*	PassSpot049	192.168.10.49
UserSpot050	*	PassSpot050	192.168.10.50
UserSpot051	*	PassSpot051	192.168.10.51
UserSpot052	*	PassSpot052	192.168.10.52
UserSpot053	*	PassSpot053	192.168.10.53
UserSpot054	*	PassSpot054	192.168.10.54
UserSpot055	*	PassSpot055	192.168.10.55
UserSpot056	*	PassSpot056	192.168.10.56
UserSpot057	*	PassSpot057	192.168.10.57
UserSpot058	*	PassSpot058	192.168.10.58
UserSpot059	*	PassSpot059	192.168.10.59
UserSpot060	*	PassSpot060	192.168.10.60
UserSpot061	*	PassSpot061	192.168.10.61
UserSpot062	*	PassSpot062	192.168.10.62
UserSpot063	*	PassSpot063	192.168.10.63
UserSpot064	*	PassSpot064	192.168.10.64
UserSpot065	*	PassSpot065	192.168.10.65
UserSpot066	*	PassSpot066	192.168.10.66
UserSpot067	*	PassSpot067	192.168.10.67
UserSpot068	*	PassSpot068	192.168.10.68
UserSpot069	*	PassSpot069	192.168.10.69
UserSpot070	*	PassSpot070	192.168.10.70
UserSpot071	*	PassSpot071	192.168.10.71
UserSpot072	*	PassSpot072	192.168.10.72
UserSpot073	*	PassSpot073	192.168.10.73
UserSpot074	*	PassSpot074	192.168.10.74
UserSpot075	*	PassSpot075	192.168.10.75
UserSpot076	*	PassSpot076	192.168.10.76
UserSpot077	*	PassSpot077	192.168.10.77
UserSpot078	*	PassSpot078	192.168.10.78
UserSpot079	*	PassSpot079	192.168.10.79
UserSpot080	*	PassSpot080	192.168.10.80
UserSpot081	*	PassSpot081	192.168.10.81
UserSpot082	*	PassSpot082	192.168.10.82
UserSpot083	*	PassSpot083	192.168.10.83
UserSpot084	*	PassSpot084	192.168.10.84
UserSpot085	*	PassSpot085	192.168.10.85
UserSpot086	*	PassSpot086	192.168.10.86
UserSpot087	*	PassSpot087	192.168.10.87
UserSpot088	*	PassSpot088	192.168.10.88
UserSpot089	*	PassSpot089	192.168.10.89
UserSpot090	*	PassSpot090	192.168.10.90
UserSpot091	*	PassSpot091	192.168.10.91
UserSpot092	*	PassSpot092	192.168.10.92
UserSpot093	*	PassSpot093	192.168.10.93
UserSpot094	*	PassSpot094	192.168.10.94
UserSpot095	*	PassSpot095	192.168.10.95
UserSpot096	*	PassSpot096	192.168.10.96
UserSpot097	*	PassSpot097	192.168.10.97
UserSpot098	*	PassSpot098	192.168.10.98
UserSpot099	*	PassSpot099	192.168.10.99
UserSpot100	*	PassSpot100	192.168.10.100
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
