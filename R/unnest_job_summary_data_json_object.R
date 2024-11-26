#' unnest_job_summary_data_json_object
#'
#' @description
#' The REDCap Custodian logging provide a field, `job_summary_data`, to store
#' arbitrary details about a job. Its contents are defined entirely by the script,
#' but in practice, it is very easy to encode a data frame or a list of data
#' frames into a JSON object, so this has become the common practice.
#'
#' Yet using the data can be a bit more complex because `jsonlite::fromJSON` is
#' not vectorized. If you need to read multiple job log records, iteration is
#' required to use JSON object in `job_summary_data`.
#'
#' This function addresses that need accepting a dataframe of job summary logs
#' and unnesting the JSON object(s) in `job_summary_data` into the equivalent
#' R objects.
#'
#' Use `objects_to_include` to limit the unnested objects to those with similar
#' geometry. Dissimilar objects cannot be unnested together.
#'
#' @param log_data - a dataframe of job summary logs
#' @param objects_to_include - an optional vector of JSON objects in the
#'   job_summary_data to be un-nested
#'
#' @return - the input dataframe of job summary logs with `job_summary_data`
#'   replaced by the R objects that were JSON-encoded therein.
#' @export
#'
#' @examples
#' \dontrun{
#' library(redcapcustodian)
#' library(RMariaDB)
#' library(DBI)
#' library(tidyverse)
#' library(dotenv)
#'
#' init_etl("pbc_scratch")
#'
#' log_conn <- get_package_scope_var("log_con")
#'
#' log_data <- tbl(log_conn, "rcc_job_log") %>%
#'   dplyr::filter(script_name == "warn_owners_of_impending_bill") |>
#'   collect()
#'
#' unnest_job_summary_data_json_object(log_data)
#'
#' # Read a more complex object
#' log_data_2 <- tbl(log_conn, "rcc_job_log") |>
#'   dplyr::filter(
#'     script_name == "create_and_send_new_redcap_prod_per_project_line_items" &
#'       level == "SUCCESS"
#'   ) %>%
#'   collect()
#'
#' # Fails due to dissimilar objects
#' unnest_job_summary_data_json_object(log_data_2)
#' # error is "Can't recycle `service_instance` (size 27) to match `invoice_line_item` (size 79)."
#'
#' # When separated, the objects can be unnested
#' unnest_job_summary_data_json_object(log_data_2, objects_to_include = c("service_instance"))
#' unnest_job_summary_data_json_object(log_data_2, objects_to_include = c("invoice_line_item"))
#' }
unnest_job_summary_data_json_object <- function(log_data, objects_to_include = NA) {
  log_ids <- log_data$id
  names(log_ids) <- log_ids

  if (is.na(objects_to_include[1]) & length(objects_to_include) == 1) {
    result <- purrr::map2_dfr(log_ids, log_data$job_summary_data, ~ jsonlite::fromJSON(.y), .id = "id") %>%
      dplyr::mutate(id = as.integer(.data$id)) %>%
      dplyr::left_join(log_data %>% dplyr::select(-"job_summary_data"), by = "id")
  } else {
    result <- purrr::map2_dfr(log_ids, log_data$job_summary_data, ~ jsonlite::fromJSON(.y)[objects_to_include], .id = "id") %>%
      dplyr::mutate(id = as.integer(.data$id)) %>%
      dplyr::left_join(log_data %>% dplyr::select(-"job_summary_data"), by = "id")
  }

  return(result)
}
