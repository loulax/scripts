#!/bin/bash

RED='\033[0;31m'
ORANGE='\033[0;33m'
GREEN='\033[0;32m'
NC='\033[0m'

function isRoot() {
	if [ "${EUID}" -ne 0 ]; then
		echo "You need to run this script as root"
		exit 1
	fi
}

function setup() {

    token="openssl rand -base64 60"

    apt update && apt -y full-upgrade
    apt -y install nginx bind9 iptables

    if ls setup_docker.sh; then
    
        chmod +x setup_docker.sh && ./setup_docker.sh
        docker pull vaultwarden/server:latest
        docker run -d --name vault -e ADMIN_TOKEN=$token --restart unless-stopped -v ~/vault-data:/data -p 8080:80 vaultwarden/server:latest
        docker start vault

        if ls db.sqlite3; then

            docker cp db.sqlite3 vault:/data
            docker stop vault
            docker start vault

        fi
    
    else

        echo -e "${RED} L'installation ne peux pas être faite sans docker.";
        exit 1;
    fi

    echo "server {
        listen 443 ssl http2 ;
        server_name bw.loulax.fr;

        http2_push_preload on;

        ssl_certificate /root/loulax.fr/fullchain.cer;
        ssl_certificate_key /root/loulax.fr/loulax.fr.key;

        add_header Strict-Transport-Security "max-age=31536000";

        location / {
            proxy_set_header X-Forwarded-Host $host:$server_port;
            proxy_set_header X-Forwarded-Server $host;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_pass_request_headers on;
            proxy_pass http://localhost:8080;
        }
    }" >> /etc/nginx/loulax.fr  

    systemctl restart nginx

echo "#!/bin/bash

#RESET FIREWALL
iptables -F
iptables -t nat -F
iptables -X
iptables -t nat -X

#DEFINE DEFAULT POLICY
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP

#DEFINE NEW CHAINS
iptables -N DOCKER
iptables -N DOCKER-ISOLATION-STAGE-1
iptables -N DOCKER-ISOLATION-STAGE-2
iptables -N DOCKER-USER
iptables -t nat -N DOCKER
iptables -N fw_in
iptables -N fw_out
iptables -N fw_fw
iptables -t nat -N pre_route
iptables -t nat -N post_route
iptables -A INPUT -j fw_in
iptables -A OUTPUT -j fw_out
iptables -A FORWARD -j fw_fw
iptables -A POSTROUTING -t nat -j post_route
iptables -A PREROUTING -t nat -j pre_route

#ALLOW LOOPBACK
iptables -A fw_fin -i lo -j ACCEPT
iptables -A fw_out -o lo -j ACCEPT

#ALLOW SSH
iptables -A fw_in -i ens33 -p tcp --dport 1432 -m conntack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A fw_out -o ens33 -p tcp --sport 1432 -m conntrack --ctstate ESTABLISHED -j ACCEPT

#NGINX
iptables -A fw_in -p tcp -m multiport --dports 80,443 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A fw_out -p tcp -m multiport --sports 80,443 -m conntrack --ctstate ESTABLISHED -j ACCEPT

#SMTP (Pour l'envoi de mail aux clients vaultwarden)
iptables -A fw_in -p tcp --sport 587 -m conntrack --ctstate ESTABLISHED -j ACCEPT
iptables -A fw_out -p tcp --dport 587 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT

#DOCKER
iptables -A fw_fw -j DOCKER-USER
iptables -A fw_fw -j DOCKER-ISOLATION-STAGE-1
iptables -A fw_fw -o docker0 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
iptables -A fw_fw -i docker0 ! -o docker0 -j ACCEPT
iptables -A fw_fw -i docker0 -o docker0 -j ACCEPT
iptables -A DOCKER -d 172.17.0.2/32 ! -i docker0 -o docker0 -p tcp --dport 80 -j ACCEPT
iptables -A DOCKER-ISOLATION-STAGE-1 -i docker0 ! -o docker0 -j DOCKER-ISOLATION-STAGE-2
iptables -A DOCKER-ISOLATION-STAGE-1 -j RETURN
iptables -A DOCKER-ISOLATION-STAGE-2 -o docker0 -j DROP
iptables -A DOCKER-ISOLATION-STAGE-2 -j RETURN
iptables -A DOCKER-USER -j RETURN

iptables -t nat -A pre_route -d <public ip> -p tcp --dport 3012 -j DNAT --to-destination 172.17.0.2:3012
iptables -t nat -A pre_route -m addrtype --dst-type LOCAL -j DOCKER
iptables -t nat -A OUTPUT ! -d 127.0.0.0/8 -m addrtype --dst-type LOCAL -j DOCKER
iptables -t nat -A post_route -s 172.17.0.0/16 ! -o docker0 -j MASQUERADE
#iptables -t nat -A POSTROUING -s 172.17.0.2/32 -d 172.17.0.2/32 -p tcp --dport 80 -j MASQUERADE
iptables -t nat -A DOCKER -i docker0 -j RETURN
iptables -t nat -A DOCKER ! -i docker0 -p tcp --dport 8080 -j DNAT --to-destination 172.17.0.2:80
" > /etc/init.d/fw_on.sh


echo "#!/bin/bash
iptables -F
iptables -X
iptables -Z
iptables -t nat -F
iptables -t nat -X
iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT" > /etc/init.d/fw_off.sh


chmod +x /etc/init.d/fw_*.sh

echo "[Unit]
Description=IPtables firewall
Requires=network-online.target
After=network-online.target

[Service]
ExecStart=/etc/init.d/iptables.sh
ExecStop=/etc/init.d/restore.sh
User=root
Type=oneshot
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
Alias=fw.service" > /lib/systemd/system/firewall.service

systemctl daemon-reload
systemctl start firewall
}