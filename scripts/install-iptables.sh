#!/usr/bin/env bash
set -ex

sudo apt-get install -y iptables-persistent

sudo sysctl -w net.ipv4.conf.all.route_localnet=1
sudo iptables -t nat -A PREROUTING -p tcp -d 169.254.170.2 --dport 80 -j DNAT --to-destination 127.0.0.1:51679
sudo iptables -t nat -A OUTPUT -d 169.254.170.2 -p tcp -m tcp --dport 80 -j REDIRECT --to-ports 51679

sudo iptables-save | sudo tee /etc/iptables/rules.v4 >/dev/null
