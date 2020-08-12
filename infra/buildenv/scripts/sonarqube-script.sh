#!/bin/bash

#System Update
sudo apt-get update

#Install MariaDB-server
sudo apt -y install mysql-server-5.7 mysql-client-5.7

#Install openjdk
sudo apt -y install openjdk-11-jdk

#Install Nginx-Server
sudo apt -y install nginx


# Un-bind Server to localhost
sudo sed -i 's/bind-address/#bind-address/g' /etc/mysql/my.cnf

#Start MariaDB-service
sudo systemctl enable mysql
sudo systemctl start mysql

#Open Firewall
sudo ufw allow 3306/tcp

# grant permissions to remote user
mysql -uroot -proot -e "grant all privileges on *.* to 'root'@'%' identified by 'root';"

#setup mysql
sudo mysql -uroot -proot<<_EOF_
    CREATE DATABASE sonarqube;

    CREATE USER sonarqube@'localhost' IDENTIFIED BY 'sonarqube';

    GRANT ALL ON sonarqube.* to sonarqube@'localhost';

    FLUSH PRIVILEGES;
_EOF_



#create the sonarqube user:
sudo adduser --system --no-create-home --group --disabled-login sonarqube

#create the directory to install SonarQube into:
sudo mkdir /opt/sonarqube

#install the unzip utility
sudo apt-get install unzip

# SonarQube installation directory:
mkdir /opt/sonarqube
cd /opt/sonarqube

#download the file:
sudo wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-7.5.zip --no-check-certificate

#Unzip the file:
sudo unzip sonarqube-7.5.zip

#Once the files extract, delete the downloaded zip file, as you no longer need it:
sudo rm sonarqube-7.5.zip

#Finally, update the permissions so that the sonarqube user will own these files, and be able to read and write files in this directory:
sudo chown -R sonarqube:sonarqube /opt/sonarqube

#Configuring the SonarQube Server
cat >> /opt/sonarqube/sonarqube-7.5/conf/sonar.properties << _EOF_
sonar.jdbc.username=sonarqube
sonar.jdbc.password=sonarqube
sonar.jdbc.url=jdbc:mysql://localhost:3306/sonarqube?useUnicode=true&characterEncoding=utf8&rewriteBatchedStatements=true&useConfigs=maxPerformance&useSSL=false
sonar.web.javaAdditionalOpts=-server
sonar.web.host=127.0.0.1
_EOF_

#Create the service file
cat >> /etc/systemd/system/sonarqube.service << _EOF_
[Unit]
Description=SonarQube service
After=syslog.target network.target

[Service]
Type=forking

ExecStart=/opt/sonarqube/sonarqube-7.5/bin/linux-x86-64/sonar.sh start
ExecStop=/opt/sonarqube/sonarqube-7.5/bin/linux-x86-64/sonar.sh stop

User=sonarqube
Group=sonarqube
Restart=always

[Install]
WantedBy=multi-user.target
_EOF_

# start and configure the SonarQube service to start automatically on boot:
sudo systemctl start sonarqube
sudo systemctl enable sonarqube

#  Configuring the Reverse Proxy

cat >> /etc/nginx/sites-enabled/sonarqube << _EOF_
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://127.0.0.1:9000;
    }
}
_EOF_

mv /etc/nginx/sites-enabled/default /root/nginx-default

# start and configure the nginx service to start automatically on boot:
sudo service nginx restart
sudo systemctl enable nginx
