test_that("write_to_sql_db returns the identical data frame that is written", {
    drv <- RSQLite::SQLite()
    conn <- connect_to_db(drv)
    table_name <- "sample_data"
    df <- tibble::tribble(
        ~colA, ~colB,
        "a", 1,
        "b", 2,
        "c", 3
    )

    write_to_sql_db(
        conn = conn,
        table_name = table_name,
        df_to_write = df,
        db_name = ":memory",
        overwrite = TRUE
    )

    result <- DBI::dbGetQuery(conn, paste("SELECT * FROM", table_name))
    expect_equal(tibble::as_tibble(result), df)
    DBI::dbDisconnect(conn)
})

test_that("on error, write_to_sql_db does not log a failure when continue_on_error = TRUE", {
    skip_if(interactive())
    drv <- RSQLite::SQLite()

    init_etl("write_to_sql_db - log failure", log_db_drv = drv)
    log_con <- get_package_scope_var("log_con")
    con <- connect_to_db(drv)
    table_name <- "sample_data"

    write_to_sql_db(
        conn = con,
        table_name = table_name,
        df_to_write = NULL, # pass invalid reference for df_to_write
        db_name = ":memory",
        overwrite = TRUE,
        continue_on_error = TRUE
    )

    result <- tryCatch(
        expr = {
            # This will fail because the table does not exist.
            # The rcc_job_log table was never created because an error entry was never written to
            DBI::dbGetQuery(
                log_con,
                "SELECT * FROM rcc_job_log WHERE level = 'ERROR'"
            )
        },
        error = function(error) {
            print(error)
            return(FALSE)
        }
    )
    DBI::dbDisconnect(log_con)
    DBI::dbDisconnect(con)
    expect_false(result)
})

test_that("on error, write_to_sql_db does log a failure when continue_on_error = FALSE and is_log_con = FALSE", {
    skip_if(interactive())

    disable_non_interactive_quit()
    drv <- RSQLite::SQLite()

    init_etl("write_to_sql_db - log failure", log_db_drv = drv)
    log_con <- get_package_scope_var("log_con")
    con <- connect_to_db(drv)
    table_name <- "sample_data"

    write_to_sql_db(
        conn = con,
        table_name = table_name,
        df_to_write = NULL, # pass invalid reference for df_to_write
        db_name = ":memory",
        overwrite = TRUE,
        continue_on_error = FALSE,
        is_log_con = FALSE
    )

    result <- tryCatch(
        expr = {
            DBI::dbGetQuery(
                log_con,
                "SELECT * FROM rcc_job_log WHERE level = 'ERROR'"
            )
        },
        error = function(error) {
            print(error)
            return(FALSE)
        }
    )
    DBI::dbDisconnect(log_con)
    DBI::dbDisconnect(con)
    expect_equal(result$level, "ERROR")
})

test_that("on error, write_to_sql_db does not log a failure when continue_on_error = FALSE and is_log_con = TRUE", {
    skip_if(interactive())
    disable_non_interactive_quit()

    drv <- RSQLite::SQLite()

    init_etl("write_to_sql_db - log failure", log_db_drv = drv)
    log_con <- get_package_scope_var("log_con")
    con <- connect_to_db(drv)
    table_name <- "sample_data"

    write_to_sql_db(
        conn = con,
        table_name = table_name,
        df_to_write = NULL, # pass invalid reference for df_to_write
        db_name = ":memory",
        overwrite = TRUE,
        continue_on_error = FALSE,
        is_log_con = TRUE
    )

    result <- tryCatch(
        expr = {
            # This will fail because the table does not exist.
            # The rcc_job_log table was never created because an error entry was never written to
            DBI::dbGetQuery(
                log_con,
                "SELECT * FROM rcc_job_log WHERE level = 'ERROR'"
            )
        },
        error = function(error) {
            print(error)
            return(FALSE)
        }
    )
    DBI::dbDisconnect(log_con)
    DBI::dbDisconnect(con)
    expect_false(result)
})

testthat::test_that(
  "sync_table can do an update",
  {

    df = dataset_diff_test_user_data

    # Set up target table
    drv <- RSQLite::SQLite()
    con <- connect_to_db(drv)
    table_name <- "target"

    DBI::dbWriteTable(
      conn = con,
      name = table_name,
      value = df$target,
      schema = table_name,
      overwrite = T
    )

    # determine what we want to update
    diff_output <- dataset_diff(
      source = df$source,
      source_pk = df$source_pk,
      target = df$target,
      target_pk = df$target_pk
    )

    # update the data
    sync_table(
      conn = con,
      table_name = table_name,
      primary_key = df$target_pk,
      data_diff_output = diff_output
    )

    # test that the target was updated
    testthat::expect_true(dplyr::all_equal(tbl(con, "target") %>% dplyr::collect(), sync_table_test_user_data_result))
  }
)

testthat::test_that(
  "sync_table_2 can do an update",
  {

    df = dataset_diff_test_user_data

    # Set up target table
    drv <- RSQLite::SQLite()
    con <- connect_to_db(drv)
    table_name <- "target"

    DBI::dbWriteTable(
      conn = con,
      name = table_name,
      value = df$target,
      schema = table_name,
      overwrite = T
    )

    # update the data
    result <- sync_table_2(
      conn = con,
      table_name = table_name,
      source = df$source,
      source_pk = df$source_pk,
      target = df$target,
      target_pk = df$target_pk
    )

    # test that the target was updated
    testthat::expect_true(dplyr::all_equal(tbl(con, "target") %>% dplyr::collect(), sync_table_test_user_data_result))
    # test that the number of rows updated matches record count of the update dataframe
    testthat::expect_equal(nrow(result$update_records), result$update_n)
  }
)
