# Write to a MySQL Database based on the diff of source and target datasets.

Write to a MySQL Database based on the diff of source and target
datasets.

## Usage

``` r
sync_table_2(
  conn,
  table_name,
  source,
  source_pk,
  target,
  target_pk,
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

- source:

  \- a dataframe with content that needs to be reflected in target

- source_pk:

  \- the primary key of source

- target:

  \- a data frame that needs to reflect source

- target_pk:

  \- the primary key of target

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

- insert_records - a dataframe of inserts

- update_records - a dataframe of updates

- delete_records - a dataframe of deletions

- insert_n - the number of rows inserted to `table_name`

- update_n - the number of rows updated in `table_name`

- delete_n - the number of rows deleted in `table_name`

## Examples

``` r
if (FALSE) { # \dontrun{
conn <- connect_to_redcap_db()

 ...

sync_table_2(
  conn = con,
  table_name = table_name,
  source = updates,
  source_pk = "id",
  target = original_table,
  target_pk = "id"
)
} # }
```
