# Write an error log entry

Write an error log entry

## Usage

``` r
write_error_log_entry(conn, target_db_name, table_written = NULL, df, pk_col)
```

## Arguments

- conn, :

  a DB connection

- target_db_name, :

  the database to write to

- table_written, :

  the table that was written to

- df, :

  the data to write

- pk_col, :

  the dataframe col to use as the primary_key

## Examples

``` r
if (FALSE) { # \dontrun{
 write_error_log_entry(
   conn = con,
   target_db_name = rc_case,
   table_written = "cases",
   df = data_written,
   pk_col = "record_id"
 )
} # }
```
