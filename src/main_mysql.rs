use mysql::*;
use mysql::prelude::*;

fn main() -> Result<()> {
    let url = "mysql://user:password@localhost:3306/database";
    let pool = Pool::new(url)?;
    let mut conn = pool.get_conn()?;
    
    let results = conn.query_iter("SELECT * FROM your_table")?;
    for row in results {
        let row = row?;
        // Process row data
    }
    
    Ok(())
}