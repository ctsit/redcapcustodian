# A template function for fetching authoritative email address data and other institutional data

A template function for fetching authoritative email address data and
other institutional data

## Usage

``` r
get_institutional_person_data(user_ids = c(NA_character_))
```

## Arguments

- user_ids:

  a optional vector of REDCap user IDs to be used in a query against the
  institutional data

## Value

A Dataframe

- user_id - a column of redcap user_ids / institutional IDs

- email - a column of with the authoritative email address for user_id

- ... - Additional columns are allowed in the return data frame

## Examples

``` r
redcap_users <- c("jane_doe", "john_q_public")
get_institutional_person_data(user_ids = redcap_users)
#> # A tibble: 2 × 2
#>   user_id       email                    
#>   <chr>         <chr>                    
#> 1 jane_doe      jane_doe@example.org     
#> 2 john_q_public john_q_public@example.org
```
