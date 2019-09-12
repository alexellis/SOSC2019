#!/bin/bash

sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add  -

sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

sudo apt-get update

sudo groupadd docker
sudo usermod -aG docker vagrant 

sudo apt-get install -y --allow-unauthenticated docker-ce docker-ce-cli containerd.io

mkdir /home/vagrant/minio_data
docker run -d -v /home/vagrant/minio_data:/data --net host -e "MINIO_ACCESS_KEY=admin" -e "MINIO_SECRET_KEY=adminminio"  minio/minio server /data

wget https://dl.min.io/client/mc/release/linux-amd64/mc
mv mc /usr/bin/mc
sudo chmod +x /usr/bin/mc

wget https://gist.githubusercontent.com/dciangot/088a02b58bd7255a28752253e66a203e/raw/99ed7afeed49956790fedcd76c3af4379c024fdf/config_mc.json

mkdir /home/vagrant/.mc/
cp config_mc.json /home/vagrant/.mc/config.json
chown -R vagrant:vagrant  /home/vagrant/.mc/

wget  https://gist.githubusercontent.com/dciangot/b895329574cd308bed06684b745ce238/raw/295e2e5189e582249d7c5af27823585df5bbbc43/config_minio.json

