import { executeQuery, closePool } from './shared/db';
import dotenv from 'dotenv';
import * as path from 'path';

// Load environment variables
const envFile = process.env.TEAMSFX_ENV ? `.env.${process.env.TEAMSFX_ENV}` : '.env.local';
dotenv.config({ path: path.join(__dirname, '..', '..', 'env', envFile) });

async function testConnection() {
  try {
    console.log('Testing Azure SQL Database connection...');
    console.log('Environment variables:');
    console.log('  AZURE_SQL_SERVER:', process.env.AZURE_SQL_SERVER);
    console.log('  AZURE_SQL_DATABASE:', process.env.AZURE_SQL_DATABASE);
    console.log('  AZURE_SQL_AUTHENTICATIONTYPE:', process.env.AZURE_SQL_AUTHENTICATIONTYPE);
    
    // Test basic connection with a simple query
    const result = await executeQuery('SELECT @@VERSION AS Version, SUSER_SNAME() AS CurrentUser');
    console.log('SQL Server Version:', result[0].Version);
    console.log('Connected as user:', result[0].CurrentUser);
    
    // Test querying the clients table
    const clients = await executeQuery(
      'SELECT TOP 5 client_id, display_name, full_name FROM dbo.clients WHERE valid_to IS NULL'
    );
    console.log(`Found ${clients.length} clients:`);
    clients.forEach(client => {
      console.log(`  - ${client.display_name} (ID: ${client.client_id})`);
    });
    
    // Test parameterized query
    if (clients.length > 0) {
      const clientId = clients[0].client_id;
      const contracts = await executeQuery(
        `SELECT contract_id, provider_name, fee_type, payment_schedule 
         FROM dbo.contracts 
         WHERE client_id = @clientId AND valid_to IS NULL`,
        { clientId }
      );
      console.log(`\nContracts for ${clients[0].display_name}:`, contracts.length);
    }
    
    console.log('\nDatabase connection test successful!');
  } catch (error) {
    console.error('Database connection test failed:', error);
  } finally {
    await closePool();
  }
}

// Run the test
testConnection();