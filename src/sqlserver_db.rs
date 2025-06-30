use std::error::Error;
use tokio::net::TcpStream;
use tokio_asyncwriteCompatExt;
use tiberius::{Client, Config};
use std::env;

pub async fn run() -> Result<(), Box<dyn Error>> {
    // Get connection details from environment or use defaults
    let server = env::var("SQLSERVER_HOST").unwrap_or_else(|_| "fiqdbprod.ac.lp.acml.com".to_string());
    let port = env::var("SQLSERVER_PORT").unwrap_or_else(|_| "1517".to_string())
        .parse::<u16>().unwrap_or(1517);
    let database = env::var("SQLSERVER_DATABASE").unwrap_or_else(|_| "FIQModel".to_string());
    let username = env::var("SQLSERVER_USERNAME").unwrap_or_else(|_| "user-app-fiq".to_string());
    let password = env::var("SQLSERVER_PASSWORD").unwrap_or_else(|_| "fiquant!".to_string());

    // Configure connection
    let mut config = Config::new();
    config.host(server);
    config.port(port);
    config.authentication(tiberius::AuthMethod::sql_server(&username, &password));
    config.database(&database);

    // IMPORTANT: Disable TLS verification to accept self-signed certificates
    config.trust_cert();

    // Explicitly disable encryption for troubleshooting if needed
    let disable_encryption = env::var("DISABLE_ENCRYPTION").unwrap_or_else(|_| "false".to_string());
    if disable_encryption == "true" {
        config.encryption(tiberius::EncryptionLevel::NotSupported);
        println!("SQL Server encryption disabled");
    }

    println!("Connecting to SQL Server at {{:?:}} as {{}} on database: {{}}",
             server, username, database);

    // Connect
    let tcp = TcpStream::connect(config.get_addr()).await?;
    tcp.set_nodelay(true)?;

    let mut client = Client::connect(config, tcp.compat_write()).await?;

    // Execute a query
    let query = "SELECT TOP 5 * FROM FIQModel.dbo.CORP_ANALYTICS";
    let stream = client.query(query, &[]).await?;
    let rows = stream.into_results().await?;

    // Process the results
    for row_set in rows {
        for row in row_set {
            println!("SQL Server row: {{:?}}", row);
        }
    }

    println!("SQL Server query completed successfully");

    Ok(())
}