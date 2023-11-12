#!/bin/bash

IP=$(hostname -I | awk '{print $2}')

echo "START - install registry - "$IP

echo "[1]: install docker"
sudo apt-get update -qq >/dev/null
sudo apt-get install -qq -y git wget curl >/dev/null
sudo curl -fsSL https://get.docker.com | sh; >/dev/null
sudo curl -sL "https://github.com/docker/compose/releases/download/v2.23.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose 


echo "[2]: install registry"
mkdir certs/
openssl req -x509 -newkey rsa:4096 -nodes -keyout certs/myregistry.key -out certs/myregistry.crt -days 365 -subj /CN=myregistry.my
mkdir passwd/
docker run --entrypoint sh registry:2 -c "apk add --no-cache apache2-utils 2>&1 > dev/null; htpasswd -Bbn myuser password" > passwd/htpasswd

mkdir data/
echo "
version: '3.8'
services:
  registry:
    restart: always
    image: registry:2.8.3
    container_name: registry
    ports:
      - 5000:5000
    environment:
      REGISTRY_HTTP_TLS_CERTIFICATE: /certs/myregistry.crt
      REGISTRY_HTTP_TLS_KEY: /certs/myregistry.key
      REGISTRY_AUTH: htpasswd
      REGISTRY_AUTH_HTPASSWD_PATH: /auth/htpasswd
      REGISTRY_AUTH_HTPASSWD_REALM: Registry Realm
    volumes:
      - ./data:/var/lib/registry
      - ./certs:/certs
      - ./passwd:/auth
" > docker-compose-registry.yml

sudo docker-compose -f docker-compose-registry.yml up -d

echo "END - install registry"

