#' get_hipaa_disclosure_log_from_ehr_fhir_logs
#' @description
#' Read a data needed for a HIPAA disclosure log from a REDCap database
#' given a DBI connection object to the REDCap database and some optional
#' parameters to narrow the returned result.
#'
#' Optionally filter the data with the data range `[start_date, end_date)`.
#'
#' @param conn a DBI connection object to the REDCap database
#' @param ehr_id a vector of REDCap EHR_IDs for the EHR(s) of interest (optional)
#' @param start_date The first date from which we should return results (optional)
#' @param end_date The last date (non-inclusive) from which we should return results (optional)
#'
#' @return A dataframe suitable for generating a HIPAA disclosure log
#' @export
#'
#' @examples
#' \dontrun{
#' library(tidyverse)
#' library(lubridate)
#' library(REDCapR)
#' library(dotenv)
#' library(redcapcustodian)
#' library(DBI)
#' library(RMariaDB)
#'
#' init_etl("export_fhir_traffic_log")
#' conn <- connect_to_redcap_db()
#'
#' get_hipaa_disclosure_log_from_ehr_fhir_logs(conn)
#' }
get_hipaa_disclosure_log_from_ehr_fhir_logs <- function(
    conn,
    ehr_id = NA_real_,
    start_date = as.Date(NA),
    end_date = as.Date(NA)) {

  # rename parameters for local use
  ehr_id_local <- ehr_id

  # determine if ehr_id of interest
  ehr_id_is_na <- length(ehr_id_local) == 1 & all(is.na(ehr_id_local))

  # make DBI objects for joins
  user_information <- dplyr::tbl(conn, "redcap_user_information") |>
    dplyr::select(
      "ui_id",
      "username"
    )

  projects <- dplyr::tbl(conn, "redcap_projects") |>
    dplyr::select(
      "project_id",
      "app_title",
      "project_pi_firstname",
      "project_pi_mi",
      "project_pi_lastname",
      "project_pi_email",
      "project_pi_alias",
      "project_irb_number"
    )

  redcap_ehr_settings <- dplyr::tbl(conn, "redcap_ehr_settings") |>
    dplyr::select(
      "ehr_id",
      "ehr_name",
      "fhir_base_url",
      "patient_identifier_string"
    )

  disclosures <-
    dplyr::tbl(conn, "redcap_ehr_fhir_logs") |>
    dplyr::filter(.data$resource_type == "Patient" & .data$mrn != "") |>
    dplyr::filter(is.na(start_date) | .data$created_at >= start_date) |>
    dplyr::filter(is.na(end_date) | .data$created_at < end_date) |>
    dplyr::filter(ehr_id_is_na | .data$ehr_id %in% ehr_id_local) |>
    dplyr::left_join(user_information, by = c("user_id" = "ui_id")) |>
    dplyr::left_join(projects, by = c("project_id")) |>
    dplyr::left_join(redcap_ehr_settings, by = c("ehr_id")) |>
    dplyr::collect() |>
    dplyr::mutate(disclosure_date = lubridate::floor_date(.data$created_at, unit = "day")) |>
    dplyr::select(-c("id", "created_at")) |>
    dplyr::distinct() |>
    dplyr::arrange(.data$disclosure_date) |>
    dplyr::rename(redcap_project_name = "app_title") |>
    dplyr::select(
      "disclosure_date",
      "fhir_id",
      "mrn",
      "ehr_id",
      "ehr_name",
      "fhir_base_url",
      "patient_identifier_string",
      "project_irb_number",
      "project_pi_firstname",
      "project_pi_mi",
      "project_pi_lastname",
      "project_pi_email",
      "redcap_project_name",
      "username",
      dplyr::everything()
    )

  return(disclosures)
}
