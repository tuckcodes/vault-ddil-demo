# HashiCorp Vault: Tactical Edge Demo

This project provides a live, interactive demonstration of HashiCorp Vault's capabilities in a simulated high-stakes, disconnected military environment. The demo showcases how Vault can provide a secure, resilient, and automated secrets management solution for applications at the tactical edge, even under Disconnected, Degraded, Intermittent, and Limited (DDIL) network conditions.

The narrative is based on a realistic "2CR Battle Cloud" scenario, where a fleet of Stryker vehicles runs a containerized application stack that must remain operational and secure at all times.

---

## How It Works

This demo uses `Docker Compose` to create a self-contained local environment on your machine. The environment consists of:

* **Vault Server**: A single Vault server running in development mode, acting as the in-theater security control plane.
* **"Stryker" Agents**: Several placeholder containers representing the Vault Agents that would run on each vehicle.
* **Demo Controller**: A lightweight Node.js server that serves the web GUI and provides a control API to interact with the live Vault container.
* **Web GUI**: An interactive, single-page web application that acts as the control panel for the demo, allowing you to trigger security scenarios and observe the results in real-time.

---

## Prerequisites

Before you begin, ensure you have the following software installed on your machine:

* **Git**: To clone the repository.
* **Docker**: To run the containerized environment.
* **Docker Compose**: To orchestrate the multi-container application.

---

## Quick Start

Getting the demo running is a single command. Open your terminal, and paste the following line:

    git clone https://github.com/tuckcodes/vault-tactical-edge-demo.git && cd vault-tactical-edge-demo && ./run-demo.sh

This command will:

* Clone this repository to your local machine.
* Navigate into the project directory.
* Execute the setup script, which builds and starts all the necessary Docker containers.

Once the script finishes, it will print the URLs for the Web GUI and the Vault Server UI.

---

## Using the Demo

After running the Quick Start command, open your web browser and navigate to:
[http://localhost:8080](http://localhost:8080)

You will be presented with the main demo interface, which includes a tactical map and a control panel.

---

## Interactive Scenarios

The control panel allows you to trigger live scenarios against the running Vault instance.

### Scenario 1: Seal Vault Server

* **Action**: Click the "**Scenario 1: Seal Vault Server**" button.
* **What Happens**: The API server executes a `vault operator seal` command on the Vault container. This encrypts all of Vault's data and makes it unable to serve any secrets.
* **Observe**:
    * The Vault icon on the map will turn red and start blinking, indicating it is sealed and offline.
    * The event log will confirm that the server has been sealed.
    * Any application trying to get a *new* secret would now fail.

### Scenario 2: Insider Threat & Credential Leak

* **Action**: Click the "**Scenario 2: Insider Threat & Leak**" button.
* **What Happens**: The API simulates a malicious insider with limited privileges (`mission-app-policy`) logging in, reading a secret, and leaking it.
* **Observe**:
    * The event log will show that the insider has successfully logged in.
    * A moment later, the log will display the *actual classified API key* that was leaked, highlighted in red.
    * After a 3-second delay (simulating an admin's reaction time), the log will confirm that the *insider's token has been revoked*, immediately cutting off their access. This demonstrates Vault's powerful ability to contain a breach in real-time.

### Action: Unseal Vault

* **Action**: Click the "**Action: Unseal Vault**" button.
* **What Happens**: In this demo, the API simply restarts the Vault container, which is in dev mode and unseals automatically. In a real-world scenario, this would require a quorum of unseal keys.
* **Observe**:
    * The Vault icon on the map will turn blue and start pulsing, indicating it is unsealed and fully operational.
    * The event log will confirm that the server is unsealed.

---

## Technical Deep Dive

* **`run-demo.sh`**: This script is the main entry point. It handles dependency checks, cleanup, and launching the Docker Compose environment. It also runs a series of `docker exec` commands to configure the running Vault instance with the necessary policies and users for the demo scenarios.
* **`ddil-vault-compose.yaml`**: Defines the four services of the demo. Note the volume mount for `/var/run/docker.sock` on the `demo-controller`, which is what allows the API to execute commands on other containers.
* **`demo-controller/`**: This directory contains the source code for the Node.js Express server and the static `index.html` GUI. The server's primary role is to act as a secure bridge between the user's browser and the Docker environment.

---

## Cleaning Up

To stop and completely remove the demo environment, navigate to the project directory in your terminal and run:

    docker-compose -f ddil-vault-compose.yaml down --remove-orphans

This will stop and delete all containers and networks associated with the demo.