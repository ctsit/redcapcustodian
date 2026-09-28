# get_project_creations

get_project_creations runs speedy queries against the REDCap log event
tables to get every project-creation event on the system.

## Usage

``` r
get_project_creations(
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

- \`description_base_name\` The description with project-level details
  removed

## Details

The redcap_log_event table is among the largest redcap tables. In the
test instance where this script was developed, it had 2.2m rows The
production system had 29m rows in the corresponding redcap_data table. A
row count in the millions is completely normal.

redcap_log_event2 and higher have the page_project key that indexes by
project_id and page. That allows a speedy query of page ==
"ProjectGeneral/create_project.php" to narrow the scope of the query to
project-creation events only. That index can be added to the
redcap_log_event table to allow a speedy query on it there as well.

What's more, this query can then be filtered by \`ts \>= start_date\` to
make it even faster and to allow incremental queries.

Because it filters on \`page\`, this query does not capture project
creation via the REDCap API: API-driven creation ("Create project
(API)") does not hit \`ProjectGeneral/create_project.php\` and so is not
returned here. Use \`get_project_life_cycle()\` if you need those events
too.

## Examples

``` r
if (FALSE) { # \dontrun{
project_creations <- get_project_creations(rc_conn = rc_conn, read_cache = TRUE)
} # }
```
