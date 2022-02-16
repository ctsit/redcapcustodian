conn <- dbConnect(RSQLite::SQLite(), dbname = ":memory:")

test_that("get_get_test_table_names() accurately reflects all schema files included in inst", {
  expect_equal(
    length(
      Sys.glob(paste0(system.file(package = "redcapcustodian"), "/testdata/*_schema.sql"))
    ),
    length(get_test_table_names())
  )
})

create_test_tables(conn)
test_that("create_test_tables successfully creates all desired tables", {
  expect_equal(length(DBI::dbListTables(conn)), length(get_test_table_names()))
})

test_that("create_test_table creates redcap_user_information with the right dimensions", {
  expect_equal(dim(tbl(conn, "redcap_user_information") %>% collect()), c(6,49))
})

test_that("create_test_table creates redcap_projects with the right dimensions", {
  expect_equal(dim(tbl(conn, "redcap_projects") %>% collect()), c(20,142))
})
