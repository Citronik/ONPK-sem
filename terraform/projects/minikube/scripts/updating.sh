#!/bin/bash

echo "Starting updating.sh"
if ! grep -q "$(hostname)" /etc/hosts; then
    echo "127.0.0.1 $(hostname)" >> /etc/hosts
fi

if ! grep -q "158.193.152.4" /etc/resolv.conf; then
    echo "nameserver 158.193.152.4
    nameserver 8.8.8.8" >> /etc/resolv.conf
    echo adding DNS
fi

sudo apt-get update
sudo apt-get upgrade -y

sudo apt-get install -y git curl wget

echo "Hostname and /etc/hosts updated: $(hostname)"

#exec > >(tee /var/log/user_data.log) 2>&1

touch /tmp/.cloud-init-finished

echo "updating.sh DONE"