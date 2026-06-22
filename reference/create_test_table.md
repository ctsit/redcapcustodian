# Create a test table from package schema and data files

Creates tables from files in inst/testdata that match the patterns
\<table_name\>\_schema.sql and \<table_name\>.csv

## Usage

``` r
create_test_table(conn, table_name, data_file = NA_character_, empty = F)
```

## Arguments

- conn:

  A DBI Connection object

- table_name:

  The name of a table used in testing

- data_file:

  The name of a file with alternative contents for \`table_name\`

- empty:

  A boolean to request that the table be created empty

## Value

NA

## Examples

``` r
if (FALSE) { # \dontrun{
conn <- dbConnect(RSQLite::SQLite(), dbname = ":memory:")
create_test_table(conn, "redcap_user_information")

} # }
```
