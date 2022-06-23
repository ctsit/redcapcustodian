# create test data for functions used in etl/cleanup_bad_email_addresses.R

get_bad_emails_from_listserv_digest_test_output <-
  dplyr::tribble(
    ~email,
    "joe.user@projectredcap.org",
    "alice@example.org",
    "bob_a@example.org",
    "carol_b@example.org",
    "dan_a@example.org",
    "dan_b@example.org",
    "dan_c@example.org"
  )

usethis::use_data(get_bad_emails_from_listserv_digest_test_output, overwrite = TRUE)


get_redcap_emails_output <- dplyr::tribble(
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

usethis::use_data(get_redcap_emails_output, overwrite = TRUE)
