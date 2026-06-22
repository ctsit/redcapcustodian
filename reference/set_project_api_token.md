# Generate an API token for a REDCap project and assign it to a specified user

Generate an API token for a REDCap project and assign it to a specified
user

## Usage

``` r
set_project_api_token(conn, username, project_id)
```

## Arguments

- conn:

  a DBI database connection, such as that from
  [`get_redcap_db_connection`](get_redcap_db_connection.md)

- username:

  a REDCap username  
  This user must already have access to the project, i.e. they must
  appear in the project's User Rights

- project_id:

  The project id of the project for which you wish to generate a token

## Value

nothing

## Examples

``` r
if (FALSE) { # \dontrun{
  conn <- get_redcap_db_connection()
  my_new_token <- set_project_api_token(conn, "admin", 15)
} # }
```
