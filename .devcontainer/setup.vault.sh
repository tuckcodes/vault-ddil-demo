#!/bin/bash
# .devcontainer/setup-vault.sh
# This script configures the running Vault instance inside the Codespace.

echo "--- Starting Vault Configuration ---"

# Set environment variables for the script
export VAULT_ADDR='http://127.0.0.1:8200'
export VAULT_TOKEN='root'
CONTAINER_NAME='vault-server' # The name of the vault service in docker-compose

# Wait for Vault to be ready
echo "Waiting for Vault to start..."
until $(curl --output /dev/null --silent --head --fail $VAULT_ADDR/v1/sys/health); do
    printf '.'
    sleep 1
done
echo "Vault is up and running!"


# 1. Enable userpass authentication
echo "Enabling userpass auth..."
docker exec $CONTAINER_NAME vault auth enable userpass

# 2. Create the policy for the mission application
echo "Creating mission-app-policy..."
docker exec $CONTAINER_NAME vault policy write mission-app-policy - <<EOF
path "secret/data/mission/api-key" {
  capabilities = ["read"]
}
EOF

# 3. Create a user 'insider' with the mission-app-policy
echo "Creating user 'insider'..."
docker exec $CONTAINER_NAME vault write auth/userpass/users/insider \
    password='password123' \
    policies='mission-app-policy'

# 4. Enable the KV v2 secrets engine at 'secret/'
echo "Enabling KV v2 secrets engine..."
docker exec $CONTAINER_NAME vault secrets enable -path=secret kv-v2

# 5. Write the secret API key for the demo
echo "Writing secret mission data..."
docker exec $CONTAINER_NAME vault kv put secret/mission/api-key classified-key="C9A3-B7E1-A4D6-8B3F"

echo "--- Vault Configuration Complete ---"
