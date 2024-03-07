#!/bin/bash

# This script sets up a validator node for Kima testnet validator.
# It assumes that you're in the correct directory and have the necessary permissions.

# First, ensure we're in the right directory
echo "Navigating to the kima-testnet-validator directory..."
cd kima-testnet-validator

# Change ownership of the 'private' directory to the current user, to avoid permission issues
echo "Updating ownership of the 'private' directory..."
sudo chown $USER:$USER -R private
if [ $? -eq 0 ]; then
    echo "Ownership updated successfully."
else
    echo "Failed to update ownership of the 'private' directory."
    exit 1
fi

# Add funds to the validator
echo "Adding funds to the validator..."
if make scripts-add-funds; then
    echo "Funds added successfully."
else
    echo "Failed to add funds to the validator."
    exit 1
fi

# Create the validator
echo "Creating the validator..."
if make scripts-create-validator; then
    echo "Validator created successfully."
else
    echo "Failed to create the validator."
    exit 1
fi

# Add validator to the whitelist
echo "Adding the validator to the whitelist..."
if make scripts-add-whitelisted; then
    echo "Validator added to whitelist successfully."
else
    echo "Failed to add the validator to the whitelist."
    exit 1
fi

echo "Validator setup completed successfully."
