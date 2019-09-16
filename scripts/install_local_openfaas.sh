#!/bin/bash

sudo sed -i 's/127.0.0.1 localhost/127.0.0.1 localhost '"$HOSTNAME"'/' /etc/hosts 

curl -sfL https://get.k3s.io | sh -

# If you want to use docker instead of containerd
# curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--docker" sh -


sudo kubectl apply -f https://raw.githubusercontent.com/openfaas/faas-netes/master/namespaces.yml

PASSWORD=$(head -c 12 /dev/urandom | shasum| cut -d' ' -f1)

sudo kubectl -n openfaas create secret generic basic-auth \
--from-literal=basic-auth-user=admin \
--from-literal=basic-auth-password="$PASSWORD"

echo $PASSWORD > gateway-password.txt

git clone https://github.com/openfaas/faas-netes
cd faas-netes && \
sudo kubectl apply -f ./yaml

curl -sL cli.openfaas.com | sudo sh
