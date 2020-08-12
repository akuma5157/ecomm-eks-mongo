#!/bin/bash

#setting environment variables for kafka main IP and broker id
sudo /bin/su -c "echo 'export NEXUS_IP="${nexus_ip}"' >> /etc/profile"
sudo /bin/su -c "echo 'export ECRURL="https://${ecr_url}"' >> /etc/profile"
sudo /bin/su -c "echo 'export AWS_DEFAULT_REGION="${aws_region}"' >> /etc/profile"
sudo /bin/su -c "echo 'export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64' >> /etc/profile"
sudo /bin/su -c "echo 'export KUBECONFIG=/home/ubuntu/.kube/config' >> /etc/profile"

# kubectl setup
mkdir /home/ubuntu/.kube
chown ubuntu:ubuntu -R /home/ubuntu/.kube
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
curl -o aws-iam-authenticator https://amazon-eks.s3-us-west-2.amazonaws.com/1.13.7/2019-06-11/bin/linux/amd64/aws-iam-authenticator
chmod +x ./aws-iam-authenticator
sudo mv ./aws-iam-authenticator /usr/local/bin/aws-iam-authenticator

#Reload the profile
source /etc/profile

# Install Java, Maven, Jenkins, AWS-CLI, Docker
wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
sudo apt update
sudo apt install -y openjdk-8-jdk
sudo apt install -y maven awscli docker-ce
sleep 20
sudo apt install -y jenkins
sudo ufw allow 8080
usermod -a -G docker jenkins

#Start Jenkins Service
sudo systemctl enable jenkins
sudo systemctl start jenkins

# sudo ufw allow 80
sudo iptables -I INPUT 1 -p tcp --dport 8080 -j ACCEPT
sudo iptables -I INPUT 1 -p tcp --dport 80 -j ACCEPT
sudo iptables -A PREROUTING -t nat -i eth0 -p tcp --dport 80 -j REDIRECT --to-port 8080
PREROUTE="iptables -A PREROUTING -t nat -i eth0 -p tcp --dport 80 -j REDIRECT --to-port 8080"
sed -i "s/exit 0/$PREROUTE\nexit 0/g" /etc/rc2.d/S01jenkins
sed -i "s/exit 0/$PREROUTE\nexit 0/g" /etc/init.d/jenkins
sudo systemctl daemon-reload


# download jenkins cli
sleep 20
wget http://localhost:8080/jnlpJars/jenkins-cli.jar
sleep 5

# create admin user
echo 'jenkins.model.Jenkins.instance.securityRealm.createAccount("admin", "${admin_passwd}")' | \
    java -jar ./jenkins-cli.jar  -s http://localhost:8080 \
    -auth admin:$(cat /var/lib/jenkins/secrets/initialAdminPassword) -noKeyAuth groovy = \–

# install jenkins plugins
java -jar jenkins-cli.jar -s http://localhost:8080/ -auth admin:${admin_passwd} \
    install-plugin docker-plugin nexus-jenkins-plugin amazon-ecr kubernetes nexus-artifact-uploader
sleep 30

# restart jenkins
sudo systemctl restart jenkins
