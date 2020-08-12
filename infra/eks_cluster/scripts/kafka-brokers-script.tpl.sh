#!/bin/bash

#System Update
sudo apt-get update
sudo apt-get upgrade -y

# Add Kafka user
useradd kafka -m

#Installing Java
sudo apt install openjdk-8-jdk -y

#Inserting text into the file profile
sudo /bin/su -c "echo 'export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-amd64' >> /etc/profile"
sudo /bin/su -c "echo 'export JRE_HOME=/usr/lib/jvm/jre' >> /etc/profile"

#setting environment variables for kafka main IP and broker id
sudo /bin/su -c "echo 'export ZOOKEEPER_MAIN_IP="${zookeeper_ip}"' >> /etc/profile"
sudo /bin/su -c "echo 'export KAFKA_BROKER_ID="${broker_id}"' >> /etc/profile"

#Reload the profile
source /etc/profile

#Installing wget
sudo apt install wget -y
sleep 20

# cd to /home/kafka
cd /home/kafka

#Downloading kafka
wget https://www-us.apache.org/dist/kafka/2.2.0/kafka_2.12-2.2.0.tgz -O kafka.tgz


#Uzip kafka
tar -xzvf kafka.tgz --strip 1

#Enable topic deletion
echo -e "\ndelete.topic.enable = true" >> /home/kafka/config/server.properties
#Modify the configuration of your kafka server
sed -i 's/export KAFKA_HEAP_OPTS="-Xmx1G -Xms1G"/export KAFKA_HEAP_OPTS="-Xmx256M -Xms128M"/g' bin/kafka-server-start.sh
sed -i 's/broker.id=0/broker.id='$KAFKA_BROKER_ID'/g' config/server.properties
sed -i "s/#listeners=PLAINTEXT:\/\/:9092/listeners=PLAINTEXT:\/\/$(curl 169.254.169.254\/latest\/meta-data\/local-ipv4):9092/g" config/server.properties
sed -i 's/zookeeper.connect=localhost:2181/zookeeper.connect='$ZOOKEEPER_MAIN_IP':2181/g' config/server.properties

#Change ownership to kafka user
chown kafka:kafka /home/kafka -R

# Creating Systemd Unit Files and Starting the Kafka Server

cat > /etc/systemd/system/kafka.service <<'_END'
    [Unit]
    Requires=network.target remote-fs.target
    After=network.target remote-fs.target

    [Service]
    Type=simple
    User=kafka
    ExecStart=/bin/sh -c '/home/kafka/bin/kafka-server-start.sh /home/kafka/config/server.properties > /home/kafka/kafka.log 2>&1'
    ExecStop=/home/kafka/bin/kafka-server-stop.sh
    Restart=on-abnormal

    [Install]
    WantedBy=multi-user.target
_END

#Start the kafka server
sudo systemctl start kafka

cd /home/ubuntu

# Install Metricbeat
curl -L -O https://artifacts.elastic.co/downloads/beats/metricbeat/metricbeat-7.2.0-amd64.deb
sudo dpkg -i metricbeat-7.2.0-amd64.deb

# Configure Metricbeat
sed -i "s/localhost:9200/${elasticsearch_ip}:9200/g" /etc/metricbeat/metricbeat.yml
mv /etc/metricbeat/modules.d/kafka.yml.disabled /etc/metricbeat/modules.d/kafka.yml
sed -i 's/#metricsets:/metricsets:/g' /etc/metricbeat/modules.d/kafka.yml
sed -i 's/#  - partition/    - partition/g' /etc/metricbeat/modules.d/kafka.yml
sed -i 's/#  - consumergroup/    - consumergroup/g' /etc/metricbeat/modules.d/kafka.yml

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
mv /etc/filebeat/modules.d/kafka.yml.disabled /etc/filebeat/modules.d/kafka.yml
filebeat setup dashboards

# start filebeat service
systemctl enable filebeat
systemctl start filebeat
