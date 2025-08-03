#!/bin/bash
# .devcontainer/setup-vault.sh
# This script configures the running Vault instance inside the Codespace.

echo "--- Starting Vault Configuration ---"

# Define the path to the docker-compose file for clarity
COMPOSE_FILE="./.devcontainer/docker-compose.yml"

# Wait for Vault to be ready by checking its health endpoint
echo "Waiting for Vault to start..."
until curl --output /dev/null --silent --head --fail http://127.0.0.1:8200/v1/sys/health; do
    printf '.'
    sleep 1
done
echo "Vault is up and running!"


# Use 'docker-compose exec' for more robust command execution.
# The -T flag disables pseudo-tty allocation, which is required for non-interactive scripts.
# The 'vault' command is run inside the 'vault-server' service container.

# 1. Enable userpass authentication
echo "Enabling userpass auth..."
docker-compose -f $COMPOSE_FILE exec -T vault-server vault auth enable userpass

# 2. Create the policy for the mission application
echo "Creating mission-app-policy..."
docker-compose -f $COMPOSE_FILE exec -T vault-server vault policy write mission-app-policy - <<EOF
path "secret/data/mission/api-key" {
  capabilities = ["read"]
}
EOF

# 3. Create a user 'insider' with the mission-app-policy
echo "Creating user 'insider'..."
docker-compose -f $COMPOSE_FILE exec -T vault-server vault write auth/userpass/users/insider \
    password='password123' \
    policies='mission-app-policy'

# 4. Enable the KV v2 secrets engine at 'secret/'
echo "Enabling KV v2 secrets engine..."
docker-compose -f $COMPOSE_FILE exec -T vault-server vault secrets enable -path=secret kv-v2

# 5. Write the secret API key for the demo
echo "Writing secret mission data..."
docker-compose -f $COMPOSE_FILE exec -T vault-server vault kv put secret/mission/api-key classified-key="C9A3-B7E1-A4D6-8B3F"

echo "--- Vault Configuration Complete ---"
