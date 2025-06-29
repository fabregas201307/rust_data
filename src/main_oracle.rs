use oracle::{Connection, Error};

fn main() -> Result<(), Error> {
    let conn = Connection::connect("username", "password", "//host:port/service_name")?;
    
    let sql = "SELECT * FROM your_table";
    let rows = conn.query(sql, &[])?;
    
    for row_result in rows {
        let row = row_result?;
        // Process row data
    }
    
    Ok(())
}