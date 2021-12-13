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

test_that("get_redcap_emails returns the correct dataframe", {
  expect_identical(get_redcap_emails(conn), get_redcap_email_output)
})
