#' Retrieve REDCap Credentials Based on Specified Parameters
#'
#' Fetches REDCap credentials from the CREDENTIALS_DB, allowing filtering based on
#' project ID, server short name, project short name, and username. At least one filtering
#' criterion must be provided.
#'
#' @param project_pid Optional project ID for filtering.
#' @param server_short_name Optional server short name for filtering.
#' @param project_short_name Optional project short name for filtering.
#' @param username Optional username for filtering.
#'
#' @return A dataframe of filtered REDCap credentials, including a 'url' column added for convenience.
#'
#' @examples
#' \dontrun{
#'   source_credentials <- get_redcap_credentials(project_pid = "123")
#'   prod_credentials <- get_redcap_credentials(server_short_name = "prod")
#'   target_credentials <- prod_credentials |>
#'     filter(str_detect(project_name, "biospecimens"))
#' }
#'
#' @export
#'
get_redcap_credentials <- function(project_pid = NA,
                                   server_short_name = NA,
                                   project_short_name = NA,
                                   username = NA) {

  # Verify that there is at least one parameter
  if (
    all(is.na(
      c(
        server_short_name,
        username,
        project_pid,
        project_short_name
      )
    ))
  ) {
    stop("At least one parameter must be defined")
  }

  credentials_conn <- DBI::dbConnect(RSQLite::SQLite(), Sys.getenv("CREDENTIALS_DB"))

  redcap_credentials <- dplyr::tbl(credentials_conn, "credentials") |>
    # Filter on any non-NA parameter
    # Parameters have to be localized so that will not be seen as columns in the data frame
    dplyr::filter(is.na(!!project_pid) | .data$project_id == !!project_pid) |>
    dplyr::filter(is.na(!!server_short_name) | .data$server_short_name == !!server_short_name) |>
    dplyr::filter(is.na(!!project_short_name) | .data$project_short_name == !!project_short_name) |>
    dplyr::filter(is.na(!!username) | .data$username == !!username) |>
    dplyr::collect() |>
    # Make a copy of redcap_uri to make redcapAPI coding a tiny bit simpler
    dplyr::mutate(url = .data$redcap_uri)

  DBI::dbDisconnect(credentials_conn)

  return(redcap_credentials)
}

