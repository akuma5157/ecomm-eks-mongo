#! /bin/bash

## Installing ElasticStack - ElasticSearch, Logstash and Kibana on Ubuntu 18.04 - noSecurity

# Step 1: import the Elasticsearch public GPG key into APT:
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add

# Step 2: add the Elastic source list to the sources.list.d directory, where APT will look for new sources:
echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-7.x.list

# Step 3: update your package lists so APT will read the new Elastic source:
sudo apt update

# Step 4: Install Elasticsearch, Logstash and Kibana:
sudo apt install elasticsearch kibana  # logstash

# Step 5: Make Elasticsearch accessible from internet
sudo sed -i 's/#network.host: 192.168.0.1/network.host: 0.0.0.0/g' /etc/elasticsearch/elasticsearch.yml
echo "discovery.type: single-node" >> /etc/elasticsearch/elasticsearch.yml

# Step 6: Make Kibana accessible from internet
sudo sed -i 's/#server.host: "localhost"/server.host: 0.0.0.0/g' /etc/kibana/kibana.yml

# Step 7: Configure Logstash
# TODO: Write Configuration script for logstash

## Running Elastic Stack As A Service

# Step 1: start the Elastic Stack service with systemctl:
sudo systemctl start elasticsearch
#sudo systemctl start logstash
sudo systemctl start kibana

# Step 2: enable Elastic Stack to start up every time the server boots:
sudo systemctl enable elasticsearch
#sudo systemctl enable logstash
sudo systemctl enable kibana

# Step 0: Set IpTables rule for kibana
PREROUTE="iptables -A PREROUTING -t nat -i eth0 -p tcp --dport 80 -j REDIRECT --to-port 5601"
$PREROUTE
sed -i "s/^exit \$?/$PREROUTE\nexit \$?/g" /etc/init.d/kibana
sed -i "s/^exit \$?/$PREROUTE\nexit \$?/g" /etc/rc2.d/S01kibana
