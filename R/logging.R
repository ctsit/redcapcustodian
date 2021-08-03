# Set a package-scoped environment for "global" vars on package load
redcapcustodian.env <- new.env(parent = emptyenv())

# Standardized error message tibble
error_list <- dplyr::tibble(
  message = character()
)

#' Builds formatted data frame from source data
#'
#' @param result, the df to log
#' @param database_written, the database the etl wrote to
#' @param table_written, the table the etl wrote to
#' @param log_level, the log level (DEBUG, ERROR, INFO)
#' @param pk_col, the dataframe col to use as the primary_key
#'
#' @return df_etl_log, the df matching the etl_log table
#'
#' @examples
#' \dontrun{
#'  build_formatted_df_from_result(
#'    result,
#'    database_written,
#'    table_written,
#'    log_level,
#'    pk_col
#'  )
#' }
build_formatted_df_from_result <- function(result, database_written, table_written, log_level, pk_col) {
  log_data <- result %>%
    dplyr::ungroup() %>%
    dplyr::mutate(record_level_data = purrr::pmap(.data, ~ rjson::toJSON(c(...)))) %>%
    dplyr::select(primary_key = pk_col, .data$record_level_data) %>%
    dplyr::mutate(
      script_name = get_script_name(),
      script_run_time = get_script_run_time(),
      log_date = get_current_time(),
      database_written = database_written,
      table_written = table_written,
      level = log_level,
      # record_level_data cannot be a list
      record_level_data = unlist(.data$record_level_data)
    )

  return(log_data)
}

#' Fetches the current time in system time zone
#'
#' @return A duration object representing the current time
#'
#' @export
#' @examples
#' \dontrun{
#' get_current_time()
#' }
get_current_time <- function() {
  current_time <- lubridate::with_tz(
    lubridate::now(),
    tzone = Sys.getenv("TIME_ZONE")
  )
  return(current_time)
}

#' Fetches the package-scoped value of script_name
#'
#' @export
get_script_name <- function() {
  return(redcapcustodian.env$script_name)
}

#' Fetches the package-scoped value of script_run_time
#'
#' @export
#' @examples
#' get_script_run_time()
get_script_run_time <- function() {
  return(redcapcustodian.env$script_run_time)
}

#' Assigns package-scoped script_name. \cr
#' By default this is sourced from the focused RStudio window or
#' the calling command (e.g. Rscript script_name.R)
#'
#' @param script_name optional arg to override the calling script
#' @importFrom magrittr "%>%"
#' @importFrom rlang .data
#' @export
set_script_name <- function(script_name = "") {
  if (script_name == "") {
    # adapted from https://stackoverflow.com/a/55322344
    script_name <- commandArgs() %>%
      tibble::enframe(name = NULL) %>%
      tidyr::separate(col = .data$value, into = c("key", "value"), sep = "=", fill = "right") %>%
      dplyr::filter(.data$key == "--file") %>%
      dplyr::pull(.data$value)

    if (length(script_name) == 0) {
      if (rstudioapi::isAvailable()) {
        script_name <- rstudioapi::getSourceEditorContext()$path %>%
          basename()
      }
    }
  }

  assign(
    "script_name",
    script_name,
    envir = redcapcustodian.env
  )
}

#' Sets the package-scoped value of script_run_time
#'
#' @param fake_runtime An asserted script run time
#' @return the package-scoped value of script_run_time
#'
#' @export
#' @examples
#' set_script_run_time()
#' set_script_run_time(fake_runtime =
#'                     as.POSIXct("2021-02-23 02:23:00",
#'                                tz="",
#'                                format="%Y-%m-%d %H:%M:%OS")
#'                    )
set_script_run_time <- function(fake_runtime = lubridate::NA_POSIXct_) {
  assign(
    "script_run_time",
    lubridate::with_tz(dplyr::if_else(
      is.na(fake_runtime),
      lubridate::now(),
      fake_runtime
    ),
    tzone = Sys.getenv("TIME_ZONE")
    ),
    envir = redcapcustodian.env
  )
  return(redcapcustodian.env$script_run_time)
}

#' Attempts to connect to the DB using all LOG_DB_* environment variables. Returns an empty list if a connection is established, returns an `error_list` entry otherwise.
#'
#' @param drv, an object that inherits from DBIDriver (e.g. RMariaDB::MariaDB()), or an existing DBIConnection object (in order to clone an existing connection).
#' @importFrom magrittr "%>%"
#'
#' @return An `error_list` entry
#'
#' @examples
#' \dontrun{
#'  verify_log_connectivity(RMariaDB::MariaDB())
#' }
verify_log_connectivity <- function(drv = RMariaDB::MariaDB()) {
  error <- error_list

  result <- DBI::dbCanConnect(
    drv,
    dbname = Sys.getenv("LOG_DB_NAME"),
    host = Sys.getenv("LOG_DB_HOST"),
    user = Sys.getenv("LOG_DB_USER"),
    password = Sys.getenv("LOG_DB_PASSWORD"),
    port = Sys.getenv("LOG_DB_PORT")
  )

  if (result == FALSE) {
    error <- error %>%
      tibble::add_row(message = attributes(result)$reason)
  }

  return(error)
}

