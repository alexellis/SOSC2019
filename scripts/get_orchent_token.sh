#!/usr/bin/env bash

IAM_CLIENT_ID=dodas-demo
IAM_CLIENT_SECRET=dodas-demo

IAM_CLIENT_ID=${IAM_CLIENT_ID:-iam-client}
IAM_CLIENT_SECRET=${IAM_CLIENT_SECRET}

echo -ne "IAM User:"
read IAM_USER

echo -ne "Password:"
stty -echo
read IAM_PASSWORD
stty echo

echo

res=$(curl -s -L \
  -d client_id=${IAM_CLIENT_ID} \
  -d client_secret=${IAM_CLIENT_SECRET} \
  -d grant_type=password \
  -d username=${IAM_USER} \
  -d password=${IAM_PASSWORD} \
  -d scope="openid profile email offline_access" \
  ${IAM_ENDPOINT:-https://dodas-iam.cloud.cnaf.infn.it/token} > .token &&
  python -c "import json; print(json.load(open('.token'))[\"access_token\"]);"
)


if [ $? != 0 ]; then
  echo "Error!"
  exit 1
fi

echo -e "Orchent access token has to be set with the following: \n export ORCHENT_TOKEN=$res"
