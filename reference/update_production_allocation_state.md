# update_production_allocation_state

Update producition rows in the redcap_randomization_allocation table to
mirror those in another project.

## Usage

``` r
update_production_allocation_state(
  source_conn,
  target_conn,
  source_project_id,
  target_rid
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

- target_rid:

  \- The randomization id of the REDCap project that will receive the
  updated randomization data.

## Value

\- The list output of sync_table_2 from the update of the randomization
allocation table.

## Examples

``` r
if (FALSE) { # \dontrun{
target_project_allocation_update <- update_production_allocation_state(
  source_conn = source_conn,
  target_conn = target_conn,
  source_project_id = source_project_id,
  target_rid = target_project_randomization_state$rid
)
} # }
```
