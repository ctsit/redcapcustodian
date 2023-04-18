testthat::test_that("get_project_life_cycle caches and returns event_date, log_event_table, and description", {
  set_script_run_time()
  # build test tables in memory
  # t_conn <- DBI::dbConnect(duckdb::duckdb(), dbdir = ":memory:")
  t_conn <- DBI::dbConnect(RSQLite::SQLite(), dbname = ":memory:")

  purrr::walk(
    redcapcustodian::log_event_tables,
    create_a_table_from_rds_test_data,
    t_conn,
    "project_life_cycle"
  )

  # check that tables were created
  DBI::dbListTables(t_conn)

  cache_file <- tempfile()

  result <- get_project_life_cycle(
    rc_conn = t_conn,
    cache_file = cache_file,
    read_cache = F
  )

  cached_result <- get_project_life_cycle(
    rc_conn = t_conn,
    cache_file = cache_file,
    read_cache = T
  )

  testthat::expect_true(dplyr::all_equal(result, cached_result))
  testthat::expect_equal("Date", class(result$event_date))
  testthat::expect_equal(
    result$log_event_table %in% seq(1:9),
    rep(TRUE, length(result$log_event_table))
  )
  testthat::expect_equal(
    result$description %in% redcapcustodian::project_life_cycle_descriptions,
    rep(TRUE, length(result$log_event_table))
  )
})
