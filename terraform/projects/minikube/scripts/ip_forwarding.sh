#!/bin/bash

echo "Starting ip_forwarding.sh"
echo "net.ipv6.conf.all.disable_ipv6=1
net.ipv6.conf.default.disable_ipv6=1
net.ipv6.conf.lo.disable_ipv6=1
net.ipv4.ip_forward=1
net.ipv6.conf.all.forwarding=1" >> /etc/sysctl.conf

sysctl -p

echo "ip_forwarding.sh DONE"