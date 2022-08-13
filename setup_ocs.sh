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


echo -e """ $Purple 
#########################################
                                        #
    SCRIPT INSTALLATION OCS INVENTORY   #
                                        #
    Author : Louis Arnau                #
    Enterprise : Cyberzen               #
    Version : 1.0                       #
                                        #
#########################################
$Color_Off
"""


if (( $EUID != 0 )); then   

    echo -e "$dardred Please run as root $color_off"
    exit 1

fi

echo -e "$darkcyan Mise à jour du système $color_off"
apt update && apt -y full-upgrade
echo -e "$darkblue Installation de LAMP $color_off"
apt -y install apache2 libapache2-mod-php mariadb-server mariadb-client libxml-simple-perl libdbi-perl libdbd-mysql-perl libapache-dbi-perl libnet-ip-perl libsoap-lite-perl libarchive-zip-perl make build-essential libdbd-mysql-perl libnet-ip-perl libxml-simple-perl php php-{pclzip,mbstring,soap,mysql,curl,xml,zip,gd} nmap
echo -e "$darkcyan Installation des modules perl $color_off"
cpan -f -i install XML::Simple Compress DBI DBD::Mysql Apache::DBI Net::IP SOAP::Lite Mojolicious::Lite Plack::Handler Archive::Zip YAML XML::Entities Switch Compress::Zlib Net::IP LWP::UserAgent Digest::MD5 Net::SSLeay Data::UUID Mac::SysProfile IO::Socket::SSL Crypt::SSLeay LWP::Protocol::https Proc::Daemon Proc::PID::File Net::SNMP Net::Netmask
Nmap::Parser Module::Install Net::CUPS Parse::EDID

if [[ -d /var/lib/ocsinventory-reports ]]; then

    echo -e "$darkred OCS semble déjà installé. $color_off"

else

    echo -e "$darkred identifiant root(localhost only) / Securefox34*" 

        mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'Securefox34*';
        DELETE FROM mysql.user WHERE user='';
        DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
        DROP DATABASE IF EXISTS test;
        DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
        FLUSH PRIVILEGES;"
    echo -e "$lightblue Création de la base de donnée $color_off"
    mysql -uroot -pSecurefox34* -e "CREATE DATABASE ocsweb;CREATE USER 'ocsuser'@'localhost' IDENTIFIED BY 'Nd452*^fd';GRANT ALL PRIVILEGES ON glpi.* TO 'glpiuser'@'localhost';"
    echo -e "$darkblue Téléchargement d'ocs depuis internet $color_off"
    cd /tmp 
    wget https://github.com/OCSInventory-NG/OCSInventory-ocsreports/releases/download/2.9.2/OCSNG_UNIX_SERVER-2.9.2.tar.gz
    echo -e "$lightblue Extraction de l'archive $color_off"
    tar zxvf OCSNG_UNIX_SERVER-2.9.2.tar.gz
    echo -e "$darkblue Exécution du script d'installation $color_off"
    rm OCSNG_UNIX_SERVER-*.tar.gz
    cd OCSNG_UNIX_SERVER-*
    sh setup.sh
    echo -e "$lightblue Paramétrage des permissions pour le répertoire /var/lib/ocsinventory-reports $color_off"
    chown -R www-data:www-data /var/lib/ocsinventory-reports
    chmod -R 755 www-data:www-data /var/lib/ocsinventory-reports
    echo -e "$darkblue Configuration d'apache2 $color_off"
    sed -i "s/php_value post_max_size 100m/php_value post_max_size 9999m/g"
    sed -i "s/upload_value upload_max_filesize 101m/upload_value upload_max_filesize 8888m/g"
    sed -i "s/OCS_DB_USER ocs/OCS_DB_USER ocsuser/g"
    sed -i "s/OCS_DB_PWD ocs/OCS_DB_PWD Nd452*^fd/g"
    sed -i "s/userocs/Nd452*^fd/g"
    echo -e "$lightblue Activation des configuration d'ocs $color_off"
    a2enconf ocsinventory-reports
    a2enconf z-ocsinventory-server
    a2enconf zz-ocsinventory-restapi
    a2enmod perl
    echo -e "$lightgreen OCS Inventory est installé. Adresse web http://<ip>/ocsreports $color_off"
    
fi

echo -e "$darkgreen Redémarrage des services apache2 mariadb $color_off"
systemctl restart apache2
systemctl restart mariadb
systemctl enable mariadb
systemctl enable apache2