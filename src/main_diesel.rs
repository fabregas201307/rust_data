use diesel::prelude::*;
use diesel::mysql::MysqlConnection;

fn main() -> Result<(), diesel::result::Error> {
    use schema::your_table::dsl::*;
    
    let database_url = "mysql://user:password@localhost:3306/database";
    let conn = MysqlConnection::establish(database_url)
        .expect("Error connecting to MySQL database");
        
    let results = your_table
        .limit(5)
        .load::<YourModel>(&conn)?;
        
    for row in results {
        // Process row data
    }
    
    Ok(())
}