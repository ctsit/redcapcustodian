library(testthat)
library(dplyr)
library(purrr)
library(DBI)
library(duckdb)
library(lubridate)

testthat::test_that("get_hipaa_disclosure_log_from_ehr_fhir_logs works", {
  # read our test data
  directory_under_test_path <- "hipaa_disclosure_log"

  test_tables <- c(
    "redcap_ehr_fhir_logs",
    "redcap_user_information",
    "redcap_projects",
    "redcap_ehr_settings"
  )

  conn <- DBI::dbConnect(duckdb::duckdb(), dbdir = ":memory:")

  purrr::walk(test_tables, create_a_table_from_rds_test_data, conn, directory_under_test_path)

  # Mutate the redcap_ehr_fhir_logs table after loading it
  redcap_ehr_fhir_logs <- dplyr::tbl(conn, "redcap_ehr_fhir_logs") |>
    dplyr::filter(.data$resource_type == "Patient" & .data$mrn != "") |>
    head(n = 30) |>
    dplyr::collect() |>
    dplyr::mutate(
      ehr_id = sample(1:3, dplyr::n(), replace = TRUE),
      created_at = seq.Date(from = Sys.Date() - 10, to = Sys.Date(), length.out = dplyr::n())
    )

  # Write the mutated data back to the database
  duckdb::duckdb_register(conn, "redcap_ehr_fhir_logs", redcap_ehr_fhir_logs)

  # Required column names
  required_names <- c(
  "disclosure_date", "fhir_id", "mrn", "project_irb_number",
  "ehr_id", "ehr_name", "fhir_base_url", "patient_identifier_string")

  result <- get_hipaa_disclosure_log_from_ehr_fhir_logs(conn)

  testthat::expect_contains(names(result), required_names)
  testthat::expect_gt(nrow(result), 0)
  testthat::expect_equal(
    nrow(result),
    result |> dplyr::distinct(disclosure_date, fhir_id, mrn, project_irb_number, username) |> nrow()
  )

  result_filtered_ehr_id <- get_hipaa_disclosure_log_from_ehr_fhir_logs(conn, ehr_id = 1)
  testthat::expect_true(all(result_filtered_ehr_id$ehr_id == 1))

  start_date <- Sys.Date() - 5
  result_filtered_start_date <- get_hipaa_disclosure_log_from_ehr_fhir_logs(conn, start_date = start_date)
  testthat::expect_true(all(result_filtered_start_date$disclosure_date >= start_date))

  end_date <- Sys.Date() - 5
  result_filtered_end_date <- get_hipaa_disclosure_log_from_ehr_fhir_logs(conn, end_date = end_date)
  testthat::expect_true(all(result_filtered_end_date$disclosure_date < end_date))

  start_date <- Sys.Date() - 7
  end_date <- Sys.Date() - 5
  result_filtered_start_and_end_date <- get_hipaa_disclosure_log_from_ehr_fhir_logs(conn, start_date = start_date, end_date = end_date)
  testthat::expect_true(all(result_filtered_start_and_end_date$disclosure_date >= start_date))
  testthat::expect_true(all(result_filtered_start_and_end_date$disclosure_date < end_date))

  result_combined_filters <- get_hipaa_disclosure_log_from_ehr_fhir_logs(conn, ehr_id = 2, start_date = start_date)
  testthat::expect_true(all(result_combined_filters$ehr_id == 2))
  testthat::expect_true(all(result_combined_filters$disclosure_date >= start_date))

  result_nonexistent_ehr_id <- get_hipaa_disclosure_log_from_ehr_fhir_logs(conn, ehr_id = 9999)
  testthat::expect_equal(nrow(result_nonexistent_ehr_id), 0)

  future_start_date <- Sys.Date() + 1
  result_future_date <- get_hipaa_disclosure_log_from_ehr_fhir_logs(conn, start_date = future_start_date)
  testthat::expect_equal(nrow(result_future_date), 0)

  # test that we can query with multiple EHR_IDs
  result_multiple_filtered_ehr_id <- get_hipaa_disclosure_log_from_ehr_fhir_logs(conn, ehr_id = c(1,2))
  testthat::expect_true(all(result_multiple_filtered_ehr_id$ehr_id %in% c(1,2)))

  DBI::dbDisconnect(conn, shutdown = TRUE)
})
