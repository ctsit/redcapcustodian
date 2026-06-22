# get_project_life_cycle

get_project_life_cycle runs speedy queries against the REDCap log event
tables to get all of the events in the life cycle of every project on
the system.

## Usage

``` r
get_project_life_cycle(
  rc_conn,
  start_date = as.Date(NA),
  cache_file = NA_character_,
  read_cache = TRUE
)
```

## Arguments

- rc_conn:

  \- a DBI connection to a REDCap database

- start_date:

  \- an optional minimum date for query results

- cache_file:

  \- an optional path to the cache_file. Defaults to NA.

- read_cache:

  \- a boolean to indicate if the cache should be read. Defaults to TRUE

## Value

\- a dataframe of redcap_log_event rows with these added columns:

- \`log_event_table\` an index for the event table read

- \`event_date\` a date object for the event

- \`description_base_name\` The description with project or report level
  details removed

## Details

The redcap_log_event table is among the largest redcap tables. In the
test instance where this script was developed, it had 2.2m rows The
production system had 29m rows in the corresponding redcap_data table. A
row count in the millions is completely normal.

The fastest way to query is to query for \`object_type ==
"redcap_projects"\`. What's more, this query can then be filtered by
\`ts \>= start_date“ to make it even faster and to allow incremental
queries. This comes at a small cost because these descriptions are not
included when searching for \`object_type == "redcap_projects"\`:

- Create project (API)

- Create project folder

- Delete project bookmark

- Send request to copy project

- Send request to create project

- Send request to delete project

- Send request to move project to production status

Among other things, their loss means we cannot tell who requested things
or when they requested it.

Deletion Events Notes

Every project deletion is composed of multiple events. The simplest
event is a deletion by a user followed by a permanent deletion by the
system via a cron job 30 days later. While admins can always do this,
users are only allowed to delete non-production projects. For production
projects, users must submit a request to delete. An admin then deletes
the project. 30 days later the system will permanently delete the
project via a cron job. As a project can be undeleted before the
permanent deletion and/or changes status, the above sequences can have
sub-loops and intermingle.

To address who wanted a project deleted and got it done, one must find
the last "Send request to delete project" or "Delete project" event to
get the username and the "Permanently delete project" event to verify
the deletion. If both a request and a delete event precede the
"Permanently delete project" event, the username on the request should
be consider the deleter. The admin who executed the task is just the
custodian.

## Examples

``` r
if (FALSE) { # \dontrun{
project_life_cycle <- get_project_life_cycle(rc_conn = rc_conn, read_cache = TRUE)
} # }
```
