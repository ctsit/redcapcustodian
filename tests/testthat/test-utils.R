test_that("get_job_duration properly calculates the elapsed time from start time to end time", {
    elapsed_time <- lubridate::dseconds(5)
    start_time <- lubridate::now()
    end_time <- start_time + elapsed_time
    testthat::expect_equal(get_job_duration(start_time, end_time), lubridate::time_length(elapsed_time))
})

test_that("get_package_scope_var properly gets vars set by set_package_scope_var", {
    key <- "test-utils-key"
    value <- "hello world"
    set_package_scope_var(key, value)
    retrieved_value <- get_package_scope_var(key)
    testthat::expect_equal(retrieved_value, value)
})

test_that("is_db_con returns TRUE for a DBI connection object", {
    conn <- DBI::dbConnect(RSQLite::SQLite())
    DBI::dbGetInfo(conn)
    # TODO(mbentz-uf): Add read to check we can read/write
    DBI::dbWriteTable(conn, "mtcars", mtcars)
    testthat::expect_true(is_db_con(conn))
    DBI::dbDisconnect(conn)
})

test_that("is_db_con returns FALSE for a non DBI connection object", {
    conn <- "invalid connection"
    testthat::expect_false(is_db_con(conn))
})

test_that("init_etl properly sets script name, script run time, and initializes log connection", {
    test_script_name <- "test_script"
    test_run_time <- lubridate::now(tz = Sys.getenv("TIME_ZONE"))
    init_etl(script_name = test_script_name, fake_runtime = test_run_time, log_db_drv = RSQLite::SQLite())
    testthat::expect_equal(get_script_name(), test_script_name)
    testthat::expect_equal(get_script_run_time(), test_run_time)
    testthat::expect_true(is_db_con(get_package_scope_var("log_con")))
})

test_that("is_on_ci returns TRUE when CI is set to FALSE", {
  Sys.setenv(CI = TRUE)
  testthat::expect_true(is_on_ci())
})

test_that("is_on_ci returns FALSE when CI is set to FALSE", {
  Sys.setenv(CI = FALSE)
  testthat::expect_false(is_on_ci())
})
