library(DBI)
library(duckdb)
library(dplyr)
library(lubridate)
library(testthat)

# Create SQL tables
redcap_projects <- data.frame(
  project_id = 1:6,
  date_deleted = c(rep(NA, 5), format(Sys.time() - 86400, "%Y-%m-%d %H:%M:%S")),
  log_event_table = c(rep("redcap_log_event1", 3), rep("redcap_log_event2", 3))
)

redcap_log_event1 <- data.frame(
  log_event_id = NA_integer_,
  project_id = NA_integer_,
  ts = NA_character_,
  user = NA_character_,
  ip = NA_character_,
  page = NA_character_,
  event = NA_character_,
  object_type = NA_character_,
  sql_log = NA_character_,
  pk = NA_character_,
  event_id = NA_character_,
  data_values = NA_character_,
  description = NA_character_,
  legacy = NA_integer_,
  change_reason = NA_character_
)

redcap_log_event2 <- redcap_log_event1

# Write SQL tables
conn <- DBI::dbConnect(duckdb::duckdb(), dbname = ":memory:")
DBI::dbWriteTable(conn, "redcap_projects", redcap_projects)
DBI::dbWriteTable(conn, "redcap_log_event1", redcap_log_event1)
DBI::dbWriteTable(conn, "redcap_log_event2", redcap_log_event2)

current_ts <- format(Sys.time(), "%Y%m%d%H%M%S")

# Expected results
expected_redcap_projects <- redcap_projects |>
  mutate(
    date_deleted = if_else(is.na(date_deleted), as.character(as.Date(Sys.time())), date_deleted)
  )

expected_redcap_log_event1 <- data.frame(
  log_event_id = NA_integer_,
  project_id = c(NA, 1:3),
  ts = c(NA, rep(current_ts, 3)),
  user = c(NA, rep("admin", 3)),
  ip = c(NA, rep(getip::getip("local"), 3)),
  page = c(NA, rep("rcc.billing::delete_abandoned_projects", 3)),
  event = c(NA, rep("MANAGE", 3)),
  object_type = c(NA, rep("redcap_projects", 3)),
  sql_log = c(NA, rep("UPDATE redcap_projects SET date_deleted = NOW() WHERE project_id IN (1,2,3,4,5)", 3)),
  pk = c(NA, as.character(1:3)),
  event_id = NA_character_,
  data_values = c(NA, sprintf("project_id = %d", 1:3)),
  description = c(NA, rep("Delete project", 3)),
  legacy = c(NA, rep(0, 3)),
  change_reason = NA_character_
)

expected_redcap_log_event2 <- data.frame(
  log_event_id = NA_integer_,
  project_id = c(NA, 4, 5),
  ts = c(NA, rep(current_ts, 2)),
  user = c(NA, rep("admin", 2)),
  ip = c(NA, rep(getip::getip("local"), 2)),
  page = c(NA, rep("rcc.billing::delete_abandoned_projects", 2)),
  event = c(NA, rep("MANAGE", 2)),
  object_type = c(NA, rep("redcap_projects", 2)),
  sql_log = c(NA, rep("UPDATE redcap_projects SET date_deleted = NOW() WHERE project_id IN (1,2,3,4,5)", 2)),
  pk = c(NA, "4", "5"),
  event_id = NA_character_,
  data_values = c(NA, sprintf("project_id = %d", 4:5)),
  description = c(NA, rep("Delete project", 2)),
  legacy = c(NA, rep(0, 2)),
  change_reason = NA_character_
)

expected_result <- data.frame(
  project_id = 1:8,
  status = c(rep("deleted", 5), "previously deleted", rep("does not exist", 2))
)

# Test function
project_ids <- 1:8
deleted_projects <- delete_project(project_ids, conn)

testthat::test_that("delete_project deletes, updates, and returns the correct project IDs and logs", {
  remove_seconds <- function(ts) {
    if (is.na(ts)) {
      return(NA)
    }
    substr(ts, 1, 12)
  }

  actual_redcap_log_event1 <- DBI::dbGetQuery(conn, "SELECT * FROM redcap_log_event1") |>
    select(-log_event_id) |>
    mutate(
      ts = sapply(ts, remove_seconds)
    )

  expected_redcap_log_event1 <- expected_redcap_log_event1 |>
    select(-log_event_id) |>
    mutate(
      ts = sapply(ts, remove_seconds)
    )

  testthat::expect_equal(actual_redcap_log_event1, expected_redcap_log_event1)

  actual_redcap_log_event2 <- DBI::dbGetQuery(conn, "SELECT * FROM redcap_log_event2") |>
    select(-log_event_id) |>
    mutate(
      ts = sapply(ts, remove_seconds)
    )

  expected_redcap_log_event2 <- expected_redcap_log_event2 |>
    select(-log_event_id) |>
    mutate(
      ts = sapply(ts, remove_seconds)
    )

  testthat::expect_equal(actual_redcap_log_event2, expected_redcap_log_event2)

  testthat::expect_equal(deleted_projects$n, 5)
  testthat::expect_equal(deleted_projects$number_rows_logged, 5)
  testthat::expect_equal(deleted_projects$project_ids_deleted, 1:5)
  testthat::expect_equal(deleted_projects$data, expected_result)
})

DBI::dbDisconnect(conn, shutdown = TRUE)
