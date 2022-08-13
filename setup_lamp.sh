#!/bin/bash

apt update && apt -y full-upgrade
apt -y install apache2 libapache2-mod-php php php-mysql mariadb-server mariadb-client php-{gd,mbstring,json,ctype,xml,simplexml,dom,zip,ldap,curl,sqlite3,mysql} snapd
echo "ServerSignature Off" >> /etc/apache2/apache2.conf
snap install code --classic
