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


tall <- dplyr::tribble(
  ~ui_id, ~username, ~user_suspended_time, ~email_field_name, ~email,
  1, "site_admin", NA, "user_email", "joe.user@projectredcap.org",
  2, "admin", NA, "user_email",  "admin@example.org",
  3, "alice", NA, "user_email",  "alice@example.org",
  4, "bob",   NA, "user_email",  "bob_a@example.org",
  4, "bob",   NA, "user_email2", "bob_b@example.org",
  5, "carol", NA, "user_email",  "carol_a@example.org",
  5, "carol", NA, "user_email2", "carol_b@example.org",
  6, "dan",   NA, "user_email",  "dan_a@example.org",
  6, "dan",   NA, "user_email2", "dan_b@example.org",
  6, "dan",   NA, "user_email3", "dan_c@example.org"
) %>%
  dplyr::mutate(ui_id = as.integer(ui_id)) %>%
  dplyr::mutate(user_suspended_time = as.POSIXct(user_suspended_time))

wide <- tall %>%
  pivot_wider(
    names_from = "email_field_name",
    values_from = "email"
  )

get_redcap_emails_test_data <- list(
  tall = tall,
  wide = wide
)

usethis::use_data(get_redcap_emails_test_data, overwrite = TRUE)


person <- dplyr::tribble(
  ~user_id, ~email,
  "site_admin", "joe.user@projectredcap.org",
  "admin", "admin@example.org",
  "alice", "real_alice@example.org",
  "bob",   "bob_b@example.org",
  "carol", "carol_a@example.org",
  "dan", "daniel@example.org"
)

bad_redcap_user_emails <- dplyr::tribble(
  ~ui_id, ~username, ~email_field_name, ~email,
  1, "site_admin", "user_email", "joe.user@projectredcap.org",
  3, "alice", "user_email",  "alice@example.org",
  4, "bob",   "user_email",  "bob_a@example.org",
  5, "carol", "user_email2", "carol_b@example.org",
  6, "dan",   "user_email",  "dan_a@example.org",
  6, "dan",   "user_email2", "dan_b@example.org",
  6, "dan",   "user_email3", "dan_c@example.org"
) %>% dplyr::mutate(ui_id = as.integer(ui_id))

output <- dplyr::tribble(
  ~ui_id, ~email_field_name, ~username, ~corrected_email, ~email,
  1, "user_email", "site_admin", NA, "joe.user@projectredcap.org",
  3, "user_email", "alice", "real_alice@example.org", "alice@example.org",
  4, "user_email", "bob", "bob_b@example.org", "bob_a@example.org",
  5, "user_email2", "carol", "carol_a@example.org", "carol_b@example.org",
  6, "user_email", "dan", "daniel@example.org", "dan_a@example.org",
  6, "user_email2", "dan", "daniel@example.org", "dan_b@example.org",
  6, "user_email3", "dan", "daniel@example.org", "dan_c@example.org"
) %>%
  dplyr::mutate(ui_id = as.integer(ui_id))

get_redcap_email_revisions_test_data <- list(
  bad_redcap_user_emails = bad_redcap_user_emails,
  person = person,
  output = output
)

usethis::use_data(get_redcap_email_revisions_test_data, overwrite = T)

output <- dplyr::tribble(
  ~ui_id, ~username, ~user_email, ~user_email2, ~user_email3,
  1, "site_admin", NA_character_, NA_character_, NA_character_,
  2, "admin", "admin@example.org", NA_character_, NA_character_,
  3, "alice", "real_alice@example.org",  NA_character_, NA_character_,
  4, "bob",   "bob_b@example.org", "bob_b@example.org", NA_character_,
  5, "carol", "carol_a@example.org", "carol_a@example.org", NA_character_,
  6, "dan",   "daniel@example.org", "daniel@example.org", "daniel@example.org"
)

update_redcap_email_addresses_test_data <- list(
  output = output
)

usethis::use_data(update_redcap_email_addresses_test_data, overwrite = T)
