#!/bin/bash

# This script automates the setup and launch of the Vault Tactical Edge Demo.

echo "--- Starting Vault Tactical Edge Demo ---"

# 1. Start all services in the background and force a rebuild of the images.
echo "Building and starting Docker containers..."
docker compose up -d --build

# 2. Wait for the Vault server to become healthy.
echo "Waiting for Vault server to be ready..."
until $(curl --output /dev/null --silent --head --fail http://localhost:8200/v1/sys/health); do
    printf '.'
    sleep 2
done
echo
echo "Vault is up and running!"

# 3. Configure the running Vault instance.
# Use 'docker compose exec' to run commands inside the 'vault-server' container.
echo "--- Configuring Vault ---"

echo "Enabling userpass auth..."
docker compose exec -T vault-server vault auth enable userpass

echo "Creating mission-app-policy..."
docker compose exec -T vault-server vault policy write mission-app-policy - <<EOF
path "secret/data/mission/api-key" {
  capabilities = ["read"]
}
EOF

echo "Creating user 'insider'..."
docker compose exec -T vault-server vault write auth/userpass/users/insider \
    password='password123' \
    policies='mission-app-policy'

echo "Enabling KV v2 secrets engine..."
docker compose exec -T vault-server vault secrets enable -path=secret kv-v2

echo "Writing secret mission data..."
docker compose exec -T vault-server vault kv put secret/mission/api-key classified-key="C9A3-B7E1-A4D6-8B3F"

echo "--- Vault Configuration Complete ---"
echo
echo "✅ Demo is ready!"
echo
echo "Open the Web GUI: http://localhost:8080"
echo "Open the Vault UI: http://localhost:8200 (Token: root)"
echo
echo "To stop the demo, run: docker compose down"

