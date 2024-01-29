#' write_project_data Write data from a REDCap project
#'
#' @param ... parameters to pass on to `REDCapR::redcap_write`
#' @param conn Connection object to the credentials database
#' @param project_pid the project PID in the REDCap system.
#' This string will be used to search through a REDCap custodian
#' credentials database to locate the `token` and `redcap_uri`
#' @param server_short_name an optional name of the server that
#' houses the REDCap project of interest. This will prevent
#' project PID clashes.
#'
#' @return a dataframe of data write from a REDCap project
#' @export
#' @importFrom rlang .data
#' @examples
#' \dontrun{
#' library(redcapcustodian)
#' library(DBI)
#'
#' dotenv::load_dot_env("testing.env")
#' init_etl("dummy")
#'
#' support_data <- write_project_data(
#'   conn = DBI::dbConnect(RSQLite::SQLite(), Sys.getenv("CREDENTIALS_DB")),
#'   project_pid = Sys.getenv("MY_PROJECT_PID"))
#' }
write_project_data <- function(..., conn, project_pid, server_short_name = as.character(NA)) {
  redcap_credentials <- dplyr::tbl(conn, "credentials") |>
    dplyr::filter(.data$project_id == project_pid) |>
    dplyr::filter(is.na(server_short_name) | .data$server_short_name == server_short_name) |>
    dplyr::collect()

  # Get the data from the REDCap Project
  data_write <- REDCapR::redcap_write(
    redcap_uri = redcap_credentials$redcap_uri,
    token =  redcap_credentials$token,
    batch_size = 2000,
    ...
  )

  return(data_write)
}
