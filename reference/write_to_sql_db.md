# Write to a MySQL Database with error checking and email alerting on failure

Write to a MySQL Database with error checking and email alerting on
failure

## Usage

``` r
write_to_sql_db(
  conn,
  table_name,
  df_to_write,
  schema,
  overwrite,
  db_name,
  is_log_con = FALSE,
  continue_on_error = FALSE,
  ...
)
```

## Arguments

- conn:

  a DBI database connection

- table_name:

  name of the table to write to

- df_to_write:

  data frame we will write to \_table_name\_

- schema:

  database we will write to

- overwrite:

  a logical that controls whether we will overwrite the table

- db_name:

  the name of the database written to

- is_log_con:

  if FALSE then log failures, if TRUE then do not attempt to log errors

- continue_on_error:

  if TRUE then continue execution on error, if FALSE then quit non
  interactive sessions on error

- ...:

  Additional parameters that will be passed to DBI::dbWriteTable

## Value

No value is returned

## Examples

``` r
if (FALSE) { # \dontrun{
write_to_sql_db(
  conn = con,
  table_name = "my_table",
  df_to_write = rule_output,
  schema = Sys.getenv("ETL_DB_SCHEMA"),
  overwrite = FALSE,
  db_name = Sys.getenv("ETL_DB_NAME"),
  append = TRUE
)
} # }
```
