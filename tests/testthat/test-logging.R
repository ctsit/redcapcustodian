test_that("log_job_debug writes a debug log entry", {
    script_name <- "test-logging-debug"
    init_etl(script_name, drv = RSQLite::SQLite())
    log_con <- get_package_scope_var("log_con")
    summary <- paste("Writing log for", script_name)

    log_job_debug(summary)
    result <- DBI::dbGetQuery(
        log_con,
        "SELECT * FROM rcc_job_log WHERE level = 'DEBUG'"
    )
    expect_equal(result$job_summary_data, summary)
})

test_that("log_job_failure writes an error log entry", {
    script_name <- "test-logging-failure"
    init_etl(script_name, drv = RSQLite::SQLite())
    log_con <- get_package_scope_var("log_con")
    summary <- paste("Writing log for", script_name)

    log_job_failure(summary)
    result <- DBI::dbGetQuery(
        log_con,
        "SELECT * FROM rcc_job_log WHERE level = 'ERROR'"
    )
    summary_data_json <- rjson::fromJSON(result$job_summary_data)
    expect_equal(summary_data_json$error_message, summary)
})

test_that("log_job_success writes a success log entry", {
    script_name <- "test-logging-success"
    init_etl(script_name, drv = RSQLite::SQLite())
    log_con <- get_package_scope_var("log_con")
    summary <- paste("Writing log for", script_name)

    log_job_success(summary)
    result <- DBI::dbGetQuery(
        log_con,
        "SELECT * FROM rcc_job_log WHERE level = 'SUCCESS'"
    )
    expect_equal(result$job_summary_data, summary)
})
