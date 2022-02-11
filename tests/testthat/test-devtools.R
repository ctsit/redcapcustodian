conn <- dbConnect(RSQLite::SQLite(), dbname = ":memory:")

create_test_table(conn, "redcap_user_information")
test_that("create_test_table creates redcap_user_information with the right dimensions", {
  expect_equal(dim(tbl(conn, "redcap_user_information") %>% collect()), c(6,49))
})

create_test_table(conn, "redcap_projects")
test_that("create_test_table creates redcap_projects with the right dimensions", {
  expect_equal(dim(tbl(conn, "redcap_projects") %>% collect()), c(20,142))
})
