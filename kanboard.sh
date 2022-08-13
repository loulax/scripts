#!/bin/bash

echo """
#############################
                            #
    INSTALL OF KANBOARD     #
                            #
#############################                         
"""


echo "[+] Updating installed"
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

    echo "[+] Installation of PHP"
    apt -y install unzip php libapache2-mod-php php php-mysql php-{gd,mbstring,json,ctype,xml,simplexml,dom,zip,ldap,curl,sqlite3} &>/dev/null

fi

echo "[-] Check if mariadb is installed"

if systemctl is-active mariadb = "active" &>/dev/null; then

    echo "[!] Mariadb is active"
    
else

    echo "[+] Installing Mariadb"
    apt -y install mariadb-server &>/dev/null

fi

echo "[-] Check if kanboard is installed"

if ls /var/www/html/kanboard/ &>/dev/null; then

    echo "[!] Kanboard is available. Go to http://<ip>/kanboard"
    exit 1

else 

    echo "[+] Installing kanboard"

    wget https://github.com/kanboard/kanboard/archive/refs/tags/v1.2.22.zip &>/dev/null
    unzip v1.2.22.zip -d /var/www/html/ &>/dev/null
    mv /var/www/html/kanboard-1.2.22/ /var/www/html/kanboard
    chown -R www-data:www-data /var/www/html/kanboard/
    chmod -R 755 /var/www/html/kanboard/
    echo """[+] Creating Kanboard database
#####################################    
    nom de la base: kanboard        #
    utilisateur : granite           #
    mot de passe : granite          #
#####################################
    """
    mysql -e "CREATE DATABASE kanboard; GRANT ALL PRIVILEGES ON kanboard.* TO 'granite'@'localhost' IDENTIFIED BY 'granite'; FLUSH PRIVILEGES;"
    mysql -u root kanboard < /var/www/html/kanboard/app/Schema/Sql/mysql.sql
    sed -i "s/define('DB_DRIVER', 'sqlite')/define('DB_DRIVER', 'mysql')/g" /var/www/html/kanboard/config.default.php
    sed -i "s/define('DB_USERNAME', 'root')/define('DB_DRIVER', 'granite')/g" /var/www/html/kanboard/config.default.php
    sed -i "s/define('DB_DRIVER', '')/define('DB_DRIVER', 'granite')/g" /var/www/html/kanboard/config.default.php
    echo """
#########################################################
    Kanboard is now ready ! ENJOY :)                    #
    Access credential : admin/admin                     #
    url: http://<ip>/kanboard                           #
#########################################################
    """
    exit 0
fi