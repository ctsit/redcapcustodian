# write_allocations

Write the development or production randomization allocation table in
the same form in which it was loaded.

## Usage

``` r
write_allocations(project_status_to_write, allocations, target_directory = ".")
```

## Arguments

- project_status_to_write:

  \- the value of project_status to export. Use 0 for development. Use 1
  for Production

- allocations:

  \- the dataframe of randomization allocation data as exported by
  \`export_allocation_tables_from_project\`

- target_directory:

  \- the directory into which the function should write the files

## Value

the full path to the allocations file

## Examples

``` r
if (FALSE) { # \dontrun{
# get and print importable allocations if we need them for reference
allocations <- export_allocation_tables_from_project(
  conn = source_conn,
  project_id_to_export = source_project_id
)

# write both files
walk(c(0,1), write_allocations, allocations, "output")
} # }
```
