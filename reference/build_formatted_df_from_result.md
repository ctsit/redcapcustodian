# Builds formatted data frame from source data

Builds formatted data frame from source data

## Usage

``` r
build_formatted_df_from_result(
  result,
  database_written,
  table_written,
  log_level,
  pk_col
)
```

## Arguments

- result, :

  the df to log

- database_written, :

  the database the etl wrote to

- table_written, :

  the table the etl wrote to

- log_level, :

  the log level (DEBUG, ERROR, INFO)

- pk_col, :

  the dataframe col to use as the primary_key

## Value

df_etl_log, the df matching the etl_log table

## Examples

``` r
if (FALSE) { # \dontrun{
 build_formatted_df_from_result(
   result,
   database_written,
   table_written,
   log_level,
   pk_col
 )
} # }
```
