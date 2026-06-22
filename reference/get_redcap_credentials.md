# Retrieve REDCap Credentials Based on Specified Parameters

Fetches REDCap credentials from the CREDENTIALS_DB, allowing filtering
based on project ID, server short name, project short name, and
username. At least one filtering criterion must be provided.

## Usage

``` r
get_redcap_credentials(
  project_pid = NA,
  server_short_name = NA,
  project_short_name = NA,
  username = NA
)
```

## Arguments

- project_pid:

  Optional project ID for filtering.

- server_short_name:

  Optional server short name for filtering.

- project_short_name:

  Optional project short name for filtering.

- username:

  Optional username for filtering.

## Value

A dataframe of filtered REDCap credentials, including a 'url' column
added for convenience.

## Examples

``` r
if (FALSE) { # \dontrun{
  source_credentials <- get_redcap_credentials(project_pid = "123")
  prod_credentials <- get_redcap_credentials(server_short_name = "prod")
  target_credentials <- prod_credentials |>
    filter(str_detect(project_name, "biospecimens"))
} # }
```
