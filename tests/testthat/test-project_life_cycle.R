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

  approximate_records_to_include <- 5
  start_date <- result %>%
    dplyr::arrange(.data$event_date) %>%
    dplyr::slice_tail(n = approximate_records_to_include) %>%
    dplyr::summarise(start_date = min(.data$event_date)) %>%
    dplyr::pull(start_date)

  records_to_include <- result %>%
    dplyr::arrange(.data$event_date) %>%
    dplyr::filter(start_date <= .data$event_date) %>%
    nrow()

  time_filtered_result <- get_project_life_cycle(
    rc_conn = t_conn,
    start_date = start_date,
    cache_file = cache_file,
    read_cache = F
  )

  testthat::expect_true(all.equal(result, cached_result))
  testthat::expect_equal("Date", class(result$event_date))
  testthat::expect_equal(
    result$log_event_table %in% seq(1:12),
    rep(TRUE, nrow(result))
  )
  testthat::expect_equal(
    result$description_base_name %in% redcapcustodian::project_life_cycle_descriptions,
    rep(TRUE, nrow(result))
  )
  testthat::expect_equal(records_to_include, nrow(time_filtered_result))
})
