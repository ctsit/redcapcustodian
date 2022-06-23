# Set a package-scoped environment for "global" vars on package load
redcapcustodian.env <- new.env(parent = emptyenv())

# Standardized error message tibble
error_list <- dplyr::tibble(
  message = character()
)

#' Builds formatted rcc_job_log data frame from source data
#'
#' @param job_duration, the job duration in seconds
#' @param job_summary, the summary of the job performed
#' @param level, the log level (DEBUG, ERROR, INFO)
#'
#' @return df_etl_log_job, the df matching the rcc_job_log table
#'
#' @examples
#' \dontrun{
#'  build_etl_job_log_df(
#'    job_duration,
#'    job_summary
#'    level,
#'  )
#' }
build_etl_job_log_df <- function(job_duration, job_summary, level) {
  log_data <- dplyr::tribble(
    ~job_duration, ~ job_summary_data, ~ level,
    job_duration, job_summary, level
  ) %>%
  dplyr::mutate(
    log_date = get_current_time(),
    script_name = get_script_name(),
    script_run_time = get_script_run_time(),
    job_duration = .data$job_duration,
    job_summary_data = .data$job_summary_data,
    level = .data$level
  )

  return(log_data)
}

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

#' Connect to the log db
#'
#' @param drv, an object that inherits from DBIDriver (e.g. RMariaDB::MariaDB()), or an existing DBIConnection object (in order to clone an existing connection).
#' @param continue_on_error if TRUE then continue execution on error, if FALSE then quit non interactive sessions on error
#' @return An S4 object. Run ?dbConnect for more information
#' @examples
#'
#' \dontrun{
#' # connect to log db using LOG_DB_* environment variables
#' con <- connect_to_log_db()
#'
#' # connect to sqlite log db
#' con <- connect_to_log_db(drv = RSQLite::SQLite())
#' }
#' @export
connect_to_log_db <- function(drv, continue_on_error = FALSE) {
  return(connect_to_db(drv = drv, prefix = "LOG", continue_on_error = continue_on_error))
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

#' Initialize the connection to the log db and set redcapcustodian.env$log_con
#'
#' @param drv, an object that inherits from DBIDriver (e.g. RMariaDB::MariaDB()), or an existing DBIConnection object (in order to clone an existing connection).
#'
#' @examples
#' \dontrun{
#'  # use a sqlite db instead
#'  init_log_con(drv = RSQLite::SQLite())
#' }
#' @export
init_log_con <- function(drv = RMariaDB::MariaDB()) {
  con <- connect_to_log_db(drv)
  set_package_scope_var("log_con", con)
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

#' Log a job debug entry
#'
#' @param summary, the job summary
#'
#' @examples
#' \dontrun{
#'  log_job_debug(
#'    summary = "Job debug step"
#'  )
#' }
#' @export
log_job_debug <- function(summary) {
  tryCatch(
    expr = {
    log_con <- get_package_scope_var("log_con")
  },
    error = function(error_message) {
      stop("redcapcustodian.env$log_con is undefined cannot call log_job_debug.")
    }
  )
  job_duration <- get_job_duration(get_script_run_time(), get_current_time())

  write_debug_job_log_entry(log_con, job_duration, summary)
}

#' Log a failed job run
#'
#' @param summary, the job summary
#'
#' @examples
#' \dontrun{
#'  log_job_failure(
#'    summary = "Job failed"
#'  )
#' }
#' @export
log_job_failure <- function(summary) {
  tryCatch(
    expr = {
      log_con <- get_package_scope_var("log_con")
    },
    error = function(error_message) {
      stop("redcapcustodian.env$log_con is undefined cannot call log_job_failure.")
    }
  )
  job_duration <- get_job_duration(get_script_run_time(), get_current_time())

  # sys.calls returns the function calls that created each existing stack frame
  # the last item in the stack trace is this function, log_job_failure, remove it
  stack_trace <- utils::head(
    paste(
      sys.calls()
    ),
    -1
  )

  error_log_json <- rjson::toJSON(
    list(
      "error_message" = summary,
      stack_trace = stack_trace
    )
  )

  write_error_job_log_entry(log_con, job_duration, error_log_json)
}

#' Log a successful job run
#'
#' @param summary, the job summary
#'
#' @examples
#' \dontrun{
#'  log_job_success(
#'    summary = "Job succeeded"
#'  )
#' }
#' @export
log_job_success <- function(summary) {
  tryCatch(
    expr = {
      log_con <- get_package_scope_var("log_con")
    },
    error = function(error_message) {
      stop("redcapcustodian.env$log_con is undefined cannot call log_job_success.")
    }
  )
  job_duration <- get_job_duration(get_script_run_time(), get_current_time())

  write_success_job_log_entry(log_con, job_duration, summary)
}

#' Write a debug log entry for the job
#'
#' @param con, a DB connection
#' @param job_duration, the duration of the job in seconds
#' @param job_summary, the summary of the job performed as JSON
#'
#' @examples
#' \dontrun{
#'  write_debug_job_log_entry(
#'    conn = con,
#'    job_duration = 30,
#'    job_summary = as.json("Update vaccination status")
#'  )
#' }
write_debug_job_log_entry <- function(con, job_duration, job_summary) {
  con_info <- DBI::dbGetInfo(con)
  df_to_write <- build_etl_job_log_df(job_duration, job_summary, "DEBUG")
  write_to_sql_db(
    conn = con,
    table_name = "rcc_job_log",
    df_to_write = df_to_write,
    schema = con_info$dbname,
    overwrite = FALSE,
    db_name = con_info$dbname,
    append = TRUE,
    is_log_con = TRUE
  )
}

#' Write an error log entry for the job
#'
#' @param con, a DB connection
#' @param job_duration, the duration of the job in seconds
#' @param job_summary, the summary of the job performed as JSON
#'
#' @examples
#' \dontrun{
#'  write_error_job_log_entry(
#'    conn = con,
#'    job_duration = 30,
#'    job_summary = as.json("Update vaccination status")
#'  )
#' }
write_error_job_log_entry <- function(con, job_duration, job_summary) {
  con_info <- DBI::dbGetInfo(con)
  df_to_write <- build_etl_job_log_df(job_duration, job_summary, "ERROR")
  write_to_sql_db(
    conn = con,
    table_name = "rcc_job_log",
    df_to_write = df_to_write,
    schema = con_info$dbname,
    overwrite = FALSE,
    db_name = con_info$dbname,
    append = TRUE,
    is_log_con = TRUE
  )
}

#' Write an success job log entry
#'
#' @param con, a DB connection
#' @param job_duration, the duration of the job in seconds
#' @param job_summary, the summary of the job performed as JSON
#'
#' @examples
#' \dontrun{
#'  write_success_job_log_entry(
#'    conn = con,
#'    job_duration = 30,
#'    job_summary = as.json("Update vaccination status")
#'  )
#' }
write_success_job_log_entry <- function(con, job_duration, job_summary) {
  con_info <- DBI::dbGetInfo(con)
  df_to_write <- build_etl_job_log_df(job_duration, job_summary, "SUCCESS")
  write_to_sql_db(
    conn = con,
    table_name = "rcc_job_log",
    df_to_write = df_to_write,
    schema = con_info$dbname,
    overwrite = FALSE,
    db_name = con_info$dbname,
    append = TRUE,
    is_log_con = TRUE
  )
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
