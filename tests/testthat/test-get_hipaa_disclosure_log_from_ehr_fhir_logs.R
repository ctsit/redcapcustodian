testthat::test_that("get_hipaa_disclosure_log_from_ehr_fhir_logs works", {
  # read our test data
  directory_under_test_path <- "hipaa_disclosure_log"
  test_tables <- c(
    "redcap_ehr_fhir_logs",
    "redcap_user_information",
    "redcap_projects"
  )

  conn <- DBI::dbConnect(duckdb::duckdb(), dbdir = ":memory:")
  purrr::walk(test_tables, create_a_table_from_rds_test_data, conn, "hipaa_disclosure_log")

  required_names <- c(
    "disclosure_date", "fhir_id", "mrn", "project_irb_number"
  )

  result <- get_hipaa_disclosure_log_from_ehr_fhir_logs(conn)

  # test for the required columns
  testthat::expect_contains(names(result), required_names)
  # test for at least one row
  testthat::expect_gt(nrow(result), 0)
  # test for only distinct rows
  testthat::expect_equal(
    nrow(result),
    result |> distinct(disclosure_date, fhir_id, mrn, project_irb_number, username) |> nrow())

  DBI::dbDisconnect(conn, shutdown=TRUE)
})
