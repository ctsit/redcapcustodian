conn <- dbConnect(RSQLite::SQLite(), dbname = ":memory:")

create_test_tables(conn)

# HACK: create rsm table just for these tests
schema_file <- system.file("schema", "redcap_summary_metrics.sql", package = "redcapcustodian")
schema <- convert_schema_to_sqlite(schema_file)
# close result set to avoid warning
res <- DBI::dbSendQuery(conn, schema)
DBI::dbClearResult(res)

test_that("write_summary_metrics writes summary metrics", {

  # HACK: stand in for running init_etl
  set_package_scope_var("log_con", conn)
  set_script_run_time()
  set_script_name("test-summary_metrics")

  start_of_this_month <- floor_date(get_script_run_time(), "month")
  start_of_previous_month <- floor_date(start_of_this_month - months(1), "month")

  users <- tbl(conn, "redcap_user_information") %>%
    filter(is.na(user_suspended_time)) %>%
    select(username, user_lastactivity) %>%
    collect() %>%
    nrow()

  users_active <- tbl(conn, "redcap_user_information") %>%
    filter(is.na(user_suspended_time)) %>%
    select(username, user_lastactivity) %>%
    collect() %>%
    ## force_tz does not work with a sqlite db
    ## mutate(user_lastactivity = force_tz(user_lastactivity, Sys.getenv("TIME_ZONE"))) %>%
    filter(user_lastactivity >= start_of_previous_month & user_lastactivity <= start_of_this_month) %>%
    nrow()

  metric_dataframe <-
    dplyr::tribble(
      ~users, ~users_active,
      users, users_active
  )

  reporting_period_start <- start_of_previous_month
  reporting_period_end <- start_of_this_month
  metric_type <- "state"

  write_summary_metrics(
    reporting_period_start = ymd_hms("2022-01-01 00:00:00"),
    reporting_period_end = ymd_hms("2022-01-31 23:59:59"),
    metric_type = "state",
    metric_dataframe = metric_dataframe
  )

  summary_metrics_table <- tbl(conn, "redcap_summary_metrics") %>%
    collect() %>%
    # HACK: in-memory data for dates get converted to int
    mutate_columns_to_posixct(c("script_run_time", "reporting_period_start", "reporting_period_end"))

  # NOTE: type coercion needed as redcap_summary_metrics value column is varchar
  expect_equal(
    as.character(users),
    summary_metrics_table %>%
      filter(key == "users") %>%
      arrange(desc(script_run_time)) %>%
      head(1) %>%
      pull(value)
  )

  expect_equal(
    as.character(users_active),
    summary_metrics_table %>%
      filter(key == "users_active") %>%
      arrange(desc(script_run_time)) %>%
      head(1) %>%
      pull(value)
  )
})

DBI::dbDisconnect(conn)
