# create_allocation_rows

Create rows in the redcap_randomization_allocation table that mirror
those in another project.

## Usage

``` r
create_allocation_rows(
  source_conn,
  target_conn,
  source_project_id,
  target_project_id
)
```

## Arguments

- source_conn:

  \- a DBI connection object pointing at the REDCap database that houses
  the source project.

- target_conn:

  \- a DBI connection object pointing at the REDCap database that houses
  the target project.

- source_project_id:

  \- The project ID of the REDCap project that contains randomization to
  be cloned.

- target_project_id:

  \- The project ID of the REDCap project that will receive the mirrored
  randomization data.

## Value

\- A dataframe containing the current allocation rows for the target
project.

## Examples

``` r
if (FALSE) { # \dontrun{
target_project_allocation_state <- create_allocation_rows(
  source_conn = source_conn,
  target_conn = target_conn,
  source_project_id = source_project_id,
  target_project_id = target_project_id
)
} # }
```
