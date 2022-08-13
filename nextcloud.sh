#!/bin/bash
echo """
#################################
                                #
    INSTALLATION OF NEXTCLOUD   #
                                #
#################################                         
"""

echo "[+] Updating installed"
apt update &>/dev/null && apt -y full-upgrade &>/dev/null

if systemctl is-active apache2 = "active" &>/dev/null; then

    echo "[!] Apache2 is running"

else

    echo "[+] Installing Apache2"

    apt -y install apache2 &>/dev/null

fi

echo "[-] Check if php and his dependancies are already installed"

if which php &>/dev/null; then

    echo "[!] PHP is already installed"

else 

    echo "[+] Installation of PHP"
    apt -y install unzip wget php libapache2-mod-php php php-mysql php-{gd,mbstring,json,ctype,xml,simplexml,dom,zip,ldap,curl,sqlite3} &>/dev/null

fi

echo "[-] Check if mariadb is installed"

if systemctl is-active mariadb = "active" &>/dev/null; then

	echo "Maraidb is active"

else

    echo "[+] Installing Mariadb"
    apt -y install mariadb-server &>/dev/null
    echo "Configuration de la base de donnée"
    mysql -e "CREATE DATABASE nextcloud;GRANT ALL PRIVILEGES ON nextcloud.* TO 'granite'@'localhost' IDENTIFIED BY 'granite';FLUSH PRIVILEGES;"
echo """
#####################################    
    nom de la base: nextcloud       #
    utilisateur : granite           #
    mot de passe : granite          #
#####################################
"""
fi

echo "Check if nextcloud installed"

if [ -f /var/www/html/nextcloud ]; then

    echo "Nextcloud seems to be already installed"

else

    echo "Installing nextcloud"
    wget https://download.nextcloud.com/server/releases/latest.zip &>/dev/null
    unzip latest.zip -d /var/www/html &>/dev/null
    rm latest.zip
    chown -R www-data:www-data /var/www/html/nextcloud
    chmod -R 755 /var/www/html/nextcloud
fi

echo """

<?php

\$AUTOCONFIG = [

    'directory' => '/var/www/html/nextcloud/data',
    'dbtype' => 'mysql',
    'dbname' => 'nextcloud',
    'dbuser' => 'granite',
    'dbpassword' => 'granite',
    'dbhost' => 'localhost',
    'dbtableprefix' => '',
    'adminlogin' => 'granite',
    'adminpass' => 'granite',
];

?>""" > /var/www/html/nextcloud/config/autoconfig.php

echo "Restarting apache2"
systemctl restart apache2

echo """
#########################################
    nextcloud is now ready ! ENJOY :)   #
    url: http://<ip>/nextcloud          #
    user: granite                       #
    password: granite                   #
#########################################
"""