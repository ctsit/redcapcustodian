library(tidyverse)
library(lubridate)
library(REDCapR)
library(dotenv)
library(redcapcustodian)
library(DBI)
library(RMariaDB)

dotenv::load_dot_env("prod.env")
conn <- connect_to_redcap_db()

project_ids_of_interest <- dplyr::tbl(conn, "redcap_ehr_fhir_logs") |>
  dplyr::filter(.data$resource_type == "Patient") |>
  dplyr::distinct(project_id) |>
  dplyr::collect() |>
  sample_n(size = 1) |>
  pull(project_id)

redcap_ehr_fhir_logs <- dplyr::tbl(conn, "redcap_ehr_fhir_logs") |>
  dplyr::filter(.data$resource_type == "Patient" &
                  .data$mrn != "" &
                  project_id == project_ids_of_interest) |>
  dplyr::collect()

redcap_ui_ids_of_interest <- redcap_ehr_fhir_logs |>
  dplyr::distinct(user_id) |>
  dplyr::collect() |>
  dplyr::pull(user_id)

redcap_user_information <- dplyr::tbl(conn, "redcap_user_information") |>
  dplyr::filter(ui_id %in% redcap_ui_ids_of_interest) |>
  dplyr::select(
    "ui_id",
    "username"
  ) |>
  dplyr::collect()

redcap_projects <- dplyr::tbl(conn, "redcap_projects") |>
  dplyr::filter(project_id %in% project_ids_of_interest) |>
  dplyr::select(
    "project_id",
    "app_title",
    "project_pi_firstname",
    "project_pi_mi",
    "project_pi_lastname",
    "project_pi_email",
    "project_pi_alias",
    "project_irb_number"
  ) |>
  collect()

# Save our test tables
test_tables <- c(
  "redcap_ehr_fhir_logs",
  "redcap_user_information",
  "redcap_projects"
)
purrr::walk(test_tables, write_rds_to_test_dir, "hipaa_disclosure_log")
