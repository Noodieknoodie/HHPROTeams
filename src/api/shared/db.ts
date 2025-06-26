import sql, { ConnectionPool, config as SqlConfig, IRecordSet, ISqlTypeFactory } from 'mssql';
import { DefaultAzureCredential, AzureCliCredential } from '@azure/identity';
import { getDatabaseConfig } from './db-config';

// Create a singleton connection pool
let pool: ConnectionPool | null = null;

/**
 * Get or create a connection pool
 */
export async function getPool(): Promise<ConnectionPool> {
  if (!pool) {
    // Get the base configuration
    let sqlConfig: SqlConfig = getDatabaseConfig() as SqlConfig;
    
    // If using Azure AD authentication, get token manually
    if (process.env.AZURE_SQL_AUTHENTICATIONTYPE === 'azure-active-directory-default') {
      try {
        console.log('Getting Azure AD token for SQL authentication...');
        // Use AzureCliCredential for local development
        const credential = new AzureCliCredential();
        const tokenResponse = await credential.getToken('https://database.windows.net/.default');
        
        if (!tokenResponse) {
          throw new Error('Failed to acquire access token');
        }
        
        console.log('Access token acquired successfully');
        
        // Override authentication with token
        sqlConfig = {
          ...sqlConfig,
          authentication: {
            type: 'azure-active-directory-access-token',
            options: {
              token: tokenResponse.token
            }
          } as any
        };
      } catch (error) {
        console.error('Failed to get Azure AD token:', error);
        throw error;
      }
    }
    
    pool = new ConnectionPool(sqlConfig);
    await pool.connect();
    console.log('Connected to Azure SQL Database');
  }
  return pool;
}

/**
 * Execute a query with parameters
 */
export async function executeQuery<T = any>(
  query: string, 
  params?: Record<string, any>
): Promise<T[]> {
  try {
    const pool = await getPool();
    const request = pool.request();
    
    // Add parameters if provided
    if (params) {
      Object.entries(params).forEach(([key, value]) => {
        request.input(key, value);
      });
    }
    
    const result = await request.query(query);
    return result.recordset as T[];
  } catch (error) {
    console.error('Database query error:', error);
    throw error;
  }
}

/**
 * Execute a query and return a single row
 */
export async function executeQuerySingle<T = any>(
  query: string, 
  params?: Record<string, any>
): Promise<T | null> {
  const results = await executeQuery<T>(query, params);
  return results.length > 0 ? results[0] : null;
}

/**
 * Execute a transaction with multiple queries
 */
export async function executeTransaction(
  queries: Array<{ query: string; params?: Record<string, any> }>
): Promise<void> {
  const pool = await getPool();
  const transaction = pool.transaction();
  
  try {
    await transaction.begin();
    
    for (const { query, params } of queries) {
      const request = transaction.request();
      
      if (params) {
        Object.entries(params).forEach(([key, value]) => {
          request.input(key, value);
        });
      }
      
      await request.query(query);
    }
    
    await transaction.commit();
  } catch (error) {
    await transaction.rollback();
    console.error('Transaction error:', error);
    throw error;
  }
}

/**
 * Execute a stored procedure
 */
export async function executeStoredProcedure<T = any>(
  procedureName: string,
  params?: Record<string, any>
): Promise<T[]> {
  try {
    const pool = await getPool();
    const request = pool.request();
    
    if (params) {
      Object.entries(params).forEach(([key, value]) => {
        request.input(key, value);
      });
    }
    
    const result = await request.execute(procedureName);
    return result.recordset as T[];
  } catch (error) {
    console.error('Stored procedure error:', error);
    throw error;
  }
}

/**
 * Close the connection pool
 */
export async function closePool(): Promise<void> {
  if (pool) {
    await pool.close();
    pool = null;
    console.log('Disconnected from Azure SQL Database');
  }
}

// Export sql types for use in other modules
export { sql };
export const TYPES = sql.TYPES;