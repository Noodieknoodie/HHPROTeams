#!/bin/bash

# Setup passwordless connection for Azure SQL Database
# This script uses Service Connector to configure managed identity access

echo "Setting up passwordless connection to Azure SQL Database..."

# Variables - update these with your values
RESOURCE_GROUP="<your-app-service-resource-group>"
APP_NAME="<your-app-service-name>"
SQL_RESOURCE_GROUP="HWM_401k"
SQL_SERVER="hohimerpro-db-server"
DATABASE_NAME="HWM_401k"

# Install Service Connector extension
echo "Installing Service Connector extension..."
az extension add --name serviceconnector-passwordless --upgrade

# Create passwordless connection using system-assigned managed identity
echo "Creating passwordless connection..."
az webapp connection create sql \
    --resource-group $RESOURCE_GROUP \
    --name $APP_NAME \
    --target-resource-group $SQL_RESOURCE_GROUP \
    --server $SQL_SERVER \
    --database $DATABASE_NAME \
    --system-identity \
    --client-type nodejs

echo "Connection created successfully!"
echo "The Service Connector has:"
echo "1. Enabled managed identity for your App Service"
echo "2. Set the Microsoft Entra admin to current user"
echo "3. Added database user for the managed identity"
echo "4. Set AZURE_SQL_CONNECTIONSTRING in App Settings"

# For local development, create a database user for your Azure AD account
echo ""
echo "For local development, run this SQL command as admin:"
echo "CREATE USER [your-email@domain.com] FROM EXTERNAL PROVIDER;"
echo "ALTER ROLE db_datareader ADD MEMBER [your-email@domain.com];"
echo "ALTER ROLE db_datawriter ADD MEMBER [your-email@domain.com];"