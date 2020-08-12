#! /bin/bash


## Installing Nexus

# Step 1: Update the Linux server.
sudo apt update

# Step 2: Install OpenJDK 1.8
sudo apt install -y openjdk-8-jdk wget

# Step 3: Create a directory named /opt/nexus and cd into the directory.
sudo mkdir /opt/nexus && cd /opt/nexus

# Step 4: Download the latest nexus.
sudo wget http://download.sonatype.com/nexus/3/nexus-3.17.0-01-unix.tar.gz
# Untar the downloaded file.
sudo tar -xvf nexus-3.17.0-01-unix.tar.gz
# Rename the untared file to nexus.
sudo mv nexus-3.17.0-01 nexus

# Step 5: As a good security practice, it is not advised to run nexus service with any sudo user. So create a new user named nexus.
sudo adduser nexus
# Change the ownership of nexus file to nexus user.
sudo chown -R nexus:nexus /opt/nexus
# Open /app/nexus/bin/nexus.rc file, uncomment run_as_user parameter and set it as following.
sudo sed -i "s/run_as_user=''/run_as_user='nexus'/g" /opt/nexus/nexus/bin/nexus


## Running Nexus As A Service

# Step 1: Create a symbolic link for nexus service script to /etc/init.d folder.
sudo ln -s /opt/nexus/nexus/bin/nexus /etc/init.d/nexus

# Step 2: Execute the following commands to add nexus service to boot.
sudo update-rc.d nexus defaults

# Step 3: Manage Nexus Service
sudo service nexus start

# Step 4: Open ufw
sudo ufw allow 80
sudo ufw allow 8081

# Step 5: Preroute Nexus to port 80
sudo iptables -A PREROUTING -t nat -i eth0 -p tcp --dport 80 -j REDIRECT --to-port 8081
PREROUTE="iptables -A PREROUTING -t nat -i eth0 -p tcp --dport 80 -j REDIRECT --to-port 8081"
sed -i "s/exit \$return_code/$PREROUTE\nexit \$return_code/g" /etc/rc2.d/S01nexus
