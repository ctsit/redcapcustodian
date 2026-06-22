# evaluate_checksums

Transform the output of \`get_table_checksum()\` from a source and
target copy of a MySQL database copy operation and compare the
checksums.

## Usage

``` r
evaluate_checksums(source_checksums, target_checksums)
```

## Arguments

- source_checksums:

  The output of \`get_table_checksum()\` for the source MySQL database
  of a database copy operation

- target_checksums:

  The output of \`get_table_checksum()\` for the target MySQL database
  of a database copy operation

## Value

A dataframe with these columns:

- table:

  MySQL table name

- checksum_source:

  checksum of source table returned by "CHECKSUM TABLE \<table_name\>"

- checksum_target:

  checksum of target table returned by "CHECKSUM TABLE \<table_name\>"

- elapsed_time_source:

  elapsed time required for the query and fetch of the checksum of the
  source table

- elapsed_time_target:

  elapsed time required for the query and fetch of the checksum of the
  target table

- matches:

  a boolean indicating if the source and target checksums match

## Examples

``` r
if (FALSE) { # \dontrun{
evaluate_checksums(source_checksums, target_checksums)
} # }
```
