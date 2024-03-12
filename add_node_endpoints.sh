#!/bin/bash
# Load environment variables from .env file at the root
set -a # automatically export all variables
source .env
set +a

# Define your config template path
configFile="./kima-testnet-validator/node/config_json_tools/config_template.json"

# Function to update configuration with environment variables
updateConfigWithEnv() {
  local configFile=$1

  # Read existing configuration
  local config=$(cat "$configFile")

  # Modify chain specific settings with environment variables using jq
  local updatedChains=$(echo $config | jq '.chains' | jq -c '.[]' | while read -r chain; do
    chain_id=$(echo $chain | jq -r '.chain_id' | tr '[:lower:]' '[:upper:]')
    pool_env="${chain_id}_POOL_ADDRESS"
    rpc_host_env="${chain_id}_RPC_HOST"
    wss_host_env="${chain_id}_WSS_HOST"

    # Check if contract field exists and update only if it does
    if echo $chain | jq '. | has("contract")' | grep -q true; then
      contract_env="${chain_id}_CONTRACT_ADDRESS"
      updated_chain=$(echo $chain | jq ".contract = \"${!contract_env:-$(echo $chain | jq -r '.contract')}\"")
    else
      updated_chain=$chain
    fi

    updated_chain=$(echo $updated_chain | jq ".pool = \"${!pool_env:-$(echo $updated_chain | jq -r '.pool')}\"")
    updated_chain=$(echo $updated_chain | jq ".block_scanner.rpc_host = \"${!rpc_host_env:-$(echo $updated_chain | jq -r '.block_scanner.rpc_host')}\"")
    updated_chain=$(echo $updated_chain | jq ".block_scanner.wss_host = \"${!wss_host_env:-$(echo $updated_chain | jq -r '.block_scanner.wss_host')}\"")
    echo $updated_chain
  done | jq -s '.')

  # Update the original config with the updated chains
  updatedConfig=$(echo $config | jq ".chains = $updatedChains")

  # Write back the updated config to the same file
  echo $updatedConfig | jq '.' > "$configFile"
  echo "Updated configuration at: $configFile"
}

# Update the configuration
updateConfigWithEnv "$configFile"
