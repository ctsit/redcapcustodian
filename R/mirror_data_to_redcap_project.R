#' Mirror a dataframe to a REDCap project
#'
#' @param df_to_mirror Dataframe to be imported into the REDCap project.
#' @param record_id_col Column in the dataframe that uniquely identifies each record.
#' @param project_name REDCap project name.
#' @param path_to_env_file Path to the ".env" credentials file.
#' @param ... Additional parameters passed to \code{\link[REDCapR]{redcap_write}}.
#'
#' @return Same values as returned by \code{\link[REDCapR]{redcap_write}}.
#' @export
#'
#' @seealso \code{\link{dataframe_to_redcap_dictionary}} to understand the REDCap data dictionary requirements.
#' The dictionary must be created and uploaded to REDCap for \code{mirror_data_to_redcap_project} to function properly.
#'
#' @examples
#' \dontrun{
#' df <- data.frame(
#'   pk_col = c("a1", "a2", "a3"),
#'   integer_col = c(1, 2, 3),
#'   numeric_col = 5.9,
#'   character_col = c("a", "b", "c"),
#'   date_col = as.Date("2011-03-07"),
#'   date_time_col = as.POSIXct(strptime("2011-03-27 01:30:00", "%Y-%m-%d %H:%M:%S")),
#'   email_col = c("test@example.com", "test.2@example.edu", "3test@example.net")
#' )
#' mirrored_data <- mirror_data_to_redcap_project(df, "pk_col", "test_project", "<env_path>.env")
#' }
#'
mirror_data_to_redcap_project <- function(df_to_mirror,
                                          record_id_col,
                                          project_name,
                                          path_to_env_file,
                                          ...) {
  if (!file.exists(path_to_env_file)) {
    stop(sprintf("The .env file was not found at %s", path_to_env_file))
  } else {
    dotenv::load_dot_env(path_to_env_file)
  }

  # retrieve the PID value from environment the env file
  project_id <- paste0(toupper(project_name), "_PID") |>
    Sys.getenv()

  credentials_db_path <- Sys.getenv("CREDENTIALS_DB")

  # check if the PID was found
  if (project_id == "") {
    stop(sprintf(
      "Environment variable %s not found in %s.",
      paste0(toupper(project_name), "_PID"),
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

  if (!record_id_col %in% names(df_to_mirror)) {
    stop("The provided record_id_col does not exist in the input dataframe.")
  }

  # create the record_id and make it the first column in df
  df_to_mirror_with_record_id <- df_to_mirror |>
    dplyr::rename(record_id = tidyselect::all_of(record_id_col)) |>
    dplyr::select("record_id", dplyr::everything())

  rownames(df_to_mirror_with_record_id) <- NULL

  write_result <- REDCapR::redcap_write(
    redcap_uri = redcap_credentials$redcap_uri,
    token = redcap_credentials$token,
    ds_to_write = df_to_mirror_with_record_id,
    ...
  )

  return(write_result)
}
