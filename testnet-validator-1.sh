#! /bin/bash
sudo apt update -y
sudo DEBIAN_FRONTEND=noninteractive apt install docker.io -y
sudo DEBIAN_FRONTEND=noninteractive apt install docker-compose -y
sudo DEBIAN_FRONTEND=noninteractive apt install openssh-server -y
echo "$SSH_PRIVATE_KEY" > ~/.ssh/id_rsa

chmod 600 ~/.ssh/id_rsa
ssh-keyscan github.com >> ~/.ssh/known_hosts
git clone git@github.com:kima-finance/kima-testnet-validator.git
sudo apt update -y
sudo DEBIAN_FRONTEND=noninteractive apt-get install make -y
sudo DEBIAN_FRONTEND=noninteractive apt-get install jq -y
cd kima-testnet-validator
nohup make up-reset-kima -d > up-kima.log 2>&1 &
pid=$!
disown $pid
sleep 60
make copy-kimad
kimad status | jq .SyncInfo