#' Verifies all required environment variables are set. Returns an empty list if all necessary environment variables are set, returns a list of errors otherwise.
#'
#' @return A list of `error_list` entries.
#'
#' @examples
#' \dontrun{
#'  verify_log_env_variables()
#' }
verify_log_env_variables <- function() {
  errors <- error_list

  log_db_name <- Sys.getenv("LOG_DB_NAME")
  log_db_host <- Sys.getenv("LOG_DB_HOST")
  log_db_user <- Sys.getenv("LOG_DB_USER")
  log_db_password <- Sys.getenv("LOG_DB_PASSWORD")
  log_db_schema <- Sys.getenv("LOG_DB_SCHEMA")

  if (log_db_name == "") {
    errors <- errors %>%
      tibble::add_row(message = "LOG_DB_NAME is not set. It is required to write log entries.")
  }
  if (log_db_host == "") {
    errors <- errors %>%
      tibble::add_row(message = "LOG_DB_HOST is not set. It is required to write log entries.")
  }
  if (log_db_user == "") {
    errors <- errors %>%
      tibble::add_row(message = "LOG_DB_USER is not set. It is required to write log entries.")
  }
  if (log_db_password == "") {
    errors <- errors %>%
      tibble::add_row(message = "LOG_DB_PASSWORD is not set. It is required to write log entries.")
  }
  if (log_db_schema == "") {
    errors <- errors %>%
      tibble::add_row(message = "LOG_DB_SCHEMA is not set. It is required to write log entries.")
  }

  return(errors)
}

#' Verifies all dependencies required to write log entries.
#'
#' @param drv, an object that inherits from DBIDriver (e.g. RMariaDB::MariaDB()), or an existing DBIConnection object (in order to clone an existing connection).
#'
#' @return A list of `error_list` entries.
#'
#' @examples
#' \dontrun{
#'  verify_log_dependencies(
#'      drv = RMariaDB::MariaDB()
#'  )
#' }
verify_log_dependencies <- function(drv = RMariaDB::MariaDB()) {
  errors <- error_list

  can_connect <- verify_log_connectivity(drv)
  all_env_set <- verify_log_env_variables()

  errors <- vctrs::vec_c(can_connect, all_env_set)

  return(errors)
}

#' Write an error log entry
#'
#' @param conn, a DB connection
#' @param target_db_name, the database to write to
#' @param table_written, the table that was written to
#' @param df, the data to write
#' @param pk_col, the dataframe col to use as the primary_key
#' @export
#'
#' @examples
#' \dontrun{
#'  write_error_log_entry(
#'    conn = con,
#'    target_db_name = rc_case,
#'    table_written = "cases"
#'    df = data_written,
#'    pk_col = "record_id",
#'  )
#' }
write_error_log_entry <- function(conn, target_db_name, table_written = NULL, df, pk_col) {
  missing_dependencies <- verify_log_dependencies()
  tryCatch({
    stopifnot(nrow(missing_dependencies) == 0)

    df_to_write <- build_formatted_df_from_result(df, target_db_name, table_written, "ERROR", pk_col)
    write_to_sql_db(
      conn = conn,
      table_name = "etl_log",
      df_to_write = df_to_write,
      schema = Sys.getenv("LOG_DB_SCHEMA"),
      overwrite = FALSE,
      db_name = Sys.getenv("LOG_DB_NAME"),
      append = TRUE
    )
  },
  error = function(cond) {
    # TODO improve error output
    print(paste0("Failed to write error log entry:", cond))
    if (nrow(missing_dependencies > 0)) {
      print(paste0("Missing dependencies:",missing_dependencies))
    }
  })
}

#' Write an info log entry
#'
#' @param conn, a DB connection
#' @param target_db_name, the database to write to
#' @param table_written, the table that was written to
#' @param df, the data to write
#' @param pk_col, the dataframe col to use as the primary_key
#'
#' @export
#'
#' @examples
#' \dontrun{
#'  write_info_log_entry(
#'    conn = con,
#'    target_db_name = rc_case,
#'    table_written = "cases",
#'    df = data_written,
#'    pk_col = "record_id",
#'  )
#' }
write_info_log_entry <- function(conn, target_db_name, table_written = NULL, df, pk_col) {
  missing_dependencies <- verify_log_dependencies()
  tryCatch({
    stopifnot(nrow(missing_dependencies) == 0)

    df_to_write <- build_formatted_df_from_result(df, target_db_name, table_written, "INFO", pk_col)
    write_to_sql_db(
      conn = conn,
      table_name = "etl_log",
      df_to_write = df_to_write,
      schema = Sys.getenv("LOG_DB_SCHEMA"),
      overwrite = FALSE,
      db_name = Sys.getenv("LOG_DB_NAME"),
      append = TRUE
    )
  },
  error = function(cond) {
    # TODO improve error output
    print(paste0("Failed to write info log entry:", missing_dependencies))
  })
}
