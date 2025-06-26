-- Run this in Azure Portal Query Editor as the AAD admin (EKnudsen@HohimerWealthManagement.com)
-- This ensures the SQL user can access the specific database

-- First, check if the user exists at the database level
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'CloudSAddb51659')
BEGIN
    -- Create user in the database from the server login
    CREATE USER [CloudSAddb51659] FOR LOGIN [CloudSAddb51659];
END

-- Grant necessary permissions
ALTER ROLE db_datareader ADD MEMBER [CloudSAddb51659];
ALTER ROLE db_datawriter ADD MEMBER [CloudSAddb51659];
ALTER ROLE db_ddladmin ADD MEMBER [CloudSAddb51659];

-- Verify the user and permissions
SELECT 
    p.name AS principal_name,
    p.type_desc AS principal_type,
    p.authentication_type_desc AS auth_type,
    r.name AS role_name
FROM sys.database_principals p
LEFT JOIN sys.database_role_members rm ON p.principal_id = rm.member_principal_id
LEFT JOIN sys.database_principals r ON rm.role_principal_id = r.principal_id
WHERE p.name = 'CloudSAddb51659';

-- Also verify your Azure AD user
SELECT 
    p.name AS principal_name,
    p.type_desc AS principal_type,
    p.authentication_type_desc AS auth_type,
    r.name AS role_name
FROM sys.database_principals p
LEFT JOIN sys.database_role_members rm ON p.principal_id = rm.member_principal_id
LEFT JOIN sys.database_principals r ON rm.role_principal_id = r.principal_id
WHERE p.name = 'EKnudsen@HohimerWealthManagement.com';