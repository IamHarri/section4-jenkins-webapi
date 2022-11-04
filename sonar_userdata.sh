#!/bin/bash
sudo apt-get update
sudo apt-get install openjdk-11-jdk -y
#install sonarqube
wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-8.9.7.52159.zip
sudo apt install unzip
sudo sysctl -w vm.max_map_count=262144
sudo unzip sonarqube-8.9.7.52159.zip
sudo mv sonarqube-8.9.7.52159 /opt/sonarqube
sudo groupadd sonar
sudo useradd -d /opt/sonarqube -g sonar sonar
sudo chown sonar:sonar /opt/sonarqube -R
sudo touch /etc/systemd/system/sonar.service
sudo chmod 775 /etc/systemd/system/sonar.service
sudo chmod 775 /opt/sonarqube/conf/sonar.properties
sudo chmod 775 /etc/sysctl.conf
sudo cat >> /etc/sysctl.conf <<EOF
vm.max_map_count=262144
EOF
sudo sysctl -p
sudo cat >> /etc/systemd/system/sonar.service <<EOF
[Unit]
Description=SonarQube service
After=syslog.target network.target

[Service]
Type=forking

ExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh start
ExecStop=/opt/sonarqube/bin/linux-x86-64/sonar.sh stop

User=sonar
Group=sonar
Restart=always

LimitNOFILE=65536
LimitNPROC=4096

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl start sonar
sudo systemctl enable sonar