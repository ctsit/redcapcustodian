# Get all user emails in redcap_user_information as tall data

Get all user emails in redcap_user_information as tall data

## Usage

``` r
get_redcap_emails(conn)
```

## Arguments

- conn:

  A DBI Connection object

## Value

a list of 2 dataframes:

- wide, relevant email columns from redcap_user_information

- tall, wide data pivoted to include email_field_name and email columns

## Examples

``` r
if (FALSE) { # \dontrun{
conn <- dbConnect(RSQLite::SQLite(), dbname = ":memory:")
create_test_table(conn, "redcap_user_information")
get_redcap_emails(conn)
} # }
```
