-- Run this script in Azure Portal Query Editor as the AAD admin
-- This grants your local Azure AD account access to the database

-- Create user for local development (replace with your email)
CREATE USER [EKnudsen@HohimerWealthManagement.com] FROM EXTERNAL PROVIDER;

-- Grant necessary permissions
ALTER ROLE db_datareader ADD MEMBER [EKnudsen@HohimerWealthManagement.com];
ALTER ROLE db_datawriter ADD MEMBER [EKnudsen@HohimerWealthManagement.com];
ALTER ROLE db_ddladmin ADD MEMBER [EKnudsen@HohimerWealthManagement.com];

-- Verify the user was created
SELECT name, type_desc, authentication_type_desc 
FROM sys.database_principals 
WHERE name = 'EKnudsen@HohimerWealthManagement.com';

-- Check role membership
SELECT 
    p.name AS principal_name,
    p.type_desc AS principal_type,
    r.name AS role_name
FROM sys.database_role_members rm
JOIN sys.database_principals p ON rm.member_principal_id = p.principal_id
JOIN sys.database_principals r ON rm.role_principal_id = r.principal_id
WHERE p.name = 'EKnudsen@HohimerWealthManagement.com';