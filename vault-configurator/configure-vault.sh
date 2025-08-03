#!/bin/sh
set -e

# This script runs inside the vault-configurator container.
# It waits for the main vault-server to be healthy and then configures it.

echo "--- [Configurator] Waiting for Vault server to be ready ---"

# Retry loop to wait for Vault to be fully available
# We poll the health endpoint using the service name 'vault-server'.
until curl --output /dev/null --silent --head --fail http://vault-server:8200/v1/sys/health; do
    printf '.'
    sleep 2
done
echo
echo "--- [Configurator] Vault is up and running! ---"

# Set environment variables for the vault CLI commands
export VAULT_TOKEN="root"
export VAULT_ADDR="http://vault-server:8200"

echo "--- [Configurator] Applying initial Vault configuration ---"

echo "[Configurator] Enabling userpass auth..."
vault auth enable userpass

echo "[Configurator] Creating mission-app-policy..."
vault policy write mission-app-policy - <<EOF
path "secret/data/mission/api-key" {
  capabilities = ["read"]
}
EOF

echo "[Configurator] Creating user 'insider'..."
vault write auth/userpass/users/insider \
    password='password123' \
    policies='mission-app-policy'

echo "[Configurator] Enabling KV v2 secrets engine..."
vault secrets enable -path=secret kv-v2

echo "[Configurator] Writing secret mission data..."
vault kv put secret/mission/api-key classified-key="C9A3-B7E1-A4D6-8B3F"

echo "--- [Configurator] Vault Configuration Complete. Exiting. ---"
