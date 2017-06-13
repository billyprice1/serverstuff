#!/bin/sh
apt-get update ;
apt-get -y upgrade ;
apt-get -y install wget ;
wget -qO- https://get.docker.com/ | sh
export OVPN_DATA=ovpn-data ;
docker pull kylemanna/openvpn ;
docker volume create --name $OVPN_DATA ;
docker run -v $OVPN_DATA:/etc/openvpn --rm kylemanna/openvpn ovpn_genconfig -u udp://$(curl ifconfig.co) ;

# manual from here on, you need a password
docker run -v $OVPN_DATA:/etc/openvpn --rm -it kylemanna/openvpn ovpn_initpki
docker run -v $OVPN_DATA:/etc/openvpn -d -p 1194:1194/udp --name openvpn --cap-add=NET_ADMIN kylemanna/openvpn
docker run -v $OVPN_DATA:/etc/openvpn --rm -it kylemanna/openvpn easyrsa build-client-full a_client nopass
docker run -v $OVPN_DATA:/etc/openvpn --rm kylemanna/openvpn ovpn_getclient a_client > vpnconfig.ovpn
