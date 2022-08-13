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
    SCRIPT INSTALLATION GUACAMOLE       #
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

echo -e "$darkblue Mise à jour du système $color_off"
apt update &>/dev/null && apt -y full-upgrade &>/dev/null 2>&1 >>/var/log/guacamole_setup.log
echo -e "$lightblue Installation des dépendances $color_off"
apt-get -y install make gcc g++ libcairo2-dev libjpeg62-turbo-dev libpng-dev libtool-bin libossp-uuid-dev libavcodec-dev libavformat-dev libavutil-dev libswscale-dev 	freerdp2-dev libpango1.0-dev libssh2-1-dev libtelnet-dev libvncserver-dev libpulse-dev libssl-dev libwebp-dev &>/dev/null 2>&1 >>/var/log/guacamole_setup.log

if [ -d /etc/guacamole ]; then

    echo -e "$darkred Guacamole est déjà installé. $color_off"

else

    echo -e "$darkblue Récupération de l'archive depuis internet $color_off"
    cd /tmp && wget https://downloads.apache.org/guacamole/1.3.0/source/guacamole-server-1.3.0.tar.gz &>/dev/null 2>&1 >>/var/log/guacamole_setup.log
    echo -e "$darkblue Décompression de l'archive"
    tar -xvf guacamole-server-1.3.0.tar.gz &>/dev/null 2>&1 >>/var/log/guacamole_setup.log
    rm guacamole-server-*.tar.gz
    cd guacamole-server-*
    echo -e "$darkblue Configuration dans /etc/init.d"
    ./configure --with-init-dir=/etc/init.d --enable-allow-freerdp-snapshots &>/dev/null 2>&1 >>/var/log/guacamole_setup.log
    make &>/dev/null 2>&1 >>/var/log/guacamole_setup.log && make install &>/dev/null 2>&1 >>/var/log/guacamole_setup.log
    ldconfig &>/dev/null 2>&1 >>/var/log/guacamole_setup.log
    echo -e "$darkblue Activation et démarrage du service guacd $color_off"
    /etc/init.d/guacd start
    echo -e "$darkblue Installation de Tomcat9 $color_off"
    apt -y install tomcat9 tomcat9-admin tomcat9-common tomcat9-user &>/dev/null 2>&1 >>/var/log/guacamole_setup.log
    echo -e "$darkblue Activation et démarrage du service tomcat9 $color_off" 
    systemctl enable tomcat9 2>>/var/log/guacamole_setup.log && systemctl start tomcat9 2>>/var/log/guacamole_setup.log
    echo -e "$darkblue Création du répertoire de configuration de guacamole dans /etc/guacamole $color_off"
    mkdir /etc/guacamole
    echo -e "$darkblue Récupération de l'archive et décompression dans /etc/guacamole $color_off"
    wget https://downloads.apache.org/guacamole/1.3.0/binary/guacamole-1.3.0.war -O /etc/guacamole/guacamole.war &>/dev/null 2>&1 >>/var/log/guacamole_setup.log
    ln -s /etc/guacamole/guacamole.war /var/lib/tomcat9/webapps/ 2>>/var/log/guacamole_setup.log
    echo -e "$darkblue Redémarrage du service tomcat9 et guacd $color_off"
    systemctl restart guacd tomcat9 2>>/var/log/guacamole_setup.log
    echo -e "$darkblue Création des répertoires extensions,lib dans /etc/guacamole"
    mkdir /etc/guacamole/extensions
    mkdir /etc/guacamole/lib
    echo -e "$darkblue Installation de mariadb-server"
    apt -y install mariadb-server &>/dev/null 2>&1 >>/var/log/guacamole_setup.log
    echo -e "$darkblue Sécurisation de Mysql $color_off"
    echo -e "$darkred identifiant root(localhost only) / Securefox34*" 
    mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'Securefox34*';
    DELETE FROM mysql.user WHERE user='';
    DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
    DROP DATABASE IF EXISTS test;
    DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
    FLUSH PRIVILEGES;" 2>>/var/log/guacamole_setup.log
    echo -e "$darkblue Configuration de la base de donnée $color_off"
    echo -e "$darkblue  
    Nom de la base : guacamole_db
    Utilisateur : guacamole_user
    Mot de passe Nd452*^fd
    $color_off
    " 2>>/var/log/guacamole_setup.log
    mysql -uroot -pSecurefox34* -e "CREATE DATABASE guacamole_db;CREATE USER 'guacamole_user'@'localhost' IDENTIFIED BY 'Nd452*^fd'; GRANT SELECT,UPDATE,DELETE,INSERT ON guacamole_db.* TO 'guacamole_user'@'localhost'; FLUSH PRIVILEGES;" 2>>/var/log/guacamole_setup.log
    
    if [ -f /tmp/guacamole-auth-jdbc-*.tar.gz ]; then

        echo -e "$red L'archive existe. $color_off"

    else 
        
        echo -e "$darkblue Téléchargement du module mysql $color_off"
        cd /tmp && wget https://downloads.apache.org/guacamole/1.3.0/binary/guacamole-auth-jdbc-1.3.0.tar.gz &>/dev/null 2>&1 >>/var/log/guacamole_setup.log
        echo -e "$darkblue Décompression de l'archive $color_off"
        tar -xvf guacamole-auth-jdbc-1.3.0.tar.gz &>/dev/null 2>&1 >>/var/log/guacamole_setup.log
        echo -e "$darkblue Installation de l'extension mysql $color_off"
        cp guacamole-auth-jdbc-1.3.0/mysql/guacamole-auth-jdbc-mysql-1.3.0.jar /etc/guacamole/extensions/ 2>&1 >>/var/log/guacamole_setup.log
        echo -e "$darkblue Importation du schéma dans la base $color_off"
        cat guacamole-auth-jdbc-1.3.0/mysql/schema/*.sql | mysql -u root -pSecurefox34* guacamole_db
        echo -e "$darkblue Installation du pilote mysql"

        if [ -f /tmp/mysql-connector-java-*.tar.gz ]; then
        
            echo -e "$red L'archive existe déjà. $color_off"
        
        else 

            cd /tmp/ && wget https://cdn.mysql.com//Downloads/Connector-J/mysql-connector-java-8.0.26.tar.gz &>/dev/null 2>&1 >>/var/log/guacamole_setup.log
            tar xvzf mysql-connector-java-8.0.26.tar.gz &>/dev/null 2>&1 >>/var/log/guacamole_setup.log
            cp /tmp/mysql-connector-java-8.0.26/mysql-connector-java-8.0.26.jar /etc/guacamole/lib/ 2>>/var/log/guacamole_setup.log
    
        fi
        
        echo -e "$darkblue Ajout de la configuration de guacamole ddans /etc/guacamole/guacamole.properties $color_off"
        echo "
        # MySQL properties
        mysql-hostname: localhost
        mysql-port: 3306
        mysql-database: guacamole_db
        mysql-username: guacamole_user
        mysql-password: Nd452*^fd
        " > /etc/guacamole/guacamole.properties 

    fi

fi

echo -e "$darkgreen Redémarrage des services tomcat9 et mariadb $color_off"
systemctl restart mariadb guacd tomcat9 2>&1 >>/var/log/guacamole_setup.log
echo -e "$darkpurple L'installation est log dans /var/log/guacamole_setup.log $color_off"
