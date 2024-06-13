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
#'    job_summary,
#'    level
#'  )
#' }
build_etl_job_log_df <- function(job_duration, job_summary, level) {
  log_data <- dplyr::tribble(
    ~job_duration, ~ job_summary_data, ~ level,
    job_duration, job_summary, level
  ) %>%
  dplyr::mutate(
    log_date = get_current_time(),
    project = get_project_name(),
    instance = get_project_instance(),
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
      project = get_project_name(),
      instance = get_project_instance(),
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

#' Fetches the package-scoped value of project_name
#' @export
get_project_name <- function() {
  return(redcapcustodian.env$project_name)
}

#' Fetches the package-scoped value of project_instance
#' @export
get_project_instance <- function() {
  return(redcapcustodian.env$project_instance)
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

#' Sets the package-scoped value of project_name
#'
#' @param project_name Defaults to NULL. If provided and not NULL, this value is used.
#'                     If NULL, the function attempts to fetch the value from the environment variable.
#' @return the package-scoped value of project_name

#' @examples
#' \dontrun{
#' project_name <- set_project_name()
#' project_name <- set_project_name("project_name")
#' }
#'
#' @export
set_project_name <- function(project_name = "") {
  if (project_name == "") {
    project_name <- Sys.getenv("PROJECT")
  }

  assign("project_name",
         project_name,
         envir = redcapcustodian.env)

  return(redcapcustodian.env$project_name)
}

#' Sets the package-scoped value of project_instance
#' @param project_instance Defaults to NULL. If provided and not NULL, this value is used.
#'                     If NULL, the function attempts to fetch the value from the environment variable.
#'
#' @return the package-scoped value of project_instance
#' @examples
#' \dontrun{
#' project_instance <- set_project_instance()
#' project_instance <- set_project_instance("project_instance")
#' }
#'
#' @export
set_project_instance <- function(project_instance = "") {
  if (project_instance == "") {
    project_instance <- Sys.getenv("INSTANCE")
  }

  assign("project_instance",
         project_instance,
         envir = redcapcustodian.env)

  return(redcapcustodian.env$project_instance)
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
#'    table_written = "cases",
#'    df = data_written,
#'    pk_col = "record_id"
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

#' A wrapper function that sends an email (via sendmailR) reporting the outcome of another function
#'
#' This function sends an email via `sendmailR`, optionally including a dataframe(s) or zip files(s) as attachments.
#'
#' @param email_body The contents of the email
#' @param email_subject The subject line of the email
#' @param email_to The email addresses of the primary recipient(s), separate recipient addresses with spaces
#' @param email_cc The email addresses of cc'd recipient(s), separate recipient addresses with spaces
#' @param email_from The email addresses of the sender
#' @param df_to_email (Optional) A dataframe or a list of dataframes to be included as file attachment(s). If this parameter is used, `file_name` must also be specified.
#'                    Each dataframe in the list must have a corresponding file name in the `file_name` parameter to ensure a one-to-one match between dataframes and file names.
#' @param file_name (Optional) A character vector specifying the file name(s) of the attachment(s). Valid file extensions are `.csv`, `.xlsx`, and `.zip`. Each file name must be unique.
#' @param ... Additional arguments passed directly to the file writing functions: `write.csv` for CSV files, and `writexl::write_xlsx` for XLSX files.
#'
#' @return No returned value. It performs an action by sending an email.
#' @examples
#'
#' \dontrun{
#' email_body <- paste("Failed REDCap data import to", project_title,
#'                   "\nThe reason given was:", error_message)
#'
#' email_subject <- paste("FAILED |", script_name, "|",
#'                         Sys.getenv("INSTANCE"), "|", script_run_time)
#'
#' # email without attachemnts
#' send_email(email_body, email_subject)
#'
#' email_to <- c("email1@example.com email2@example.com")
#' dfs_to_email <- list(head(cars), tail(cars))
#' file_names <- c("file1.csv", "file2.xlsx")
#'
#' # single attachment and at least one email address
#' send_email(
#'   email_subject = email_subject,
#'   email_body = email_body,
#'   email_from = email_from,
#'   email_to = email_to,
#'   df_to_email = head(cars),
#'   file_name = "file1.csv"
#' )
#'
#' # multiple attachments and at least one email address
#' send_email(
#'   email_subject = email_subject,
#'   email_body = email_body,
#'   email_from = email_from,
#'   email_to = email_to,
#'   df_to_email = dfs_to_email,
#'   file_name = file_names
#' )
#'
#' send_email(
#'   email_subject = email_subject,
#'   email_body = email_body,
#'   email_from = email_from,
#'   email_to = email_to,
#'   file_name = c("file1.zip", "<path_to_file>file2.zip")
#' )
#'
#' # single attachment for each email group
#' email_to <- c("email1@example.com", c("email2@example.com email3@example.com"))
#'
#' args_list <- list(
#'   email_subject = email_subject,
#'   email_body = email_body,
#'   email_to = email_to,
#'   email_from = email_from,
#'   df_to_email = dfs_to_email,
#'   file_name = file_names
#' )
#'
#' purrr::pmap(args_list, send_email)
#'
#' # multiple attachments for each email group
#' email_to <- c(
#'   c("email1@example.com email2@example.com"),
#'   c("email3@example.com email4@example.com")
#' )
#'
#' args_list <- list(
#'   email_subject = email_subject,
#'   email_body = email_body,
#'   email_to = email_to,
#'   email_from = email_from,
#'   df_to_email = list(dfs_to_email, dfs_to_email),
#'   file_name = list(file_names, file_names)
#' )
#'
#' purrr::pmap(args_list, send_email)
#'
#' }
#' @importFrom sendmailR "sendmail"
#' @importFrom openxlsx write.xlsx
#' @export
send_email <-
  function(email_body,
           email_subject = "",
           email_to = "",
           email_cc = "",
           email_from = "",
           df_to_email = NULL,
           file_name = NULL,
           ...
  ) {

    email_server <- list(smtpServer = Sys.getenv("SMTP_SERVER"))
    if (email_from == "") {
      email_from <- Sys.getenv("EMAIL_FROM")
    }
    if (email_cc == "") {
      email_cc <- unlist(strsplit(Sys.getenv("EMAIL_CC"), " "))
    } else {
      email_cc <- unlist(strsplit(email_cc, " "))
    }
    if (email_subject == "") {
      email_subject <-
        paste(Sys.getenv("EMAIL_SUBJECT"), get_script_run_time())
    }

    if (email_to == "") {
      email_to <- unlist(strsplit(Sys.getenv("EMAIL_TO"), " "))
    } else {
      email_to <- unlist(strsplit(email_to, " "))
    }

    email_content <- email_body

    if (!is.null(file_name)) {
      output_dir <- tempdir()

      if (!is.null(df_to_email) && is.data.frame(df_to_email)) {
        df_to_email <- list(df_to_email)
      }

      if (!is.null(df_to_email) &&
          length(df_to_email) != length(file_name)) {
        stop("The number of dataframes and file names must match.")
      }

      for (i in seq_along(file_name)) {
        file_extension <- tolower(sub(".*\\.(.*)$", "\\1", file_name[[i]]))
        file_fullpath <- file.path(output_dir, basename(file_name[[i]]))

        if (!is.null(df_to_email)) {
          if (file_extension == "csv") {
            readr::write_csv(df_to_email[[i]], file_fullpath, ...)
          } else if (file_extension == "xlsx") {
            openxlsx::write.xlsx(df_to_email[[i]], file_fullpath, ...)
          } else {
            stop("Unsupported file format. Use 'csv' or 'xlsx'.")
          }
        }

        if (file_extension == "zip" &&
            !file.copy(file_name[[i]], output_dir, overwrite = TRUE)) {
          stop(paste("Failed to move", file_name[[i]]))
        }

        attachment_object <- sendmailR::mime_part(file_fullpath, basename(file_fullpath))
        email_content <- c(email_content, attachment_object)
      }
    }

    ## TODO: consider toggling bypass of printing if interactive and local env detected
    ## if (interactive()) {
    ##   print(email_body)
    ##   return(email_body)
    ## }
    # TODO: consider replacing sendmailR with mRpostman
    sendmailR::sendmail(
      from = email_from,
      to = email_to,
      cc = email_cc,
      subject = email_subject,
      msg = email_content,
      control = email_server
    )
  }
