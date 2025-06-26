● So this is a migration/conversion project where I need to:
  1. Take the existing, working Python/Next.js codebase
  2. Convert it to TypeScript while preserving ALL business logic exactly
  3. Use the Agent 365 Toolkit scaffolding that's already set up
  4. Connect to the existing Azure SQL database that's already populated
  5. Ensure the converted app passes all test cases in test_cases.json

## Project Migration Overview: HohimerPro Python Backend to TypeScript Teams Tab App

### Current Setup
HohimerPro is a 401(k) payment tracking system with a Python/FastAPI backend and Next.js/React frontend. The backend manages CRUD operations for clients, contracts, and payments, with business logic for fee calculations, payment period tracking, and compliance status monitoring. It currently uses SQLite with dynamic path detection to switch between local development and OneDrive office environments.

### Target Architecture
We are migrating to an all-TypeScript stack deployed as a Microsoft Teams tab application using the Agent 365 toolkit. The new architecture will:
- Use Node.js/TypeScript for all backend operations (Azure Functions)
- Deploy as a Teams tab application with React/TypeScript frontend
- Utilize Azure SQL Database instead of SQLite
- Integrate naturally with the Teams ecosystem and Azure services

### Reasons for Migration
1. **Type Safety**: TypeScript provides compile-time type checking matching Python's type hints
2. **Teams Integration**: Teams SDK and toolkit are TypeScript-first
3. **Unified Stack**: Single language across frontend and backend
4. **Better Tooling**: Superior IntelliSense, refactoring, and error detection
5. **Azure Support**: First-class TypeScript support in Azure Functions

### Functionality to Retain
All core business logic must be preserved exactly:
- **Client Management**: List, search, and retrieve client information with payment status
- **Contract Management**: Fee calculations (flat rate vs percentage-based), payment schedules (monthly/quarterly)
- **Payment Operations**: Full CRUD with split payment support, period calculations, and variance tracking
- **Business Logic**: 
  - Compliance status determination (green/yellow/red)
  - Expected fee calculations based on contract terms
  - Payment variance calculations (exact/acceptable/warning/alert)
  - Period generation and validation
  - Next payment due date calculations
- **Data Validation**: All current validation rules for payments, periods, and amounts

### Functionality to Remove
- **File/Document Management**: No OneDrive integration or local file path handling
- **Dynamic Path Detection**: No need for office vs home mode switching
- **SQLite-specific Features**: Replace with Azure SQL equivalents
- **Local Backup Systems**: Azure handles backups at the infrastructure level

### New Azure Integration
- **Database**: Azure SQL Database replaces SQLite (schema already migrated)
- **Authentication**: Teams/Azure AD authentication instead of open access
- **Hosting**: Azure Functions with TypeScript runtime
- **Configuration**: Azure App Configuration or environment variables instead of path-based config

### Testing Framework
A `test_cases.json` file has been generated from the current Python implementation containing real inputs and expected outputs for all critical business functions. The TypeScript implementation must produce identical results for these test cases to ensure functional parity.

### Success Criteria
The migration is complete when:
1. All test cases in `test_cases.json` pass with identical outputs
2. The application runs natively in Teams
3. All CRUD operations work with Azure SQL
4. Business logic produces identical results to the Python version
5. The codebase is 100% TypeScript with strict type checking enabled
6. All Python type hints are converted to TypeScript interfaces/types

This migration preserves all business value while modernizing the technical stack for Teams deployment with enhanced type safety throughout.



# Name: Agenda_Teams_Subscription  
Subscription ID: e2ed8f3b-7c6a-46b9-a829-65aad1898d3e  
State: Enabled


# ENTRA: Hohimer Wealth Management | Tenant ID: e621abc4-3baa-4b93-badc-3b99e8609963  
Domain: HohimerWealthManagement.com | License: Microsoft Entra ID P1


# AZURE DB
AZURE SQL DATABASE (DEV CONFIG)
database name - it's HohimerPro-401k not HWM_401k.
HohimerPro-401k
General Purpose - Serverless: Standard-series (Gen5), 1 vCore
Server: hohimerpro-db-server.database.windows.net,1433
Region: West US 2
Subscription: Agenda_Teams_Subscription
Subscription ID: e2ed8f3b-7c6a-46b9-a829-65aad1898d3e
Resource Group: HWM_401k

Authentication Method: AAD (Admin: EKnudsen@HohimerWealthManagement.com)
Public Access: Enabled
Firewall IP Whitelisted: Yes (1 rule)
Connection Strings: Available in Azure Portal
Pricing Tier: Serverless (Gen5, 1 vCore)
Auto-pause Delay: 1 hour
Max Storage: 32 GB
Backups: PITR 7 days, Differential every 12 hrs
Geo-redundant backup storage: Enabled
Zone Redundancy: Disabled
SQL Authentication: Not enabled (must configure manually if needed)

Primary Endpoint: hohimerpro-db-server.database.windows.net


mssql package supports
  passwordless authentication using azure-active-directory-default authentication type.



ODBC (Includes Node.js) (SQL authentication)
Driver={ODBC Driver 18 for SQL Server};Server=tcp:hohimerpro-db-server.database.windows.net,1433;Database=HohimerPro-401k;Uid=CloudSAddb51659;Pwd={your_password_here};Encrypt=yes;TrustServerCertificate=no;Connection Timeout=30;

ODBC (Includes Node.js) (Microsoft Entra password authentication)
Driver={ODBC Driver 18 for SQL Server};Server=tcp:hohimerpro-db-server.database.windows.net,1433;Database=HohimerPro-401k;Uid={your_user_name};Pwd={your_password_here};Encrypt=yes;TrustServerCertificate=no;Connection Timeout=30;Authentication=ActiveDirectoryPassword

ODBC (Includes Node.js) (Microsoft Entra integrated authentication)
Driver={ODBC Driver 18 for SQL Server};Server=tcp:hohimerpro-db-server.database.windows.net,1433;Database=HohimerPro-401k;Uid={your_user_name};Encrypt=yes;TrustServerCertificate=no;Connection Timeout=30;Authentication=ActiveDirectoryIntegrated


