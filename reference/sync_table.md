# Write to a MySQL Database using the result of [`dataset_diff`](dataset_diff.md)

Write to a MySQL Database using the result of
[`dataset_diff`](dataset_diff.md)

## Usage

``` r
sync_table(
  conn,
  table_name,
  primary_key,
  data_diff_output,
  insert = F,
  update = T,
  delete = F
)
```

## Arguments

- conn:

  a DBI database connection

- table_name:

  name of the table to write to

- primary_key:

  name of the primary key (or vector of multiple keys) of the table to
  write to

- data_diff_output:

  list of dataframes returned by [`dataset_diff`](dataset_diff.md)

- insert:

  boolean toggle to use the insert dataframe to insert rows in
  `table_name`

- update:

  boolean toggle to use the updates dataframe to update rows in
  `table_name`

- delete:

  boolean toggle to use the delete dataframe to delete rows in
  `table_name`

## Value

a named list with these values:

- insert_n - the number of rows inserted to `table_name`

- update_n - the number of rows updated in `table_name`

- delete_n - the number of rows deleted in `table_name`

## Examples

``` r
if (FALSE) { # \dontrun{
conn <- connect_to_redcap_db()

 ...

diff_output <- dataset_diff(
  source = updates,
  source_pk = "id",
  target = original_table,
  target_pk = "id"
)

sync_table(
  conn = con,
  table_name = table_name,
  primary_key = primary_key,
  data_diff_output = diff_output
)
} # }
```
