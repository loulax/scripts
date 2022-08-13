#!/bin/bash

echo """
######################
                     #
    INSTALL OF SPIP  #
                     #
######################                         
"""


echo "[+] Updating system"
apt update &>/dev/null && apt -y full-upgrade &>/dev/null

echo "[!] check if apache is already installed"

if systemctl is-active apache2 = "active" &>/dev/null; then

    echo "[!] Apache2 is active"

else

    echo "[+] Installing Apache2"

    apt -y install apache2 &>/dev/null

fi

echo "[-] Check if php is already installed"

if which php &>/dev/null; then

    echo "[!] PHP is already installed"

else 

    echo "[+] Installing PHP"
    apt -y install unzip php libapache2-mod-php php-{mysql,gd,mbstring,json,ctype,xml,simplexml,dom,zip,ldap,curl,sqlite3,common,cli,common,opcache,readline,pdo,zip,pear,bcmath} &>/dev/null

fi

if systemctl is-active mariadb = "active" &>/dev/null; then

	echo "Maraidb is active"

else

    echo "[+] Installing Mariadb"
    apt -y install mariadb-server &>/dev/null
    echo "Configuration database"
    mysql -e "CREATE DATABASE spipdb;GRANT ALL PRIVILEGES ON spipdb.* TO 'granite'@'localhost' IDENTIFIED BY 'granite';FLUSH PRIVILEGES;"
echo """
#####################################    
    nom de la base: spipdb          #
    utilisateur : granite           #
    mot de passe : granite          #
#####################################
"""
fi

echo "[+] Check if SPIP is ready"

if ls /var/www/html/spip/autoloader.php; then

    echo "SPIP seems to be installed"

else

    echo "Installing SPIP"
    mkdir /var/www/html/spip
    chown -R www-data:www-data /var/www/html
    chmod -R 755 /var/www/html 
    cd /var/www/html/spip   
    wget https://get.spip.net/spip_loader.php

fi

echo "[+] Restarting apache2"
systemctl restart apache2

echo """

SPIP is ready to be installed in browser

"""