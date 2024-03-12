#!/bin/bash

# Path to the JSON configuration file
CONFIG_FILE="./kima-testnet-validator/base_image/node_config.json"

# Function to update a configuration parameter
update_config() {
    local path="$1"
    local value="$2"
    jq "$path = \"$value\"" $CONFIG_FILE > temp.json && mv temp.json $CONFIG_FILE
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
        --key-name)
            KEY_NAME="$2"
            shift # past argument
            shift # past value
            ;;
        --keyring-backend)
            KEYRING_BACKEND="$2"
            shift # past argument
            shift # past value
            ;;
        --chain-id)
            CHAIN_ID="$2"
            shift # past argument
            shift # past value
            ;;
        --genesis-node-ip)
            GENESIS_NODE_IP="$2"
            shift # past argument
            shift # past value
            ;;
        --tss-ip)
            TSS_IP="$2"
            shift # past argument
            shift # past value
            ;;
        --rest-node-ips)
            REST_NODE_IPS="$2"
            shift # past argument
            shift # past value
            ;;
        --amount)
            AMOUNT="$2"
            shift # past argument
            shift # past value
            ;;
        --external-ip) # New option for external IP
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

# Update the configuration file with the provided values
[[ ! -z "$KEY_NAME" ]] && update_config '.key_name' "$KEY_NAME"
[[ ! -z "$KEYRING_BACKEND" ]] && update_config '.keyring_backend' "$KEYRING_BACKEND"
[[ ! -z "$CHAIN_ID" ]] && update_config '.chain_id' "$CHAIN_ID"
[[ ! -z "$GENESIS_NODE_IP" ]] && update_config '.genesis_node_ip' "$GENESIS_NODE_IP"
[[ ! -z "$TSS_IP" ]] && update_config '.tss_ip' "$TSS_IP"
[[ ! -z "$REST_NODE_IPS" ]] && update_config '.rest_node_ips' "$REST_NODE_IPS"
[[ ! -z "$AMOUNT" ]] && update_config '.validator_config.amount' "$AMOUNT"
[[ ! -z "$EXTERNAL_IP" ]] && update_config '.external_ip' "$EXTERNAL_IP" # Update the external IP

echo "Configuration updated successfully."
