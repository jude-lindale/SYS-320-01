#!/bin/bash

# Storyline: script to create wireguard server

#create a private key
privatekey="$(wg genkey)"

#create public key
publickey="$(echo {$privatekey} | wg pubkey)"

#set the addresses
address="10.254.132.0/24,172.16.28.0/24"

#set listen port
listenport="4282"

peerinfo="# ${address} 198.199.97.163:4282 ${publickey} 8.8.8.8,1.1.1.1 1280 120 0.0.0.0/0"

echo "${peeeinfo}
[Interface]
Address = ${address}
#PostUp = /etc/wireguard/wg-up.bash
#PostDown = /etc/wireguard/wg-down.bash
#wg addconf wg0 <(wg-quick strip wg0)
ListenPort = ${listenport}
PrivateKey = ${privatekey}
" > wg0.conf
