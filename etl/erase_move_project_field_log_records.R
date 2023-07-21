library(tidyverse)
library(lubridate)
library(dotenv)
library(redcapcustodian) # devtools::install_github("ctsit/redcapcustodian")
library(DBI)
library(RMariaDB)

script_name <- "erase_move_project_field_log_records"

connect_to_redcap_with_schema <- function(schema = NULL) {
  if (is.null(schema)) {
    schema <- Sys.getenv("REDCAP_DB_NAME")
  }

  if (Sys.getenv("REDCAP_DB_PORT") == "") {
    port <- "3306"
  } else {
    port <- Sys.getenv("REDCAP_DB_PORT")
  }
  conn <- DBI::dbConnect(
    RMariaDB::MariaDB(),
    dbname = schema,
    host = Sys.getenv("REDCAP_DB_HOST"),
    user = Sys.getenv("REDCAP_DB_USER"),
    password = Sys.getenv("REDCAP_DB_PASSWORD"),
    port = port
  )
}

# Get the stats of the log_event_table
is_conn <- connect_to_redcap_with_schema(schema = "INFORMATION_SCHEMA")
log_table_data <- tbl(is_conn, "TABLES") %>%
  filter(TABLE_NAME %in% !!redcapcustodian::log_event_tables) %>%
  collect() %>%
  janitor::clean_names() %>%
  select(
    log_event_table = table_name,
    log_event_data_length = data_length
  )

measure_move_project_fields_in_one_project <- function(project_id, log_event_table, conn) {
  sql <- paste(
    "select project_id, sum(length(sql_log)) as sql_log_size, count(*) as n from",
    log_event_table,
    "where project_id =",
    project_id,
    "and description = 'Move project field'"
  )
  start <- Sys.time()
  query_result <- DBI::dbGetQuery(conn, sql)
  end <- Sys.time()

  result <-
    query_result %>%
    mutate(
      log_event_table = log_event_table,
      elapsed_time_to_query = round(end - start)
    ) %>%
    rename(rows = n)

  return(result)
}

delete_move_project_fields_in_one_project <- function(project_id, log_event_table, conn) {
  sql <- paste(
    "delete from",
    log_event_table,
    "where project_id =",
    project_id,
    "and description = 'Move project field'"
  )
  start <- Sys.time()
  rows_deleted <- DBI::dbExecute(conn, sql)
  end <- Sys.time()

  result <-
    tibble(rows_deleted) %>%
    mutate(
      project_id = project_id,
      elapsed_time_to_delete = round(end - start)
    ) %>%
    select(-rows_deleted, everything(), rows_deleted)

  return(result)
}

rc_conn <- connect_to_redcap_db()
redcap_projects <-
  tbl(rc_conn, "redcap_projects") %>%
  select(project_id, log_event_table) %>%
  collect()

# measure the projects of interest
size_by_project <- map2_dfr(
  redcap_projects$project_id,
  redcap_projects$log_event_table,
  measure_move_project_fields_in_one_project,
  rc_conn
)

projects_to_clean <- size_by_project %>%
  filter(rows > 0) %>%
  left_join(log_table_data, by = "log_event_table")

deletions <- map2_dfr(
  projects_to_clean$project_id,
  projects_to_clean$log_event_table,
  delete_move_project_fields_in_one_project,
  rc_conn
) %>%
  left_join(projects_to_clean, by = "project_id") %>%
  select(
    project_id,
    log_event_table,
    rows,
    rows_deleted,
    sql_log_size,
    log_event_data_length,
    elapsed_time_to_query,
    elapsed_time_to_delete
  ) %>%
  mutate(across(starts_with("elapsed"), as.numeric))

activity_log <- lst(
  deletions
)

log_job_success(jsonlite::toJSON(activity_log))

dbDisconnect(rc_conn)
dbDisconnect(is_conn)
