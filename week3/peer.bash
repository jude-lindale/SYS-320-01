#!/bin/bash

# Storyline: Create peer VPN configuration fiel

# What is the peer's name
echo -n "What is the peer's name?"
read clientanem

# Filename variable
peerfile="${clientname}-wg0.conf"

# Check if the peer file exists
if [[ -f "${peerfile}" ]]
then
	# Prompt if we need to overwrite the file
	echo "The file ${peerfile} exists."
	echo -n "Do you want to overwrite it? (y/n)"
	read to_overwrite

	if [[ "${to_overwrite}" == "n" || "${to_overwrite}" == "" || "${to_overwrite}" == "N" ]]
	then
		echo "Exit..."
		exit 0
	elif [[ "${to_overwrite}" == "y" || "${to_overwrite}" == "Y" ]]
	then
		echo "Creating the wireguard configuration file..."
	else
		echo "Invalid value"
		exit 1
	fi
fi

# Generate a private key
privatekey="$(wg genkey)"

# Generate a public key
clientpublickey="$(echo ${privatekey} | wg pubkey)"

# Generate a preshared key
preshared="$(wg genpsk)"

# Endpoint
endpoint="$(head -1 wg0.conf | awk ' { pring $3 } ')"

# Server public key
publickey="$(head -1 wg0.conf | awk ' { print $4 } ')"

# DNS servers
dns="$(head -1 wg0.conf | awk ' { pring $5 } ')"

# MTU
mtu="$(head -1 wg0.conf | awk ' { print $6 } ')"

# KeepAlive
keep="$(head -1 wg0.conf | awk ' { print $7 } ')"

# ListenPort
lport="$(shuf -n1 -i 40000-50000)"

# Default routes for VPN
routes="$(head -1 wg0.conf | awk ' { print $8 } ')"

# Create the client config file

echo "[Interface]
Address = 10.254.132.100/24
DNS = ${dns}
ListenPort = ${listenport}
MTU = ${mtu}
PrivateKey = ${privatekey}

[Peer]
AllowedIPs = ${routes}
PersistentKeepalive = ${keepalive}
PresharedKey = ${preshared}
PublicKey = ${clientpublickey}
Endpoint = ${endpoint}
" > "${peerfile}"

# Add peer config to server config

echo "
# ${clientname} begin
[Peer]
PublicKey = ${clientpublickey}
PresharedKey = ${preshared}
AllowedIPs = 10.254.132.100/32
# ${clientname} end" >> wg0.conf 

#echo "
#sudo cp wg0.conf /etc/wireguard
#sudo wg addcong wg0 <(wg-quick strip wg0)
#"
