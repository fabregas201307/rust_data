use std::env;
use std::error::Error;

mod mysql_db;
mod oracle_db;
mod diesel_db;
mod schema;
mod models;
mod sqlserver_db;

#[tokio::main]
async fn main() -> Result<(), Box<dyn Error>> {
    println!("Starting rust_abdata ETL process");

    // Determine which database to use from environment variable
    let db_type = env::var("DB_TYPE").unwrap_or_else(|_| "oracle".to_string());
    match db_type.to_lowercase().as_str() {
        "oracle" => {
            println!("Using Oracle database");
            oracle_db::run().await?;
        },
        "mysql" => {
            println!("Using MySQL native driver");
            mysql_db::run().await?;
        },
        "diesel" => {
            println!("Using Diesel ORM with MySQL");
            diesel_db::run().await?;
        },
        "sqlserver" => {
            println!("Using Tiberius with SQL Server");
            match sqlserver_db::run().await {
                Ok(_) => println!("SQL Server connection succeeded"),
                Err(e) => {
                    eprintln!("SQL Server connection error: {}", e);
                    eprintln!("Error details: {:?}", e);
                    return Err(e);
                }
            }
        },
        _ => {
            return Err(format!("Unknown database type: {}", db_type).into());
        }
    }

    println!("ETL process completed successfully");
    Ok(())
}