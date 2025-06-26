-- Run this in Azure Portal Query Editor or Azure Data Studio
-- Connect as the AAD admin (EKnudsen@HohimerWealthManagement.com)

-- Set password for SQL user
ALTER LOGIN [CloudSAddb51659] WITH PASSWORD = 'YourSecurePassword123!';

-- Ensure the user exists in the database
USE [HWM_401k];
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'CloudSAddb51659')
BEGIN
    CREATE USER [CloudSAddb51659] FOR LOGIN [CloudSAddb51659];
END

-- Grant permissions
ALTER ROLE db_datareader ADD MEMBER [CloudSAddb51659];
ALTER ROLE db_datawriter ADD MEMBER [CloudSAddb51659];
ALTER ROLE db_ddladmin ADD MEMBER [CloudSAddb51659];

-- For Azure AD user access (if needed)
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'EKnudsen@HohimerWealthManagement.com')
BEGIN
    CREATE USER [EKnudsen@HohimerWealthManagement.com] FROM EXTERNAL PROVIDER;
    ALTER ROLE db_datareader ADD MEMBER [EKnudsen@HohimerWealthManagement.com];
    ALTER ROLE db_datawriter ADD MEMBER [EKnudsen@HohimerWealthManagement.com];
    ALTER ROLE db_ddladmin ADD MEMBER [EKnudsen@HohimerWealthManagement.com];
END