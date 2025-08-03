#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e
# Treat unset variables as an error when substituting.
set -u
# Pipes will fail if any command in the pipe fails.
set -o pipefail

# --- Configuration & Helper Functions ---
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color
COMPOSE_FILE="ddil-vault-compose.yaml"

print_message() {
    echo -e "${GREEN}▶ $1${NC}"
}

check_dependency() {
    if ! command -v "$1" &> /dev/null; then
        echo -e "${YELLOW}Error: '$1' command not found. Please install it and try again.${NC}"
        exit 1
    fi
}

# --- Phase 1: Pre-flight Checks ---
print_message "Phase 1: Running Pre-flight Checks..."
check_dependency "docker"
check_dependency "docker-compose"

# --- Phase 2: Environment Cleanup ---
print_message "Phase 2: Cleaning up any previous demo environments..."
if [ -f "$COMPOSE_FILE" ]; then
    docker-compose -f "$COMPOSE_FILE" down --remove-orphans
fi

# --- Phase 3: Build and Launch Environment ---
print_message "Phase 3: Building and launching the demo environment..."
docker-compose -f "$COMPOSE_FILE" up --build -d

# --- Phase 4: Configure Live Vault Instance ---
print_message "Phase 4: Configuring Vault for demo scenarios..."
# Wait a few seconds for the Vault container to be fully up and running
sleep 5
VAULT_CONTAINER_NAME="vault-tactical-edge-demo_vault-server_1"

# The root token is set to 'root' in the docker-compose file for simplicity
export VAULT_TOKEN=root

# Enable KV-V2 secrets engine and create a sample secret
print_message "Enabling KV-V2 secrets engine and creating mission secret..."
docker exec "$VAULT_CONTAINER_NAME" vault secrets enable -path=secret kv-v2
docker exec "$VAULT_CONTAINER_NAME" vault kv put secret/mission-app/config api_key="CLASSIFIED-STRYKER-B2-API-KEY" target_grid="NK-1701"

# Enable userpass auth method for the insider threat scenario
print_message "Enabling Userpass auth method..."
docker exec "$VAULT_CONTAINER_NAME" vault auth enable userpass

# Write the policy from the local file into Vault
print_message "Writing 'mission-app-policy' into Vault..."
docker exec -i "$VAULT_CONTAINER_NAME" vault policy write mission-app-policy - < ./policies/mission-app-policy.hcl

# Create a user for the insider threat scenario
print_message "Creating 'insider' user with limited privileges..."
docker exec "$VAULT_CONTAINER_NAME" vault write auth/userpass/users/insider password="password123" policies="mission-app-policy"

# --- Phase 5: Final Output ---
VAULT_IP=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ${VAULT_CONTAINER_NAME})

print_message "Phase 5: Demo Environment is Ready!"
echo "------------------------------------------------------------------"
echo -e "${YELLOW}The Tactical Demo GUI is now running at:${NC} http://localhost:8080"
echo -e "${YELLOW}The Vault Server UI is accessible at:${NC} http://${VAULT_IP}:8200 (Token: root)"
echo ""
echo "Use the web GUI to run interactive scenarios against the live Vault instance."
echo "You can view logs with: 'docker-compose -f ${COMPOSE_FILE} logs -f'"
echo "------------------------------------------------------------------"
