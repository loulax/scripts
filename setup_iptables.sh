#!/bin/bash

black='\e[0;30m'
grey='\e[1;30m'
darkred='\e[0;31m'
pink='\e[1;31m'
darkgreen='\e[0;32m'
lightgreen='\e[1;32m'
orange='\e[0;33m'
yellow='\e[1;33m'
darkblue='\e[0;34m'
lightblue='\e[1;34m'
darkpurple='\e[0;35m'
lightpurple='\e[1;35m'
darkcyan='\e[0;36m'
lightcyan='\e[1;36m'
lightgrey='\e[0;37m'
white='\e[1;37m'
color_off='\e[0;m'

function banner(){

echo """
#########################################
#                                       #
#   deployment of iptables firewall     #
#   author : loulax                     #
#   version : 1.0                       #
#                                       #
#########################################

"""

}

function run_as_root(){

    if (( $EUID != 0 )); then

        echo "Please run as root"
        exit 1

    fi

}

function check_firewall_service(){

    if systemctl is-active firewall = "\x3d\x20active" &>/dev/null; then
    
        echo "Le service firewall est déjà actif"
        exit 1

    else

        install_firewall_service

    fi

}

function install_firewall_service(){
    apt -y install iptables
    cat > firewall.service <<EOF
[Unit]
Description=Firewall service
Requires=network-online.target
After=network-online.target

[Service]
User=root
Type=oneshot
RemainAfterExit=yes
ExecStart=/etc/init.d/fw_on.sh start
ExecStop=/etc/init.d/fw_off.sh stop

[Install]
WantedBy=multi-user.target
EOF

read -p "Do yo uwant to start firewall service ? Y/n : " start_firewall

if [[ $start_firewall = "y" ]]; then

    echo "Starting firewall service..."
    systemctl start firewall
fi

read -p "Do you want to automatically start the service at boot ? Y/n : " enable_firewall_at_boot

if [[ $enable_firewall_at_boot == "y" ]]; then

    echo "enable starting at boot"

fi

}

function deployment_rules(){

    cat > fw_on.sh <<EOF

#!/bin/bash

iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X

iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP

iptables -A INPUT -p tcp -m multiport --sports 80,443 -m conntrack --ctstate ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp -m multiport --dports 80,443 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
EOF

read -p "A webserver is running on this machine ? Y/n : " web_server

if [ $web_server = "Y" ] || [ $web_server = "y" ]; then

    read -p "Give the port which is use for : " web_server_port

    cat >> fw_on.sh <<EOF

## TCP/IN => $web_server_port
iptables -A INPUT -p tcp --dport $web_server_port -m conntrack --ctststate NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --sport $web_server_port -m conntrack --ctstate ESTABLISHED -j ACCEPT

EOF
fi

read -p "Allow SSH service ? Y/n : " ssh_server

if [ $ssh_server = "Y" ] || [$ssh_server = "y"]; then

    read -p "Enter the listening port : " ssh_server_port

    cat >> fw_on.sh <<EOF

## TCP/IN => $ssh_server_port
iptables -A INPUT -p tcp --dport $ssh_server_port -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --sport $ssh_server_port -m conntrack --ctstate ESTABLISHED -j ACCEPT

EOF

fi
}

run_as_root
#check_firewall_service
deployment_rules