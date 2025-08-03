# HashiCorp Vault: Tactical Edge Demo (Codespaces Edition)

This project provides a live, one-click, interactive demonstration of HashiCorp Vault's capabilities in a simulated tactical environment. It runs entirely in your browser via GitHub Codespaces, requiring **zero local installation**.

The demo showcases how Vault provides a secure and resilient secrets management solution for applications at the tactical edge, even under Disconnected, Degraded, Intermittent, and Limited (DDIL) network conditions.

## 🚀 One-Click Launch

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://github.com/codespaces/new?repo=tuckcodes/vault-ddil-demo)

Click the button above to launch the demo environment directly in a new Codespace. This may take a few minutes on the first run.

## How to Use the Demo

Once the Codespace is running, a "Ports" tab will appear in the VS Code terminal pane.

1.  Find the **Demo GUI (8080)** port in the list and click the globe icon (Open in Browser) next to it.
2.  A new browser tab will open with the interactive demo interface, including a tactical map and a control panel.
3.  Use the control panel buttons to trigger the interactive scenarios and observe the results in the event log.

You can also access the raw Vault UI via the **Vault UI (8200)** port.

### Interactive Scenarios

The control panel allows you to trigger live scenarios against the running Vault instance.

* **Scenario 1: Seal Vault Server**: Simulates a network or power failure by sealing the Vault server, making it unable to serve secrets.
* **Scenario 2: Insider Threat & Leak**: Simulates a credential leak and demonstrates Vault's ability to contain the breach in real-time by revoking the compromised token.
* **Action: Unseal Vault**: Restarts the Vault server to bring it back online.

## How It Works

This demo uses a **Dev Container** to define a complete, self-contained development environment. When you launch the Codespace:

1.  The `.devcontainer/devcontainer.json` file instructs GitHub to build a custom environment.
2.  It uses Docker Compose to launch three services: the Vault server, the demo controller, and a placeholder agent.
3.  A setup script (`setup-vault.sh`) runs automatically to configure the Vault instance with the necessary policies and secrets for the demo.
4.  Ports `8080` (Web GUI) and `8200` (Vault UI) are automatically forwarded and made accessible to you via a private URL.

This entire process is automated, providing a seamless and secure way to run the demo without affecting your local machine.
