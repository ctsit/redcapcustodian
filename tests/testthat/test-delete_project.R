# create SQL tables
redcap_projects <- data.frame(
  project_id = 1:6,
  date_deleted = c(rep(NA, 5), format(Sys.time() - 86400, "%Y-%m-%d %H:%M:%S")),
  log_event_table = c(rep('redcap_log_event1', 3), rep('redcap_log_event2', 3))
)

redcap_log_event1 <- data.frame(
  object_type = NA_character_,
  event = NA_character_,
  project_id = NA_integer_,
  description = NA_character_
)

redcap_log_event2 <- data.frame(
  object_type = NA_character_,
  event = NA_character_,
  project_id = NA_integer_,
  description = NA_character_
)

# write SQL tables
conn <- DBI::dbConnect(duckdb::duckdb(), dbname = ":memory:")
DBI::dbWriteTable(conn, "redcap_projects", redcap_projects)
DBI::dbWriteTable(conn, "redcap_log_event1", redcap_log_event1)
DBI::dbWriteTable(conn, "redcap_log_event2", redcap_log_event2)

# create comparison dfs
expected_redcap_projects <- data.frame(
  project_id = 1:6,
  # convert to UTC to prevent test from failing due to timezone differences
  date_deleted = c(rep(as.Date(lubridate::with_tz(Sys.time(), "UTC")), 5), Sys.Date() - 1),
  log_event_table = c(rep('redcap_log_event1', 3), rep('redcap_log_event2', 3))
)

expected_redcap_log_event1 <- data.frame(
  object_type = c(NA, rep("redcap_projects", 3)),
  event = c(NA, rep("MANAGE", 3)),
  project_id = c(NA, 1:3),
  description =  c(NA, rep("delete project", 3))
)

expected_redcap_log_event2 <- data.frame(
  object_type = c(NA, rep("redcap_projects", 2)),
  event = c(NA, rep("MANAGE", 2)),
  project_id =  c(NA, 4:5),
  description = c(NA, rep("delete project", 2))
)

expected_result <- data.frame(
  project_id = 1:8,
  status = c(rep("deleted", 5), "previously deleted", rep("does not exist", 2))
)

# test function
project_ids <- 1:8
deleted_projects <- delete_project(project_ids, conn)

testthat::test_that("delete_project deletes, updates and returns the correct project IDs", {
  expect_equal(
    DBI::dbGetQuery(conn, "select * from redcap_projects") |>
      # convert date_deleted to yyyy-mm-dd to allow comparison with expected_redcap_projects
      dplyr::mutate(date_deleted = as.Date(date_deleted)),
    expected_redcap_projects
  )

  testthat::expect_equal(
    DBI::dbGetQuery(conn, "select * from redcap_log_event1"),
    expected_redcap_log_event1
  )
  testthat::expect_equal(
    DBI::dbGetQuery(conn, "select * from redcap_log_event2"),
    expected_redcap_log_event2
  )

  testthat::expect_equal(deleted_projects$n, 5)

  testthat::expect_equal(deleted_projects$number_rows_logged, 5)

  testthat::expect_equal(deleted_projects$project_ids_deleted, 1:5)

  testthat::expect_equal(deleted_projects$data, expected_result)

})

DBI::dbDisconnect(conn, shutdown = TRUE)
