# .devcontainer/Dockerfile
# This Dockerfile is used to build the main 'demo' service container.

FROM mcr.microsoft.com/devcontainers/base:ubuntu

# Install curl and other dependencies needed for the setup script
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends curl

# Install Docker CLI for the setup script to execute 'docker exec'
RUN apt-get install -y docker.io
