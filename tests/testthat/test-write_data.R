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

# test failures behave as expected
