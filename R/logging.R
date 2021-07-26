# Set a package-scoped environment for "global" vars on package load
redcapcustodian.env <- new.env(parent = emptyenv())

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
    dplyr::mutate(record_level_data = purrr::pmap(., ~ rjson::toJSON(c(...)))) %>%
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
  return (current_time)
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
#' @export
set_script_name <- function(script_name = "") {
  key <- value <- NULL
  if (script_name == "") {
    # adapted from https://stackoverflow.com/a/55322344
    script_name <- commandArgs() %>%
      tibble::enframe(name=NULL) %>%
      tidyr::separate(col=value, into=c("key", "value"), sep="=", fill='right') %>%
      dplyr::filter(key == "--file") %>%
      dplyr::pull(value)

    if (length(script_name) == 0) {
      if(rstudioapi::isAvailable()) {
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

#' Write an error log entry
#'
#' @param con, a DB connection
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
write_error_log_entry <- function(con, target_db_name, table_written = NULL, df, pk_col) {
  df_to_write <- build_formatted_df_from_result(df, target_db_name, table_written, "ERROR", pk_col)
  write_to_sql_db(
    conn = con,
    table_name = "etl_log",
    df_to_write = df_to_write,
    schema = Sys.getenv("LOG_DB_SCHEMA"),
    overwrite = FALSE,
    db_name = Sys.getenv("LOG_DB_NAME"),
    append = TRUE
  )
}

#' Write an info log entry
#'
#' @param con, a DB connection
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
#'    conn = conn,
#'    target_db_name = rc_case,
#'    table_written = "cases",
#'    df = data_written,
#'    pk_col = "record_id",
#'  )
#' }
write_info_log_entry <- function(con, target_db_name, table_written = NULL, df, pk_col) {
  df_to_write <- build_formatted_df_from_result(df, target_db_name, table_written, "INFO", pk_col)
  write_to_sql_db(
    conn = con,
    table_name = "etl_log",
    df_to_write = df_to_write,
    schema = Sys.getenv("LOG_DB_SCHEMA"),
    overwrite = FALSE,
    db_name = Sys.getenv("LOG_DB_NAME"),
    append = TRUE
  )
}
