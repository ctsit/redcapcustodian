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
    drv <- duckdb::duckdb()

    init_etl("write_to_sql_db - log failure", log_db_drv = drv)
    log_con <- get_package_scope_var("log_con")
    con <- connect_to_db(duckdb::duckdb())
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
    DBI::dbDisconnect(log_con, shutdown=TRUE)
    DBI::dbDisconnect(con, shutdown=TRUE)
    expect_false(result)
})

test_that("on error, write_to_sql_db does log a failure when continue_on_error = FALSE and is_log_con = FALSE", {
    skip_if(interactive())

    disable_non_interactive_quit()
    drv <- duckdb::duckdb()

    init_etl("write_to_sql_db - log failure", log_db_drv = drv)
    log_con <- get_package_scope_var("log_con")
    con <- connect_to_db(duckdb::duckdb())
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
    DBI::dbDisconnect(log_con, shutdown=TRUE)
    DBI::dbDisconnect(con, shutdown=TRUE)
    expect_equal(result$level, "ERROR")
})

test_that("on error, write_to_sql_db does not log a failure when continue_on_error = FALSE and is_log_con = TRUE", {
    skip_if(interactive())
    disable_non_interactive_quit()

    drv <- duckdb::duckdb()

    init_etl("write_to_sql_db - log failure", log_db_drv = drv)
    log_con <- get_package_scope_var("log_con")
    con <- connect_to_db(duckdb::duckdb())
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
    DBI::dbDisconnect(log_con, shutdown=TRUE)
    DBI::dbDisconnect(con, shutdown=TRUE)
    expect_false(result)
})

testthat::test_that(
  "sync_table can do an insert/update/delete",
  {
    # make test data
    mtcars_for_db <- mtcars %>%
      dplyr::mutate(model = row.names(mtcars)) %>%
      dplyr::mutate(id = dplyr::row_number()) %>%
      dplyr::select(id, model, dplyr::everything())
    damaged_mtcars_for_db <- mtcars_for_db %>%
      dplyr::filter(id <= 20) %>%
      dplyr::mutate(cyl = dplyr::if_else(id <= 10, 1, cyl)) %>%
      rbind(mtcars_for_db %>% dplyr::sample_n(10) %>% dplyr::mutate(id = id+100))

    # write damaged data to a DB
    conn <- DBI::dbConnect(RSQLite::SQLite(), dbname = ":memory:")
    DBI::dbWriteTable(conn = conn, name = "mtcars", value = damaged_mtcars_for_db)

    # determine what we want to update
    diff_output <- dataset_diff(
      source = mtcars_for_db,
      source_pk = "id",
      target = damaged_mtcars_for_db,
      target_pk = "id"
    )

    # update the data
    result <- sync_table(
      conn = conn,
      table_name = "mtcars",
      primary_key = "id",
      data_diff_output = diff_output,
      insert = T,
      update = T,
      delete = T
    )

    # read the updated table
    mtcars_from_db <- dplyr::tbl(conn, "mtcars") %>%
      dplyr::collect() %>%
      dplyr::mutate(id = as.integer(id))

    # test that the data reads back correctly
    testthat::expect_true(all.equal(dplyr::as_tibble(mtcars_for_db), mtcars_from_db))
  }
)

testthat::test_that(
  "sync_table works when deletion count = 0",
  {
    # make test data
    mtcars_for_db <- mtcars %>%
      dplyr::mutate(model = row.names(mtcars)) %>%
      dplyr::mutate(id = dplyr::row_number()) %>%
      dplyr::select(id, model, dplyr::everything())
    damaged_mtcars_for_db <- mtcars_for_db %>%
      dplyr::filter(id <= 20) %>%
      dplyr::mutate(cyl = dplyr::if_else(id <= 10, 1, cyl))

    # write damaged data to a DB
    conn <- DBI::dbConnect(RSQLite::SQLite(), dbname = ":memory:")
    DBI::dbWriteTable(conn = conn, name = "mtcars", value = damaged_mtcars_for_db)

    # determine what we want to update
    diff_output <- dataset_diff(
      source = mtcars_for_db,
      source_pk = "id",
      target = damaged_mtcars_for_db,
      target_pk = "id"
    )

    # update the data
    result <- sync_table(
      conn = conn,
      table_name = "mtcars",
      primary_key = "id",
      data_diff_output = diff_output,
      insert = T,
      update = T,
      delete = T
    )

    # read the updated table
    mtcars_from_db <- dplyr::tbl(conn, "mtcars") %>%
      dplyr::collect() %>%
      dplyr::mutate(id = as.integer(id))

    # test that the data reads back correctly
    testthat::expect_true(all.equal(dplyr::as_tibble(mtcars_for_db), mtcars_from_db))
  }
)

testthat::test_that(
  "sync_table_2 can do an insert/update/delete",
  {
    # make test data
    mtcars_for_db <- mtcars %>%
      dplyr::mutate(model = row.names(mtcars)) %>%
      dplyr::mutate(id = dplyr::row_number()) %>%
      dplyr::select(id, model, dplyr::everything())
    damaged_mtcars_for_db <- mtcars_for_db %>%
      dplyr::filter(id <= 20) %>%
      dplyr::mutate(cyl = dplyr::if_else(id <= 10, 1, cyl)) %>%
      rbind(mtcars_for_db %>% dplyr::sample_n(10) %>% dplyr::mutate(id = id+100))

    # write damaged data to a DB
    conn <- DBI::dbConnect(RSQLite::SQLite(), dbname = ":memory:")
    DBI::dbWriteTable(conn = conn, name = "mtcars", value = damaged_mtcars_for_db)

    # update the data
    result <- sync_table_2(
      conn = conn,
      table_name = "mtcars",
      source = mtcars_for_db,
      source_pk = "id",
      target = damaged_mtcars_for_db,
      target_pk = "id",
      insert = T,
      update = T,
      delete = T
    )

    # read the updated table
    mtcars_from_db <- dplyr::tbl(conn, "mtcars") %>%
      dplyr::collect() %>%
      dplyr::mutate(id = as.integer(id))

    # test that the data reads back correctly
    testthat::expect_true(all.equal(dplyr::as_tibble(mtcars_for_db), mtcars_from_db))
  }
)

testthat::test_that(
  "sync_table_2 works when deletion count = 0",
  {
    # make test data
    mtcars_for_db <- mtcars %>%
      dplyr::mutate(model = row.names(mtcars)) %>%
      dplyr::mutate(id = dplyr::row_number()) %>%
      dplyr::select(id, model, dplyr::everything())
    damaged_mtcars_for_db <- mtcars_for_db %>%
      dplyr::filter(id <= 20) %>%
      dplyr::mutate(cyl = dplyr::if_else(id <= 10, 1, cyl))

    # write damaged data to a DB
    conn <- DBI::dbConnect(RSQLite::SQLite(), dbname = ":memory:")
    DBI::dbWriteTable(conn = conn, name = "mtcars", value = damaged_mtcars_for_db)

    # update the data
    result <- sync_table_2(
      conn = conn,
      table_name = "mtcars",
      source = mtcars_for_db,
      source_pk = "id",
      target = damaged_mtcars_for_db,
      target_pk = "id",
      insert = T,
      update = T,
      delete = T
    )

    # read the updated table
    mtcars_from_db <- dplyr::tbl(conn, "mtcars") %>%
      dplyr::collect() %>%
      dplyr::mutate(id = as.integer(id))

    # test that the data reads back correctly
    testthat::expect_true(all.equal(dplyr::as_tibble(mtcars_for_db), mtcars_from_db))
  }
)
