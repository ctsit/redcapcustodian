testthat::test_that("expire_user_project_rights excludes specified users from expiration", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), dbname = ":memory:")

  DBI::dbCreateTable(
    conn,
    name = "redcap_user_rights",
    fields = user_rights_test_data$redcap_user_rights
  )
  DBI::dbAppendTable(
    conn,
    name = "redcap_user_rights",
    value = user_rights_test_data$redcap_user_rights
  )

  all_users_except <- c("bob", "dan")
  my_project_ids = c(34)

  result <- expire_user_project_rights(
    conn = conn,
    project_ids = my_project_ids,
    all_users_except = all_users_except
  )

  testthat::expect_equal(result$updates, 3)

  testthat::expect_equal(
    tbl(conn, "redcap_user_rights") %>%
      dplyr::filter(.data$project_id %in% my_project_ids) %>%
      dplyr::filter(is.na(expiration)) %>%
      dplyr::select(username) %>%
      dplyr::collect() %>%
      dplyr::pull(username),
    all_users_except
  )
})

testthat::test_that("expire_user_project_rights expires specified users", {
  conn <- DBI::dbConnect(RSQLite::SQLite(), dbname = ":memory:")

  DBI::dbCreateTable(
    conn,
    name = "redcap_user_rights",
    fields = user_rights_test_data$redcap_user_rights
  )
  DBI::dbAppendTable(
    conn,
    name = "redcap_user_rights",
    value = user_rights_test_data$redcap_user_rights
  )

  usernames <- c("bob", "dan")
  my_project_ids <- c(34)

  result <- expire_user_project_rights(
    conn = conn,
    project_ids = my_project_ids,
    usernames = usernames
  )

  testthat::expect_equal(
    tbl(conn, "redcap_user_rights") %>%
      dplyr::filter(.data$project_id %in% my_project_ids) %>%
      dplyr::filter(.data$username %in% usernames) %>%
      dplyr::select(expiration) %>%
      dplyr::collect() %>%
      dplyr::pull(expiration),
    c(
      as.character(lubridate::today()),
      as.character(lubridate::today())
    )
  )
})
