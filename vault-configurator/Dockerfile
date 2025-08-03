# This Dockerfile builds the container that configures Vault.

# We use the official vault image as our base, so it already has the 'vault' CLI.
FROM hashicorp/vault:1.20

# We only need to add 'curl' for the health check loop in our script.
RUN apk add --no-cache curl

# Copy the configuration script into the container
COPY configure-vault.sh /usr/local/bin/configure-vault.sh

# Make the script executable
RUN chmod +x /usr/local/bin/configure-vault.sh

# The command to run when the container starts
CMD ["configure-vault.sh"]
