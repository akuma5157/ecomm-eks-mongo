#!/bin/bash
sleep 10;

# 1 create .kube directory
ssh -i ${key_file} -o StrictHostKeyChecking=no ubuntu@${jenkins_ip} \
    "/bin/mkdir -p ~/.kube" ;

# 2 configure kubeconfig
scp -i ${key_file} -o StrictHostKeyChecking=no \
    ${kubeconfig} ubuntu@${jenkins_ip}:~/.kube/config ;

# 3 configure mariadb ip
ssh -i ${key_file} -o StrictHostKeyChecking=no ubuntu@${jenkins_ip} \
    "sudo touch /etc/profile.d/jenkins.sh ; \
    sudo chown ubuntu:ubuntu /etc/profile.d/jenkins.sh ; \
    sudo chmod +x /etc/profile.d/jenkins.sh ; \
    cat > /etc/profile.d/jenkins.sh <<EOT
#!/bin/bash
export MARIADB_IP=${mariadb_ip}
export KAFKA_IP=${kafka_ip}
export NEXUS_IP=${nexus_ip}
export SONAR_IP=${sonar_ip}
EOT
"

# 4 restart jenkins server
ssh -i ${key_file} -o StrictHostKeyChecking=no ubuntu@${jenkins_ip} \
    "( sleep 5 ; sudo init 6 ) &" ;
