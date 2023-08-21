#' mirror_data_to_redcap_project
#'
#' mirror a dataframe to a REDCap project
#'
#' @param df_to_mirror the dataframe to be imported into the REDCap project
#' @param table_name  the table name
#' @param path_to_env_file the env file path
#' @param ... Additional parameters that will be passed to \code{\link[REDCapR]{redcap_write}}
#' @parm env_file the path to the env file that contains the required credentials
#'
#' @return  Same values returned as \code{\link[REDCapR]{redcap_write}}
#' @export
#'
#' @examples
#' \dontrun{
#' mirror_data <- mirror_data_to_redcap_project(df, "table_name", "./folder/path/.env")
#' }
#'
mirror_data_to_redcap_project <- function(df_to_mirror, table_name, path_to_env_file, ...) {


  if (!file.exists(path_to_env_file)) {
    stop(sprintf("The .env file was not found at %s", path_to_env_file))
  } else {
    dotenv::load_dot_env(path_to_env_file)
  }

  # retrieve the PID value from environment the env file
  project_id <- paste0(toupper(table_name), "_PID") |>
    Sys.getenv()

  credentials_db_path <- Sys.getenv("CREDENTIALS_DB")

  # check if the PID was found
  if (project_id == "") {
    stop(sprintf(
      "Environment variable %s not found in %s.",
      paste0(toupper(table_name), "_PID"),
      path_to_env_file
    ))
  } else if (credentials_db_path == "") {
    stop(sprintf(
      "Environment variable CREDENTIALS_DB not found in %s.",
      path_to_env_file
    ))
  }

  credentials_db <- DBI::dbConnect(RSQLite::SQLite(), credentials_db_path)

  # get the REDCap API credentials from the credentials database
  redcap_credentials <- dplyr::tbl(credentials_db, "credentials") |>
    dplyr::filter(project_id == local(project_id)) |>
    dplyr::collect()

  # check if credentials were found
  if (nrow(redcap_credentials) == 0) {
    stop(sprintf("No REDCap API credentials found for PID %s.", project_id))
  }

  # create unique identifier for each record
  df_to_mirror$record_id <- seq_len(nrow(df_to_mirror))
  # make record_id the first column
  df_to_mirror <- df_to_mirror[, c("record_id", setdiff(names(df_to_mirror), "record_id"))]

  rownames(df_to_mirror) <- NULL

  write_result <- REDCapR::redcap_write(
    redcap_uri = redcap_credentials$redcap_uri,
    token = redcap_credentials$token,
    ds_to_write = df_to_mirror,
    ...
  )

  return(write_result)
}
