-- Run this in Azure Portal Query Editor as the AAD admin
-- This creates a new SQL user specifically for the application

-- Step 1: Create a new login at the server level (run in master database)
-- First, connect to the master database and run:
/*
USE master;
CREATE LOGIN [Teams401kApp] WITH PASSWORD = 'YourSecurePassword123!';
*/

-- Step 2: Create user in the HWM_401k database (run in HWM_401k database)
USE [HWM_401k];

-- Create user from the login
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'Teams401kApp')
BEGIN
    CREATE USER [Teams401kApp] FOR LOGIN [Teams401kApp];
END

-- Grant necessary permissions
ALTER ROLE db_datareader ADD MEMBER [Teams401kApp];
ALTER ROLE db_datawriter ADD MEMBER [Teams401kApp];
ALTER ROLE db_ddladmin ADD MEMBER [Teams401kApp];

-- Verify the user was created
SELECT 
    p.name AS principal_name,
    p.type_desc AS principal_type,
    p.authentication_type_desc AS auth_type,
    r.name AS role_name
FROM sys.database_principals p
LEFT JOIN sys.database_role_members rm ON p.principal_id = rm.member_principal_id
LEFT JOIN sys.database_principals r ON rm.role_principal_id = r.principal_id
WHERE p.name = 'Teams401kApp';

-- List all database users
SELECT name, type_desc, authentication_type_desc 
FROM sys.database_principals 
WHERE type IN ('S', 'U', 'E') -- SQL users, Windows users, External users
ORDER BY name;