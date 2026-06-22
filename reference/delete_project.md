# Delete a Project from REDCap

Deletes specified projects from the REDCap system by setting the
\`date_deleted\` field. It will also log the event in the appropriate
\`log_event_table\` for each project.

## Usage

``` r
delete_project(project_id, conn)
```

## Arguments

- project_id:

  A project ID or vector of project IDs to be deleted.

- conn:

  A DBI connection object to the database that holds the
  \`redcap_projects\` and \`redcap_log_event\*\` tables.

## Value

A list containing:

- n: the number of projects deleted

- number_rows_logged: the number of rows logged for the deletion event

- project_ids_deleted: a vector of project IDs that were deleted

- data: a data frame with each input project_id and its status after
  trying to delete it

## Examples

``` r
if (FALSE) { # \dontrun{
conn <- DBI::dbConnect(...)
delete_project(c(1, 2, 3), conn)
} # }
```
