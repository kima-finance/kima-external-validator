#! /bin/bash

# Load the .env file
if [ -f .env ]; then
    export $(cat .env | xargs)
else
    echo "Error: .env file not found. Please create a .env file based on the .env.template file and fill in the actual values."
    exit 1
fi

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
# Ensure the SSH directory exists
mkdir -p ~/.ssh

# Ensure permissions are correct on the SSH directory
chmod 700 ~/.ssh

# Copy the private key from the specified path to your .ssh directory (if needed)
if [ -n "$SSH_PRIVATE_KEY_PATH" ]; then
    cp $SSH_PRIVATE_KEY_PATH ~/.ssh/id_rsa
else
    echo "Error: SSH_PRIVATE_KEY_PATH is not set."
    exit 1
fi

# Set the appropriate permissions for the private key file
chmod 600 ~/.ssh/id_rsa

# Add GitHub to known hosts to avoid interactive prompt asking for confirmation
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