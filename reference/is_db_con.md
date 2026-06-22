# Check if the provided connection is a DBI connection object

Check if the provided connection is a DBI connection object

## Usage

``` r
is_db_con(con)
```

## Arguments

- con:

  a DBI connection

## Value

The result of the test

## Examples

``` r
if (FALSE) { # \dontrun{
 conn = connect_to_local_db()
 is_db_con(
   con = conn
 )
} # }
```
