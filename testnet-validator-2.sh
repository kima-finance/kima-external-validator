#! /bin/bash
cd kima-testnet-validator
sudo chown $USER:$USER -R private
make scripts-add-funds
make scripts-create-validator
make scripts-add-whitelisted