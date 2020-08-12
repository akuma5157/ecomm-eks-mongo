#!/bin/bash

#apt Update
sudo apt-get update
sudo apt-get install software-properties-common
sudo apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8
sudo add-apt-repository "deb [arch=amd64,arm64,ppc64el] http://mariadb.mirror.liquidtelecom.com/repo/10.4/ubuntu $(lsb_release -cs) main"

#Installing Java
sudo apt install openjdk-8-jdk mariadb-client-10.4 -y

#Inserting text into the file profile
sudo /bin/su -c "echo 'export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-amd64' >> /etc/profile"
sudo /bin/su -c "echo 'export JRE_HOME=/usr/lib/jvm/jre' >> /etc/profile"

#Reload the profile
source /etc/profile
