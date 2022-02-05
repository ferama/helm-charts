#!/bin/bash

SERVER_PORT="${SERVER_PORT:-51820}"
echo "Server port: $SERVER_PORT"
INTERNAL_SUBNET="${INTERNAL_SUBNET:-10.13.16.0}"
echo "Internal subnet: $INTERNAL_SUBNET"
# vpn routed ips / net
ALLOWED_IPS="${ALLOWED_IPS:-172.21.0.0/16}"
echo "Allowed Ips: $ALLOWED_IPS"

SERVER_URL="1.1.1.1"
DNS=$(cat /etc/resolv.conf  | grep nameserver | awk '{print $2}')

nextip() {
    IP=$1
    IP_HEX=$(printf '%.2X%.2X%.2X%.2X\n' `echo $IP | sed -e 's/\./ /g'`)
    NEXT_IP_HEX=$(printf %.8X `echo $(( 0x$IP_HEX + 1 ))`)
    NEXT_IP=$(printf '%d.%d.%d.%d\n' `echo $NEXT_IP_HEX | sed -r 's/(..)/0x\1 /g'`)
    echo "$NEXT_IP"
}

init_config() {
    # initialize if not exists
    if [ ! -e /etc/wireguard/wg*.conf ]
    then 
        echo "$(date): wireguard init config - /etc/wireguard/wg0.conf"
        wg genkey | tee /etc/wireguard/wg0.key | wg pubkey > /etc/wireguard/wg0.pub
        SERVER_KEY=`cat /etc/wireguard/wg0.key`
        SERVER_ADDRESS=$(nextip $INTERNAL_SUBNET)
        cat > /etc/wireguard/wg0.conf << EOF
[Interface]
Address = $SERVER_ADDRESS/24
ListenPort = $SERVER_PORT
PrivateKey = $SERVER_KEY
PostUp = iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE; iptables -A FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --set-mss 1400; iptables -t mangle -A POSTROUTING -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --set-mss 1400
PostDown = iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE; iptables -D FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --set-mss 1400; iptables -t mangle -D POSTROUTING -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --set-mss 1400
EOF
        chmod go-rw /etc/wireguard/wg0.key /etc/wireguard/wg0.conf
    fi

    # create clients dir if not exists
    [ -d /etc/wireguard/peers ] || mkdir -p /etc/wireguard/peers
    nextpeerip=$(nextip $SERVER_ADDRESS)
    echo $nextpeerip > /etc/wireguard/nextpeerip
}

wg_up() {
    for conf in /etc/wireguard/wg*.conf
	do
        echo "$(date): wireguard up interface - $conf"
        wg-quick up $conf
    done
	
	for NAME in /etc/wireguard/clients/*.pub
	do
		PUB=`cat $NAME`
		CONF=${NAME/pub/conf}
		IP=`awk '/Address/{print $3}' $CONF|awk -F\/ '{print $1}'`
		wg set wg0 peer $PUB allowed-ips $IP
	done

    echo "$(date): setup NAT"
    iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
}

wg_down() {
    for conf in /etc/wireguard/wg*.conf
	do
        echo "$(date): wireguard down interface - $conf"
        wg-quick down $conf
    done
}

add_peer() {
    NAME=$1
    if [ ! -e "/etc/wireguard/clients/$NAME.pub" ]
    then
        wg genkey | tee /etc/wireguard/clients/$NAME.key | wg pubkey > /etc/wireguard/clients/$NAME.pub
        SERVER_PUB=`cat /etc/wireguard/wg0.pub`
	    CLIENT_KEY=`cat /etc/wireguard/clients/$NAME.key`
    fi

    peer_ip=`cat /etc/wireguard/nextpeerip`
    nextpeerip=$(nextip $peer_ip)
    echo $nextpeerip > /etc/wireguard/nextpeerip
    # create config
	cat > /etc/wireguard/clients/$NAME.conf << EOF
[Interface]
PrivateKey = $CLIENT_KEY
Address = $peer_ip/24
DNS = $DNS

[Peer]
PublicKey = $SERVER_PUB
AllowedIPs = $ALLOWED_IPS
Endpoint = $SERVER_URL:$SERVER_PORT
EOF
	chmod go-rw /etc/wireguard/clients/$NAME.key /etc/wireguard/clients/$NAME.conf
}

# Handle shutdown behavior
finish () {
    echo "$(date): stopping wireguard"
    wg_down
    if [ $NAT -eq 1 ]; then
        iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
    fi

    exit 0
}



# init_config
# wg_up
# trap finish TERM INT QUIT