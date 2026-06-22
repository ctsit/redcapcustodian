# export_allocation_tables_from_project

Export randomization allocation data for a project from the REDCap
randomization tables but in a form that reflects the allocation tables
REDCap requests for import

## Usage

``` r
export_allocation_tables_from_project(conn, project_id_to_export)
```

## Arguments

- conn:

  \- a DBI connection object pointing at a REDCap database that houses
  the project on interest

- project_id_to_export:

  \- The project ID of a REDCap project that contains randomization to
  be exported.

## Value

a dataframe in the shape of REDCap randomization table CSVs

## Examples

``` r
if (FALSE) { # \dontrun{
allocations <- export_allocation_tables_from_project(
  conn = source_conn,
  project_id_to_export = source_project_id
)
} # }
```
