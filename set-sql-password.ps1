# PowerShell script to set SQL password using Azure CLI
# Run this in Azure Cloud Shell or local Azure CLI

$resourceGroup = "HWM_401k"
$serverName = "hohimerpro-db-server"
$adminPassword = "YourSecurePassword123!" # Change this to your desired password

# Update SQL server admin password
az sql server update `
    --resource-group $resourceGroup `
    --name $serverName `
    --admin-password $adminPassword

Write-Host "SQL admin password updated successfully"
Write-Host "Update your .env.local file with:"
Write-Host "AZURE_SQL_PASSWORD=$adminPassword"