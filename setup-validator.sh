#! /bin/bash

# Check if a key-name was provided as an argument
if [ -z "$1" ]; then
    echo "Usage: $0 KEY_NAME"
    echo "KEY_NAME is the name of the validator node."
    exit 1
fi

KEY_NAME="$1"  # Assign the first command-line argument to KEY_NAME

# Ensure that 'curl' is installed on your system
if ! command -v curl &> /dev/null; then
    echo "curl could not be found. Please install curl to continue."
    exit 1
fi

# Automatically fetch the external IP address of this machine using api.ipify.org
EXTERNAL_IP=$(curl -s https://api.ipify.org)
echo "My IP address is: $EXTERNAL_IP"

# Validate that we actually got something that looks like an IP address
if [[ ! $EXTERNAL_IP =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Error obtaining external IP address."
    exit 1
fi

echo "Updating system packages..."
if sudo apt update -y && sudo DEBIAN_FRONTEND=noninteractive apt install docker.io docker-compose openssh-server make jq -y; then
    echo "System packages updated successfully."
else
    echo "Failed to update system packages."
    exit 1
fi

echo "Setting up SSH..."
echo "$SSH_PRIVATE_KEY" > ~/.ssh/id_rsa

chmod 600 ~/.ssh/id_rsa
ssh-keyscan github.com >> ~/.ssh/known_hosts

echo "Cloning kima-testnet-validator repository..."
if git clone git@github.com:kima-finance/kima-testnet-validator.git; then
    echo "Repository cloned successfully."
else
    echo "Failed to clone repository."
    exit 1
fi

echo "Updating configuration..."
# Replace 'your_value' with "$KEY_NAME" to use the passed-in or environment variable value
./update-config.sh --key-name "$KEY_NAME" --external-ip "$EXTERNAL_IP"
# Check if configuration update was successful
if [ $? -eq 0 ]; then
    echo "Configuration updated successfully."
else
    echo "Failed to update configuration."
    exit 1
fi

# Navigate to the cloned repository directory
cd kima-testnet-validator
echo "Setting up the KIMA validator..."
if nohup make up-reset-kima -d > up-kima.log 2>&1 & then
    pid=$!
    disown $pid
    sleep 60  # Waiting for the process to initialize properly.
    echo "KIMA validator setup initiated."
else
    echo "Failed to initiate KIMA validator setup."
    exit 1
fi

echo "Copying kimad..."
if make copy-kimad; then
    echo "kimad copied successfully."
else
    echo "Failed to copy kimad."
    exit 1
fi

echo "Checking KIMA daemon status..."
if kimad status | jq .SyncInfo; then
    echo "KIMA daemon status checked successfully."
else
    echo "Failed to check KIMA daemon status."
    exit 1
fi

echo "All processes completed successfully."