const express = require('express');
const cors = require('cors');
const path = require('path');
const { exec } = require('child_process');

const app = express();
const port = 8080;

app.use(cors());
app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));

const VAULT_CONTAINER = "vault-tactical-edge-demo_vault-server_1";

const runCommand = (command) => {
  return new Promise((resolve, reject) => {
    exec(command, (error, stdout, stderr) => {
      if (error) {
        console.error(`Exec error for command "${command}": ${stderr}`);
        return reject({ message: stderr || error.message });
      }
      resolve({ message: stdout.trim() });
    });
  });
};

app.get('/api/state', async (req, res) => {
    try {
        const vaultStatusCmd = `docker exec ${VAULT_CONTAINER} vault status -format=json`;
        const result = await runCommand(vaultStatusCmd);
        const vaultState = JSON.parse(result.message);
        res.json({
            vault_server: { status: vaultState.sealed ? 'sealed' : 'unsealed' }
        });
    } catch (error) {
        if (error.message && error.message.includes("sealed")) {
             res.json({ vault_server: { status: 'sealed' } });
        } else {
             res.status(500).json({ message: "Failed to get Vault status.", details: error.message || 'Unknown error' });
        }
    }
});

app.post('/api/actions/:action', async (req, res) => {
    const action = req.params.action;
    try {
        let command, successMessage, responseData = {};

        switch (action) {
            case 'seal-vault':
                command = `docker exec ${VAULT_CONTAINER} vault operator seal`;
                successMessage = "Vault server is now SEALED. All secrets are inaccessible.";
                break;
            
            case 'unseal-vault':
                // In a real scenario, this would use the actual unseal key. For the demo, we use the dev auto-unseal logic.
                // This is a placeholder for a more complex unseal flow if needed.
                // For now, we can simulate by restarting the container which auto-unseals in dev mode.
                command = `docker restart ${VAULT_CONTAINER}`;
                successMessage = "Vault server is UNSEALED and operational.";
                break;

            case 'leak-secret':
                // 1. Login as the 'insider' user
                const loginCmd = `docker exec ${VAULT_CONTAINER} vault login -format=json -method=userpass username=insider password=password123`;
                const loginResult = await runCommand(loginCmd);
                const token = JSON.parse(loginResult.message).auth.client_token;
                
                // 2. Use the token to read the secret
                const readCmd = `docker exec ${VAULT_CONTAINER} vault kv get -format=json -token=${token} secret/mission-app/config`;
                const readResult = await runCommand(readCmd);
                const secret = JSON.parse(readResult.message).data.data.api_key;

                responseData = { leakedSecret: secret, userToken: token };
                successMessage = "Insider threat has logged in and leaked a secret!";
                break;

            case 'revoke-secret':
                const userToken = req.body.token;
                if (!userToken) {
                    return res.status(400).json({ message: "Token to revoke is required." });
                }
                // Revoke the specific token used by the insider
                command = `docker exec ${VAULT_CONTAINER} vault token revoke ${userToken}`;
                successMessage = "Leaked token has been revoked. Insider can no longer access secrets.";
                break;

            default:
                return res.status(400).json({ message: "Invalid action specified." });
        }
        
        if (command) await runCommand(command);
        res.json({ message: successMessage, ...responseData });

    } catch (error) {
        res.status(500).json(error);
    }
});

app.listen(port, () => {
  console.log(`Demo controller listening at http://localhost:${port}`);
});
