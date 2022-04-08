test_that("get_job_duration properly calculates the elapsed time from start time to end time", {
    elapsed_time <- lubridate::dseconds(5)
    start_time <- lubridate::now()
    end_time <- start_time + elapsed_time

    expect_equal(get_job_duration(start_time, end_time), lubridate::time_length(elapsed_time))
})

test_that("get_package_scope_var properly gets vars set by set_package_scope_var", {
    key <- "test-utils-key"
    value <- "hello world"
    set_package_scope_var(key, value)
    retrieved_value <- get_package_scope_var(key)
    expect_equal(retrieved_value, value)
})

test_that("is_db_con returns TRUE for a DBI connection object", {
    conn <- dbConnect(RSQLite::SQLite(), dbname = ":memory:")
    expect_true(is_db_con(conn))
    DBI::dbDisconnect(conn)
})

test_that("is_db_con returns FALSE for a DBI connection object", {
    conn <- "invalid connection"
    expect_false(is_db_con(conn))
})

test_that("is_on_ci returns TRUE when CI is set to FALSE", {
    Sys.setenv(CI = TRUE)
    expect_true(is_on_ci())
})

test_that("is_on_ci returns FALSE when CI is set to FALSE", {
    Sys.setenv(CI = FALSE)
    expect_false(is_on_ci())
})