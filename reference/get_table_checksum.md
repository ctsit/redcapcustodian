# get_table_checksum

Fetch the checksum of a MySQL table accessed via DBI connection object.

## Usage

``` r
get_table_checksum(table_name, conn)
```

## Arguments

- table_name:

  The name of a table in the database described by \`conn\`

- conn:

  A DBI Connection object to a MySQL database

## Value

A one row dataframe with these columns:

- host:

  MySQL host name found on the DBI connection object

- database_name:

  MySQL database name returned by the query

- table:

  MySQL table name

- checksum:

  checksum returned by "CHECKSUM TABLE \<table_name\>"

- elapsed_time:

  elapsed time required for the query and fetch of the checksum

## Examples

``` r
if (FALSE) { # \dontrun{
get_table_checksum("redcap_user_information", rc_conn)
} # }
```
