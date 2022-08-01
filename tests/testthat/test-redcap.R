conn <- dbConnect(RSQLite::SQLite(), dbname = ":memory:")

create_test_table(conn, "redcap_user_information")

test_that("get_redcap_emails returns the correct dataframes", {
  expect_identical(get_redcap_emails(conn)$tall, get_redcap_emails_test_data$tall)
  expect_identical(get_redcap_emails(conn)$wide, get_redcap_emails_test_data$wide)
})

test_that("get_redcap_email_revisions returns the correct columns", {
  result <- get_redcap_email_revisions(
    get_redcap_email_revisions_test_data$bad_redcap_user_emails,
    get_redcap_email_revisions_test_data$person
  )

  expect_named(result, c("ui_id", "email_field_name", "username", "corrected_email", "email"))
})

test_that("get_redcap_email_revisions returns unique entries for ui_id and email_field_name" ,{
  result <- get_redcap_email_revisions(
    get_redcap_email_revisions_test_data$bad_redcap_user_emails,
    get_redcap_email_revisions_test_data$person
  ) %>%
    dplyr::group_by(ui_id, email_field_name) %>%
    dplyr::count() %>%
    dplyr::filter(n > 1)

  expect_equal(nrow(result), 0)
})

testthat::test_that("get_redcap_email_revisions returns the correct dataframe", {
  result <- get_redcap_email_revisions(
    get_redcap_email_revisions_test_data$bad_redcap_user_emails,
    get_redcap_email_revisions_test_data$person
    )

  testthat::expect_identical(result, get_redcap_email_revisions_test_data$output)
})

testthat::test_that("get_redcap_email_revisions properly updates alice's email", {
  result <- get_redcap_email_revisions(
    get_redcap_email_revisions_test_data$bad_redcap_user_emails,
    get_redcap_email_revisions_test_data$person
  )

  alice_new_email <- result %>%
    dplyr::filter(username == "alice") %>%
    dplyr::pull(corrected_email)

  alice_correct_email <- get_redcap_email_revisions_test_data$person %>%
    dplyr::filter(user_id == "alice") %>%
    dplyr::pull(email)

  testthat::expect_equal(alice_new_email, alice_correct_email)
})

testthat::test_that("update_redcap_email_addresses properly updates email addresses in redcap_user_information", {

  redcap_email_revisions <- get_redcap_email_revisions(
    get_redcap_email_revisions_test_data$bad_redcap_user_emails,
    get_redcap_email_revisions_test_data$person
  )

  update_n = update_redcap_email_addresses(conn, redcap_email_revisions, get_redcap_emails_test_data$wide)

  result <- DBI::dbGetQuery(
    conn,
    "select ui_id, username, user_email, user_email2, user_email3 from redcap_user_information"
  ) %>%
    tibble::tibble()

  testthat::expect_equal(nrow(redcap_email_revisions), update_n)
  testthat::expect_equal(update_redcap_email_addresses_test_data$output, result)
})
