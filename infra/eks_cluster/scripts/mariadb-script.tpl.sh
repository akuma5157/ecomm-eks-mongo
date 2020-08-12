#!/bin/bash

#Add MariaDB repository
sudo apt-get install software-properties-common
sudo apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8
sudo add-apt-repository "deb [arch=amd64,arm64,ppc64el] http://mariadb.mirror.liquidtelecom.com/repo/10.4/ubuntu $(lsb_release -cs) main"

#System Update
sudo apt-get update
sudo apt-get upgrade -y

#Install MariaDB-server
sudo apt -y install mariadb-server-10.4 mariadb-client-10.4

# Un-bind Server to localhost
sudo sed -i 's/bind-address/#bind-address/g' /etc/mysql/my.cnf

# Setup logging
sed -i 's/#general_log/general_log/g' /etc/mysql/my.cnf
sed -i 's/#log-queries/log-queries/g' /etc/mysql/my.cnf
sed -i 's/#slow_query_log\[={0|1}\]/slow_query_log = 1/g' /etc/mysql/my.cnf

sed -i 's/long_query_time = 10/long_query_time = 2/g' /etc/mysql/my.cnf
cat >> /etc/mysql/conf.d/mysqld_safe_syslog.cnf <<EOF
[mariadb]
log_error               =/var/log/mysql/mariadb-error.log
plugin_load_add         = sql_errlog
sql_error_log_filename  = /var/log/mysql/mariadb-error.log
EOF

#Start MariaDB-service
sudo systemctl enable mariadb
sudo systemctl start mariadb

#Open Firewall
sudo ufw allow 3306/tcp
uu
# grant permissions to remote user
mysql -uroot -proot -e "grant all privileges on *.* to 'root'@'%' identified by 'root';"
mysql -uroot -proot -e "create user beats@localhost identified by 'beats';"
mysql -uroot -proot -e "create database collectionDB1;"
mysql -uroot -proot -e "create database collectionDB2;"
mysql -uroot -proot -e "create database collectionDB3;"
mysql -uroot -proot -e "create database collectionDB4;"
mysql -uroot -proot -e "create database collectionDB5;"

# Install Metricbeat
curl -L -O https://artifacts.elastic.co/downloads/beats/metricbeat/metricbeat-7.2.0-amd64.deb
sudo dpkg -i metricbeat-7.2.0-amd64.deb

# Configure Metricbeat
sed -i "s/localhost:9200/${elasticsearch_ip}:9200/g" /etc/metricbeat/metricbeat.yml
sed -i "s/#host: \"localhost:5601/host: \"${elasticsearch_ip}:5601/g" /etc/metricbeat/metricbeat.yml
mv /etc/metricbeat/modules.d/mysql.yml.disabled /etc/metricbeat/modules.d/mysql.yml
metricbeat setup dashboards
sed -i 's/#metricsets:/metricsets:/g' /etc/metricbeat/modules.d/mysql.yml
sed -i 's/#  - status/    - status/g' /etc/metricbeat/modules.d/mysql.yml
sed -i 's/secret/beats/g' /etc/metricbeat/modules.d/mysql.yml
sed -i 's/root/beats/g' /etc/metricbeat/modules.d/mysql.yml

# start metricbeat service
systemctl enable metricbeat
systemctl start metricbeat


# install filebeat
curl -L -O https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-7.2.0-amd64.deb
sudo dpkg -i filebeat-7.2.0-amd64.deb

# Configure filebeat
sed -i "s/localhost:9200/${elasticsearch_ip}:9200/g" /etc/filebeat/filebeat.yml
sed -i "s/ enabled: false/ enabled: true/g" /etc/filebeat/filebeat.yml
sed -i "s/#host: \"localhost:5601/host: \"${elasticsearch_ip}:5601/g" /etc/filebeat/filebeat.yml
filebeat modules enable mysql
sed -i "s/#var.paths:/var.paths: [\"\/var\/log\/mysql\/mariadb-error.log*\"]/" /etc/filebeat/modules.d/mysql.yml
sed -i "s/#var.paths:/var.paths: [\"\/var\/log\/mysql\/mariadb-slow.log*\"]/" /etc/filebeat/modules.d/mysql.yml
cat >> /tmp/HereFile <<EOF
    - /var/log/mysql/mariadb-error.log*
  processors:
    - add_fields:
        target: ''
        fields:
          event.module: mysql
          fileset.name : error
    - add_fields:
        when:
          contains:
            message: 'Warning'
        target: ''
        fields:
          log.level: 'WARN'
    - add_fields:
        when:
          contains:
            message: 'ERROR'
        target: ''
        fields:
          log.level: 'ERROR'
EOF

sed -i '/- \/var\/log\/*.log/ {
   r /tmp/HereFile
   d
   }' /etc/filebeat/filebeat.yml
rm /tmp/HereFile

filebeat setup dashboards

# start filebeat service
systemctl enable filebeat
systemctl restart filebeat

init 6
