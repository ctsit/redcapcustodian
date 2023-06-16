conn <- DBI::dbConnect(RSQLite::SQLite(), dbname = ":memory:")

testthat::test_that("get_get_test_table_names() accurately reflects all schema files included in inst", {
  testthat::expect_equal(
    length(
      Sys.glob(paste0(system.file(package = "redcapcustodian"), "/testdata/*_schema.sql"))
    ),
    length(get_test_table_names())
  )
})

create_test_tables(conn)
testthat::test_that("create_test_tables successfully creates all desired tables", {
  testthat::expect_equal(length(DBI::dbListTables(conn)), length(get_test_table_names()))
})

testthat::test_that("create_test_table creates redcap_user_information with the right dimensions", {
  testthat::expect_equal(dim(tbl(conn, "redcap_user_information") %>% collect()), c(6,49))
})

testthat::test_that("create_test_table creates redcap_projects with the right dimensions", {
  testthat::expect_equal(dim(tbl(conn, "redcap_projects") %>% collect()), c(20,142))
})

testthat::test_that("convert_schema_to_sqlite can convert a MySQL schema to valid SQLite syntax", {
  mysql_schema <- "CREATE TABLE `redcap_entity_project_ownership` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `created` int(10) unsigned NOT NULL,
  `updated` int(10) unsigned NOT NULL,
  `pid` int(10) unsigned NOT NULL,
  `username` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `email` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `firstname` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `lastname` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `billable` int(10) unsigned DEFAULT NULL,
  `sequestered` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci"

  tmp_filename <- fs::file_temp()
  write(mysql_schema, tmp_filename)
  result <- convert_schema_to_sqlite(tmp_filename)
  expected_result <- "CREATE TABLE `redcap_entity_project_ownership` (  `id` integer NOT NULL,  `created` integer NOT NULL,  `updated` integer NOT NULL,  `pid` integer NOT NULL,  `username` varchar(255)  DEFAULT NULL,  `email` varchar(255)  DEFAULT NULL,  `firstname` varchar(255)  DEFAULT NULL,  `lastname` varchar(255)  DEFAULT NULL,  `billable` integer DEFAULT NULL,  `sequestered` integer DEFAULT NULL) "
  testthat::expect_equal(result, expected_result)

  sqlite_conn <- DBI::dbConnect(RSQLite::SQLite(), dbname = ":memory:")

  res <- DBI::dbSendQuery(sqlite_conn, result)
  # close result set to avoid warning
  DBI::dbClearResult(res)
  testthat::expect_equal(DBI::dbListTables(sqlite_conn), "redcap_entity_project_ownership")
  DBI::dbDisconnect(sqlite_conn)
})

testthat::test_that("copy_entire_table_to_db works", {

  # Build the objects need for testing
  test_data <- dplyr::tribble(
    ~a, ~b, ~c, ~d,
    "asdf", 1, TRUE, lubridate::ymd_hms("2023-01-14 12:34:56"),
    "qwer", 2, FALSE, lubridate::ymd_hms("2016-01-14 12:34:56")
  )
  table_name <- "test_data"
  source_conn <- DBI::dbConnect(duckdb::duckdb(), dbdir = ":memory:")
  DBI::dbWriteTable(conn = source_conn, name = table_name, value = test_data)

  # copy the table
  target_conn <- DBI::dbConnect(duckdb::duckdb(), dbdir = ":memory:")
  copy_entire_table_to_db(
    source_conn = source_conn,
    table_name = table_name,
    target_conn = target_conn
  )

  # verify the copy
  testthat::expect_equal(
    dplyr::collect(dplyr::tbl(target_conn, table_name)),
    test_data
  )
})
