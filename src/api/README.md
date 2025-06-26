# Azure SQL Database Connection

This module provides database connectivity to Azure SQL Database for the Teams 401k application.

## Configuration

The database connection can be configured in two ways:

### 1. Using Environment Variables

Add these to your `.env.local` file:

```env
SQL_SERVER=hohimerpro-db-server.database.windows.net
SQL_DATABASE=HWM_401k
SQL_USER=CloudSAddb51659
SQL_PASSWORD=your_password_here
SQL_AUTH_TYPE=default
```

### 2. Using Connection String

You can also use a full ODBC connection string:

```env
SQL_CONNECTION_STRING=Driver={ODBC Driver 18 for SQL Server};Server=tcp:hohimerpro-db-server.database.windows.net,1433;Database=HWM_401k;Uid=CloudSAddb51659;Pwd=your_password_here;Encrypt=yes;TrustServerCertificate=no;Connection Timeout=30;
```

## Authentication Methods

### SQL Authentication (Default)
- Uses username and password
- Set `SQL_AUTH_TYPE=default`

### Azure AD Password Authentication
- Uses Azure AD username and password
- Set `SQL_AUTH_TYPE=azure-active-directory-password`

### Azure AD Integrated Authentication
- Uses current Azure AD identity
- Set `SQL_AUTH_TYPE=azure-active-directory-default`

## Usage

```typescript
import { executeQuery, executeQuerySingle, executeTransaction } from './shared/db';

// Query multiple rows
const clients = await executeQuery<Client>(
  'SELECT * FROM clients WHERE valid_to IS NULL'
);

// Query single row with parameters
const client = await executeQuerySingle<Client>(
  'SELECT * FROM clients WHERE client_id = @clientId',
  { clientId: 123 }
);

// Execute transaction
await executeTransaction([
  {
    query: 'INSERT INTO payments (...) VALUES (...)',
    params: { /* parameters */ }
  },
  {
    query: 'UPDATE client_metrics SET ...',
    params: { /* parameters */ }
  }
]);
```

## Testing Connection

Run the test script to verify database connectivity:

```bash
npm run test:db
```

This will:
1. Test basic connection
2. Query clients table
3. Test parameterized queries
4. Verify proper configuration