#!/bin/bash

curl -sfL https://get.k3s.io | sh -

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

export OPENFAAS_URL=http://127.0.0.1:31112

echo -n $PASSWORD | faas-cli login --password-stdin