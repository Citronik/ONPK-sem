#!/bin/bash

# This script is used to forward ports from the jump host to the minikube cluster.
echo "Forwarding ports from the jump host to the minikube cluster..."
echo "To be done ... /not implemented yet/"
# Delete iptables
iptables -F && apt remove iptables iptables-persistent -y
apt autoremove -y
apt install nftables -y
systemctl enable nftables
systemctl start nftables
touch /etc/nftables.conf
echo <<EOF > /etc/nftables.conf
#!/usr/sbin/nft -f
flush ruleset

table inet filter {
        limit lim_400ppm { rate 400/minute ; comment "use to limit incoming icmp" ; }
        limit lim_1kbps  { rate over 1024 bytes/second burst 512 bytes ; comment "use to limit incoming smtp" ; }
        chain input {
                type filter hook input priority 0;
                tcp dport {ssh, 80, 443, 30000-32767} accept
                ct state {established, related} accept
                ct state invalid drop
				meta l4proto icmp limit name "lim_400ppm" accept
                tcp dport 25 limit name "lim_1kbps" accept
				#counter drop
        }
        chain forward {
                type filter hook forward priority 0;
                tcp dport {ssh, 80, 443, 30000-32767} accept
                ct state {established, related} accept
                ct state invalid drop
                meta l4proto icmp limit name "lim_400ppm" accept
                tcp dport 25 limit name "lim_1kbps" accept
                #counter drop
        }
        chain output {
                ct state {established, related} accept
                ct state invalid drop
        }
}

table inet nat {
        chain prerouting {
                type nat hook prerouting priority 0;
                #DEVICES
                tcp dport 80 dnat to :80
				tcp dport 8022 dnat to :8022
                tcp dport {30000-32767} dnat to :{30000-32767}
        }
        chain postrouting {
                type nat hook postrouting priority 0;
                oifname "ens3" masquerade
        }
}
EOF

systemctl start nftables