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


echo -e """ $darkpurple
#########################################
                                        #
    SCRIPT INSTALLATION GLPI            #
                                        #
    Author : Louis Arnau                #
    Version : 1.0                       #
                                        #
#########################################
$Color_Off
"""


if (( $EUID != 0 )); then

    echo -e "$dardred Please run as root $color_off"
    exit 1

fi

echo -e "$lightblue Mise à jour du système $color_off"
apt update &>/dev/null 2>&1 >>/var/log/glpi_setup.log && apt -y full-upgrade &>/dev/null 2>&1 >>/var/log/glpi_setup.log
echo -e "$lightblue Installation des dépendances $color_off"
#Installation d'apache et des paquets php nécessaires au bon fonctionnement de glpi
apt -y install apache2 libapache2-mod-php php mariadb-server php-{ldap,cli,curl,xmlreader,xmlwriter,intl,bz2,zip,fileinfo,json,xmlrpc,imap,apcu,apcu-bc,xmlrpc,cas,mysqli,mbstring,curl,gd,simplexml,xml,intl,zip,bz2,fpm} &>/dev/null 2>&1 >>/var/log/glpi_setup.log

if [[ -d /var/www/html/glpi ]]; then

    echo -e "$darkred GLPI est déjà installé. $color_off"

else

    echo -e "$lightblue Récupération de l'archive depuis internet $color_off"
    cd /tmp && wget https://github.com/glpi-project/glpi/releases/download/10.0.16/glpi-10.0.16.tgz &>/dev/null 2>&1 >>/var/log/glpi_setup.log
    echo -e "$lightblue extraction de l'archive $color_off"
    cd /tmp && tar xvzf glpi-*.tgz -C /var/www/html &>/dev/null 2>&1 >>/var/log/glpi_setup.log
    echo -e "$darkblue Installation de mariadb-server"
    apt -y install mariadb-server &>/dev/null 2>&1 >>/var/log/glpi_setup.log
    echo -e "$darkblue Sécurisation de Mysql $color_off"
    echo -e "$darkred identifiant root(localhost only) / Securefox34*"
    mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'Securefox34*';
    DELETE FROM mysql.user WHERE user='';
    DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
    DROP DATABASE IF EXISTS test;
    DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
    FLUSH PRIVILEGES;"
    echo -e "$lightblue Création de la base de donnée $color_off"
    mysql -uroot -pSecurefox34* -e "CREATE DATABASE glpi;CREATE USER 'glpiuser'@'localhost' IDENTIFIED BY 'Nd452*^fd';GRANT ALL PRIVILEGES ON glpi.* TO 'glpiuser'@'localhost';"
    echo -e "$darkpurple Configuration des accès pour www-data sur /var/www/html/glpi $color_off"
    chown -R www-data:www-data /var/www/html/glpi
    chmod -R 755 /var/www/html/glpi
    echo -e "$darkblue Ajout d'une configuration dans /etc/apache2/apache2.conf $color_off"
    echo "<Directory /var/www/html/glpi>
        Options Indexes FollowSymLinks
        AllowOverride limit
        Require all granted
        </Directory>
    ServerSignature Off" >> /etc/apache2/apache2.conf
    echo "<VirtualHost *:80>
	# The ServerName directive sets the request scheme, hostname and port that
	# the server uses to identify itself. This is used when creating
	# redirection URLs. In the context of virtual hosts, the ServerName
	# specifies what hostname must appear in the request's Host: header to
	# match this virtual host. For the default virtual host (this file) this
	# value is not decisive as it is used as a last resort host regardless.
	# However, you must set it for any further virtual host explicitly.
	#ServerName www.example.com

	ServerAdmin webmaster@localhost
	DocumentRoot /var/www/html/glpi/

	# Available loglevels: trace8, ..., trace1, debug, info, notice, warn,
	# error, crit, alert, emerg.
	# It is also possible to configure the loglevel for particular
	# modules, e.g.
	#LogLevel info ssl:warn

	ErrorLog ${APACHE_LOG_DIR}/error.log
	CustomLog ${APACHE_LOG_DIR}/access.log combined

	# For most configuration files from conf-available/, which are
	# enabled or disabled at a global level, it is possible to
	# include a line for only one particular virtual host. For example the
	# following line enables the CGI configuration for this host only
	# after it has been globally disabled with "a2disconf".
	#Include conf-available/serve-cgi-bin.conf
</VirtualHost>" > /etc/apache2/sites-enabled/glpi.conf
	/usr/sbin/a2dissite 000-default.conf
    /usr/sbin/a2enmod ldap &>/dev/null
fi

echo -e "$darkgreen Redémarrage du service apache2 / mariadb $color_off"
systemctl restart apache2 mariadb
echo -e "$darkpurple L'installation est log dans /var/log/glpi_setup.log $color_off"
