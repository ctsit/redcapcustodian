conn <- dbConnect(RSQLite::SQLite(), dbname = ":memory:")

create_test_table(conn, "redcap_user_information")

get_redcap_email_output <- dplyr::tribble(
  ~ui_id, ~username, ~email_field_name, ~email,
  1, "site_admin", "user_email", "joe.user@projectredcap.org",
  2, "admin", "user_email",  "admin@example.org",
  3, "alice", "user_email",  "alice@example.org",
  4, "bob",   "user_email",  "bob_a@example.org",
  4, "bob",   "user_email2", "bob_b@example.org",
  5, "carol", "user_email",  "carol_a@example.org",
  5, "carol", "user_email2", "carol_b@example.org",
  6, "dan",   "user_email",  "dan_a@example.org",
  6, "dan",   "user_email2", "dan_b@example.org",
  6, "dan",   "user_email3", "dan_c@example.org"
) %>% dplyr::mutate(ui_id = as.integer(ui_id))

get_institutional_person_output <- dplyr::tribble(
  ~user_id, ~email,
  "site_admin", "joe.user@projectredcap.org",
  "admin", "admin@example.org",
  "alice", "alice@example.org",
)

get_bad_redcap_email_output <- dplyr::tribble(
  ~ui_id, ~username, ~email_field_name, ~email,
  1, "site_admin", "user_email", "joe.user@projectredcap",
  2, "admin", "user_email",  "admin@example",
  3, "alice", "user_email",  "alice@example",
  4, "bob",   "user_email",  "bob_a@example",
  4, "bob",   "user_email2", "bob_b@example",
  5, "carol", "user_email",  "carol_a@example",
  5, "carol", "user_email2", "carol_b@example",
  6, "dan",   "user_email",  "dan_a@example",
  6, "dan",   "user_email2", "dan_b@example",
  6, "dan",   "user_email3", "dan_c@example",
  6, "dan",   "user_email3", "dan_c@example"
) %>% dplyr::mutate(ui_id = as.integer(ui_id))

get_institutional_person_output <- dplyr::tribble(
  ~user_id, ~email,
  "site_admin", "joe.user@projectredcap.org",
  "admin", "admin@example.org",
  "alice", "alice@example.org",
  "dan",   "dan_b@example",
  "bob",   "",
  "carol", NA
)

test_that("get_redcap_emails returns the correct dataframe", {
  expect_identical(get_redcap_emails(conn), get_redcap_email_output)
})

test_that("get_redcap_email_revisions returns the proper data frame", {
  result <- get_redcap_email_revisions(get_bad_redcap_email_output, get_institutional_person_output)

  expect_named(result, c("ui_id", "username", "email_field_name", "corrected_email"))
})

test_that("get_redcap_email_revisions returns unique entries for ui_id and email_field_name" ,{
  result <- get_redcap_email_revisions(get_bad_redcap_email_output, get_institutional_person_output) %>%
    dplyr::group_by(ui_id, email_field_name) %>%
    dplyr::count() %>%
    dplyr::filter(n > 1)

  expect_equal(nrow(result), 0)
})

test_that("get_redcap_email_revisions does not return any na or blank corrected_email_fields" ,{
  result <- get_redcap_email_revisions(get_bad_redcap_email_output, get_institutional_person_output) %>%
    dplyr::filter(is.na(corrected_email) | corrected_email == "")

  expect_equal(nrow(result), 0)
})
