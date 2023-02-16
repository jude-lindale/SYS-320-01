#!/bin/bash

# Story: Extract IPs from emergingthreats.net and create a firewall ruleset

#function to create the badIPs file
badIPs() {
#download the file 
wget https://rules.emergingthreats.net/blockrules/emerging-drop.suricata.rules -O /tmp/emerging-drop.suricata.rules

#pull IP addresses out of the file and make a list of the IPs to block
egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.0/[0-9]{1,2}' /tmp/emerging-drop.suricata.rules | sort -u | tee badIPs.txt
}

#check if the badips file exists
i="badIPs.txt"
if test -f "$i"; then
 #if yes ask if it should be redownloaded
	read -p "This file already exists. Do you want to overwrite it? y/N" choice

	case "${choice}" in
		Y|y) 
		echo  "redownloading badIPs.txt"
		badIPs
		;;
		N|n) echo "Not redownloading badIPs.txt"
		;;
		*) 
			echo "Invalid value."
			exit 1
		;;
	esac
else 
#if it doesnt exist download file
	badIPs
fi

#functions for the various inbound drop rules

#windows 
windows() {
egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.0' badIPs.txt | tee badips.windowsform
	for eachip in $(cat badips.windowsform)
	do
		echo 'netsh advfirewall firewall add rule name=\"BLOCK IP ADDRESS - ${eachip}\" dir=in action=block remoteip=${eachip}' | tee -a badips.netsh
	done
	rm badips.windowsform
	clear
	echo 'file output:"badips.netsh" - IP Table for windows firewall drop rules'
}

#cisco
cisco() {
egrep -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.0' badIPs.txt | tee badips.nocidr
for eachIP in $(cat badips.nocidr)
do
	echo "deny ip host ${eachIP}" | tee -a badips.cisco 
done
rm badips.nocidr
clear
echo 'file output:"badips.cisco" - IP Table for cisco firewall drop rules'
}

#mac
mac() {
echo '
scrub-anchor "com.apple/*"
nat-anchor "com.apple/*"
rdr-anchor "com.apple/*"
dummynet-anchor "com.apple/*"
anchor "com.apple/*"
load anchor "com.apple" from "/etc/pf.anchors/com.apple"
' | tee pf.conf

for eachIP in $(cat badIPs.txt)
do
	echo "block in from ${eachIP}" | tee -a pf.conf 
done
clear
echo 'file output:"pf.conf" - IP table for mac firewall drop rules'
}

#iptables
iptables() {
for eachIP in $(cat badIPs.txt)
do
	echo "iptables -A INPUT -s $(eachIP) -j DROP" | tee -a badIPs.iptables #iptable
done
clear
	echo 'file output: \"badips.iptables\" - Created IPTables firewall drop rules'
}

#parse the cisco file
parse() {
wget https://raw.githubusercontent.com/botherder/targetedthreats/master/targetedthreats.csv -O /tmp/targetedthreats.csv
	awk '/domain/ {print}' /tmp/targetedthreats.csv | awk -F \" '{print $4}' | sort -u > threats.txt
	echo 'class-map match-any BAD_URLS' | tee ciscothreats.txt
	for eachip in $(cat threats.txt)
	do
		echo 'match http host \"${eachip}\"' | tee -a ciscothreats.txt
	done
	rm threats.txt
	echo 'file output:"ciscothreats.txt" - Cisco URL filters file parsed'
}

#various inbound drop rule switches
while getopts 'cdmfi' OPTION ; do
	case "${OPTION}" in
		c) cisco
		;;
		d) parse
		;;
		m) mac
		;;
		w) windows
		;;
		i) iptables
		;;
		*)
			echo "Invalid Value"
			exit 1
		;;
	esac
done
