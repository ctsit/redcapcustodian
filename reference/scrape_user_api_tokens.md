# Gather all API tokens on a specified REDCap server for a given user

Gather all API tokens on a specified REDCap server for a given user

## Usage

``` r
scrape_user_api_tokens(conn, username_to_scrape = Sys.info()[["user"]])
```

## Arguments

- conn:

  a DBI database connection to a REDCap instance, such as that from
  [`get_redcap_db_connection`](get_redcap_db_connection.md)

- username_to_scrape:

  a REDCap username, defaults to your system's username

## Value

A dataframe of all tokens assigned to the user containing the following:

- project_id - The project ID in REDCap (0 if super token)

- username - The username from REDCap

- token - The API token associated with the project ID

- project_display_name - The name of the project as it appears in the
  REDCap GUI

## Examples

``` r
if (FALSE) { # \dontrun{
  conn <- get_redcap_db_connection()
  my_credentials <- scrape_user_api_tokens(conn, "admin")

} # }
```
