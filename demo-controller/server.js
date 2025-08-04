// This is the Node.js server for the demo controller.
// It serves the web GUI and provides an API to interact with the Docker containers.

const express = require('express');
const { exec } = require('child_process');
const cors = require('cors');
const path = require('path');

const app = express();
const PORT = 8080;

app.use(cors());
app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));

// Store the leaked token in memory for the demo
let leakedUserToken = null;

// Helper function to execute shell commands
const runCommand = (command) => {
    return new Promise((resolve, reject) => {
        exec(command, (error, stdout, stderr) => {
            if (error) {
                if (error) {
                    console.error(`Command error: ${stderr}`);
                    return reject(new Error(stderr));
                }
            }
            resolve(stdout.trim());
        });
    });
};

// --- Health Check Endpoint ---
// The frontend will poll this to know when the server is ready.
app.get('/api/health', (req, res) => {
    res.status(200).json({ status: 'ok' });
});


// --- Story API Endpoints ---

app.post('/api/story/disconnect', (req, res) => {
    // This is a simulated action for the story. No actual command is needed.
    res.json({ message: 'SATCOM link simulation toggled to DISCONNECTED.' });
});

app.post('/api/story/reconnect', (req, res) => {
    // This is a simulated action for the story.
    res.json({ message: 'SATCOM link simulation toggled to CONNECTED.' });
});

app.post('/api/story/login', async (req, res) => {
    try {
        const command = "docker exec vault-server-demo vault login -format=json -method=userpass username=insider password=password123";
        const output = await runCommand(command);
        const loginData = JSON.parse(output);
        leakedUserToken = loginData.auth.client_token; // Save the token for the next steps
        res.json({ command: "vault login -method=userpass username=insider password=...", output, token: leakedUserToken });
    } catch (error) {
        res.status(500).json({ message: `Login failed: ${error.message}` });
    }
});

app.post('/api/story/steal', async (req, res) => {
    if (!leakedUserToken) {
        return res.status(400).json({ message: 'Error: Insider has not logged in yet.' });
    }
    try {
        const command = `docker exec vault-server-demo vault kv get -format=json secret/mission/api-key`;
        // We add the token via an environment variable for security, rather than a command-line flag.
        const commandWithToken = `docker exec -e VAULT_TOKEN=${leakedUserToken} vault-server-demo vault kv get -format=json secret/mission/api-key`;
        
        const output = await runCommand(commandWithToken);

        // Send the response to the user immediately so they see the "win"
        res.json({ command: "vault kv get secret/mission/api-key", output });

        // After a delay, trigger the containment (token revocation) in the background
        setTimeout(async () => {
            try {
                console.log(`[BACKGROUND] Detected leak. Revoking token: ${leakedUserToken}`);
                const revokeCmd = `docker exec vault-server-demo vault token revoke ${leakedUserToken}`;
                await runCommand(revokeCmd);
                console.log(`[BACKGROUND] Successfully revoked token.`);
                leakedUserToken = null; // Clear the token
            } catch (revokeError) {
                console.error(`[BACKGROUND] Failed to revoke token: ${revokeError.message}`);
            }
        }, 3000);

    } catch (error) {
        res.status(500).json({ message: `Steal failed: ${error.message}` });
    }
});


app.listen(PORT, () => {
    console.log(`Demo controller server running on http://localhost:${PORT}`);
});
