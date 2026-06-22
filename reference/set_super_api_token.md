# Generate and set a Super API token for a provided REDCap user

Generate and set a Super API token for a provided REDCap user

## Usage

``` r
set_super_api_token(conn, username)
```

## Arguments

- conn:

  a DBI database connection, such as that from
  [`get_redcap_db_connection`](get_redcap_db_connection.md)

- username:

  a REDCap username

## Value

The newly created super token

## Examples

``` r
if (FALSE) { # \dontrun{
  conn <- get_redcap_db_connection()
  my_new_super_token <- set_super_api_token(conn, "admin")
} # }
```
