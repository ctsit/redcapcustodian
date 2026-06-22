# A wrapper around [`create_test_table`](create_test_table.md) to create all tables, or a specified subset of them

A wrapper around [`create_test_table`](create_test_table.md) to create
all tables, or a specified subset of them

## Usage

``` r
create_test_tables(conn, table_names = c())
```

## Arguments

- conn:

  A DBI Connection object

- table_names:

  A character list of the names of all tables you wish to create, if
  nothing is provided, the result of
  [`get_test_table_names`](get_test_table_names.md) will be used to
  create all test tables

## Value

NA

## Examples

``` r
if (FALSE) { # \dontrun{
conn <- dbConnect(RSQLite::SQLite(), dbname = ":memory:")
create_test_tables(conn) # create all test tables

} # }
```
