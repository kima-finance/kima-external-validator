#!/bin/bash

# Function to update a configuration parameter in a given file
update_config() {
    local file="$1"
    local path="$2"
    local value="$3"
    jq "$path = \"$value\"" "$file" > temp.json && mv temp.json "$file"
}

# Paths to the JSON configuration files
CONFIG_FILE_ONE="./kima-testnet-validator/base_image/node_config.json"
CONFIG_FILE_TWO="./kima-testnet-validator/node/config_json_tools/config_template.json"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
        --key-name)
            KEY_NAME="$2"
            shift # past argument
            shift # past value
            ;;
        --external-ip) # Option for external IP
            EXTERNAL_IP="$2"
            shift # past argument
            shift # past value
            ;;
        *)    # unknown option
            echo "Unknown option $1"
            exit 1
            ;;
    esac
done

# Check for necessary parameters
if [[ -z "$KEY_NAME" ]] || [[ -z "$EXTERNAL_IP" ]]; then
    echo "Missing required arguments."
    echo "Usage: $0 --key-name <KEY_NAME> --external-ip <EXTERNAL_IP>"
    exit 1
fi

# Update the configuration files with the provided values
update_config "$CONFIG_FILE_ONE" '.key_name' "$KEY_NAME"
update_config "$CONFIG_FILE_ONE" '.external_ip' "$EXTERNAL_IP"
update_config "$CONFIG_FILE_TWO" '.kimachain.signer_name' "$KEY_NAME"
update_config "$CONFIG_FILE_TWO" '.tss_ecdsa.external_ip' "$EXTERNAL_IP"
update_config "$CONFIG_FILE_TWO" '.tss_eddsa.external_ip' "$EXTERNAL_IP"

echo "Configurations updated successfully."
