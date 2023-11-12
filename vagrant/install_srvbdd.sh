#!/bin/bash

IP=$(hostname -I | awk '{print $2}')

echo "START - install mysql - "$IP

echo "[1]: install mysql"
sudo apt-get update -qq >/dev/null
sudo apt-get install -qq -y vim git wget curl mysql-server >/dev/null

# Attribution des droits GRANTS à root
sudo mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'root';"

sudo mysql -u root -proot -e "CREATE USER 'vagrant'@'192.168.10.0/24' IDENTIFIED BY 'vagrant';"
sudo mysql -u root -proot -e "CREATE DATABASE dev;"
sudo mysql -u root -proot -e "CREATE DATABASE stage;"
sudo mysql -u root -proot -e "CREATE DATABASE master;"

sudo mysql -u root -proot -e "GRANT ALL PRIVILEGES ON *.* TO 'vagrant'@'192.168.10.0/24';"

sudo sed -i "s/127.0.0.1/0.0.0.0/g" /etc/mysql/mysql.conf.d/mysqld.cnf
        
sudo systemctl restart mysql
sudo systemctl enable mysql

echo "END - install mysql"