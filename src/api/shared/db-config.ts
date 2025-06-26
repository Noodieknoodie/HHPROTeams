/**
 * Database configuration for Azure SQL
 * Supports both SQL authentication and Azure AD authentication
 */

export interface DatabaseConfig {
  server: string;
  database: string;
  port: number;
  options: {
    encrypt: boolean;
    trustServerCertificate?: boolean;
    enableArithAbort?: boolean;
  };
  user?: string;
  password?: string;
  authentication?: {
    type: 'default' | 'azure-active-directory-default' | 'azure-active-directory-password' | 'azure-active-directory-access-token';
    options?: {
      userName?: string;
      password?: string;
      token?: string;
    };
  };
  pool: {
    max: number;
    min: number;
    idleTimeoutMillis: number;
  };
}

/**
 * Parse ODBC connection string to extract connection parameters
 */
export function parseOdbcConnectionString(connectionString: string): Partial<DatabaseConfig> {
  const params: any = {};
  
  // Extract key-value pairs
  const pairs = connectionString.split(';').filter(pair => pair.trim());
  
  pairs.forEach(pair => {
    const [key, value] = pair.split('=').map(s => s.trim());
    if (key && value) {
      // Handle different ODBC parameter names
      switch (key.toLowerCase()) {
        case 'server':
          // Remove tcp: prefix and port if present
          const serverMatch = value.match(/tcp:(.+?)(,\d+)?$/);
          if (serverMatch) {
            params.server = serverMatch[1];
            if (serverMatch[2]) {
              params.port = parseInt(serverMatch[2].substring(1));
            }
          } else {
            params.server = value;
          }
          break;
        case 'database':
          params.database = value;
          break;
        case 'uid':
          if (!params.authentication) params.authentication = { type: 'default', options: {} };
          params.authentication.options.userName = value;
          break;
        case 'pwd':
          if (!params.authentication) params.authentication = { type: 'default', options: {} };
          params.authentication.options.password = value;
          break;
        case 'authentication':
          if (value.toLowerCase() === 'activedirectorypassword') {
            params.authentication = { ...params.authentication, type: 'azure-active-directory-password' };
          } else if (value.toLowerCase() === 'activedirectoryintegrated') {
            params.authentication = { type: 'azure-active-directory-default' };
          }
          break;
        case 'encrypt':
          if (!params.options) params.options = {};
          params.options.encrypt = value.toLowerCase() === 'yes';
          break;
        case 'trustservercertificate':
          if (!params.options) params.options = {};
          params.options.trustServerCertificate = value.toLowerCase() === 'yes';
          break;
      }
    }
  });
  
  return params;
}

/**
 * Get database configuration from environment variables or connection string
 */
export function getDatabaseConfig(): DatabaseConfig {
  const authType = process.env.AZURE_SQL_AUTHENTICATIONTYPE || process.env.SQL_AUTH_TYPE || 'default';
  
  // Configuration based on Microsoft docs for Node.js
  const baseConfig: DatabaseConfig = {
    server: process.env.AZURE_SQL_SERVER || process.env.SQL_SERVER || 'hohimerpro-db-server.database.windows.net',
    database: process.env.AZURE_SQL_DATABASE || process.env.SQL_DATABASE || 'HWM_401k',
    port: parseInt(process.env.AZURE_SQL_PORT || process.env.SQL_PORT || '1433'),
    options: {
      encrypt: true
    },
    pool: {
      max: 10,
      min: 0,
      idleTimeoutMillis: 30000,
    },
  };

  // Handle different authentication types
  if (authType === 'azure-active-directory-default') {
    // Passwordless authentication for local development
    console.log('Using Azure AD Default authentication (passwordless)');
    baseConfig.authentication = {
      type: 'azure-active-directory-default'
    };
  } else if (authType === 'azure-active-directory-password') {
    // Azure AD with password
    console.log('Using Azure AD Password authentication');
    baseConfig.authentication = {
      type: 'azure-active-directory-password',
      options: {
        userName: process.env.AZURE_SQL_USER || process.env.SQL_USER,
        password: process.env.AZURE_SQL_PASSWORD || process.env.SQL_PASSWORD,
      }
    };
  } else {
    // SQL authentication
    console.log('Using SQL authentication');
    baseConfig.user = process.env.AZURE_SQL_USER || process.env.SQL_USER || 'CloudSAddb51659';
    baseConfig.password = process.env.AZURE_SQL_PASSWORD || process.env.SQL_PASSWORD || '';
    console.log('SQL User:', baseConfig.user);
    console.log('SQL Password length:', baseConfig.password.length);
  }

  return baseConfig;
}