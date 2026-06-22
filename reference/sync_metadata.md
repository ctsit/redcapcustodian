# Sync data dictionary of a source project to a target project using credential objects

Sync data dictionary of a source project to a target project using
credential objects

## Usage

``` r
sync_metadata(
  source_credentials,
  target_credentials,
  strip_action_tags = FALSE
)
```

## Arguments

- source_credentials:

  A dataframe containing the following columns:

  - redcap_uri - The uri for the API endpoint of a REDCap host

  - token - The REDCap API token for a specific project

  This dataframe should contain credentials for the project you wish to
  copy from

- target_credentials:

  A dataframe containing the following columns:

  - redcap_uri - The uri for the API endpoint of a REDCap host

  - token - The REDCap API token for a specific project

  This dataframe should contain credentials for the project you wish to
  overwrite

- strip_action_tags:

  Optional toggle to remove action tags, useful for porting to a
  development environment; defaults to FALSE

## Value

nothing

## See also

[`retrieve_credential`](https://ouhscbbmc.github.io/REDCapR/reference/retrieve_credential.html),
[`scrape_user_api_tokens`](scrape_user_api_tokens.md)
[`vignette("credential-scraping", package = "redcapcustodian")`](../articles/credential-scraping.md)

## Examples

``` r
if (FALSE) { # \dontrun{
  source_credentials <- REDCapR::retrieve_credential_local(
    path_credential = "source_credentials.csv",
    project_id = 31
  )

  target_credentials <- REDCapR::retrieve_credential_local(
    path_credential = "target_credentials.csv",
    project_id = 25
  )

  sync_metadata(source_credentials, target_credentials)
} # }
```
