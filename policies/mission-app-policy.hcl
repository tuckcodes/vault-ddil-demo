# Allow read-only access to secrets in the 'mission-app' path
path "secret/data/mission-app/*" {
  capabilities = ["read"]
}
