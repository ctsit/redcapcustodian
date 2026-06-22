# enable_randomization_on_a_preconfigured_project_in_production

Turn on randomization in the target project but only if it has already
been moved to production and randomization has been configured.

## Usage

``` r
enable_randomization_on_a_preconfigured_project_in_production(
  target_conn,
  target_project_id
)
```

## Arguments

- target_conn:

  \- a DBI connection object pointing at the REDCap database that houses
  the target project.

- target_project_id:

  \- The project ID of the REDCap project that will receive the mirrored
  randomization data.

## Value

A logical indicating success or failure of the operation

## Examples

``` r
if (FALSE) { # \dontrun{
enable_randomization_on_a_preconfigured_project_in_production(
  target_conn = target_conn,
  target_project_id = target_project_id
)
} # }
```
