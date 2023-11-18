#!/bin/bash

IP=$(hostname -I | awk '{print $2}')

echo "START - install jenkins - "$IP

echo "[1]: install jenkins"

sudo apt-get update -qq >/dev/null
sudo apt-get install -qq -y git sshpass wget ansible gnupg2 curl >/dev/null
sudo wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo apt-key add -
sudo sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt-get update -qq >/dev/null
sudo apt-get install -qq -y default-jre jenkins >/dev/null
sudo systemctl enable jenkins
sudo systemctl restart jenkins

echo "[2]: config ansible"

touch /etc/ansible/ansible.cfg
echo "
[defaults]
allow_world_readable_tmpfiles=True

[ssh_connection]
pipelining = True
" >/etc/ansible/ansible.cfg

# sed -i 's/.*pipelining.*/pipelining = True/' /etc/ansible/ansible.cfg
# sed -i 's/.*allow_world_readable_tmpfiles.*/allow_world_readable_tmpfiles = True/' /etc/ansible/ansible.cfg

echo "[3]: install docker - "

sudo curl -fsSL https://get.docker.com | sh; >/dev/null
sudo usermod -aG docker jenkins
sudo curl -sL "https://github.com/docker/compose/releases/download/v2.23.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose 

echo "[4]: use registry without ssl"

echo '
{
  "insecure-registries" : ["192.168.10.5:5000"]
}
' >/etc/docker/daemon.json

sudo systemctl daemon-reload
sudo systemctl restart docker
sudo newgrp docker

echo "END - install jenkins"
