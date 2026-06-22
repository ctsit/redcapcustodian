# Expire user rights to REDCap projects

Expire user rights on one or more REDCap projects based on list of users
to expire or users to exclude from expiration

## Usage

``` r
expire_user_project_rights(
  conn,
  project_ids,
  usernames = NULL,
  all_users_except = NULL,
  expiration_date = as.Date(NA)
)
```

## Arguments

- conn, :

  DBI Connection object to a REDCap database

- project_ids, :

  a vector of project IDs whose users need expiration

- usernames, :

  a vector of usernames to expire across the vector of project IDs

- all_users_except, :

  a vector of usernames who will be excluded from expiration

- expiration_date, :

  the expiration date to be applied to the users. Defaults to today.

## Value

a list of the update count and data written

- updates - the number of records revised

- data - the dataframe of changes applied to redcap_user_rights

## Examples

``` r
conn <- DBI::dbConnect(RSQLite::SQLite(), dbname = ":memory:")

DBI::dbCreateTable(
  conn,
  name = "redcap_user_rights",
  fields = user_rights_test_data$redcap_user_rights
)
DBI::dbAppendTable(
  conn,
  name = "redcap_user_rights",
  value = user_rights_test_data$redcap_user_rights
)
#> [1] 27

usernames <- c("bob", "dan")

expire_user_project_rights(
  conn = conn,
  project_ids = c(34),
  usernames = usernames
)
#> $updates
#> [1] 2
#> 
#> $data
#> # A tibble: 2 × 3
#>   project_id username expiration
#>        <int> <chr>    <date>    
#> 1         34 bob      2026-06-22
#> 2         34 dan      2026-06-22
#> 
```
