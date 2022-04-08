#' Write to a MySQL Database with error checking and email alerting on failure
#'
#' @param conn a DBI database connection
#' @param table_name name of the table to write to
#' @param df_to_write data frame we will write to _table_name_
#' @param schema database we will write to
#' @param overwrite a logical that controls whether we will overwrite the table
#' @param db_name the name of the database written to
#' @param is_log_con if FALSE then log failures, if TRUE then do not attempt to log errors
#' @param continue_on_error if TRUE then continue execution on error, if FALSE then quit non interactive sessions on error
#' @param ... Additional parameters that will be passed to DBI::dbWriteTable
#'
#' @return No value is returned
#' @export
#'
#' @examples
#' \dontrun{
#' write_to_sql_db(
#'   conn = con,
#'   table_name = "my_table",
#'   df_to_write = rule_output,
#'   schema = Sys.getenv("ETL_DB_SCHEMA"),
#'   overwrite = FALSE,
#'   db_name = Sys.getenv("ETL_DB_NAME")
#'   append = TRUE
#' )
#' }
write_to_sql_db <- function(
  conn,
  table_name,
  df_to_write,
  schema,
  overwrite,
  db_name,
  is_log_con = FALSE,
  continue_on_error = FALSE,
  ...) {

  # CTSIT team specific check.
  # Safety measure for interactive sessions
  #if (interactive() && !get0('write_to_prod', ifnotfound = FALSE)) {
  #  table_name = paste0(table_name, "_test")
  #  print("write_to_prod not set to True, appending '_test' to table_name before write")
  #}

  result <- tryCatch(
    expr = {
      DBI::dbWriteTable(
        conn = conn,
        name = table_name,
        value = df_to_write,
        schema = schema,
        overwrite = overwrite,
        ...
      )
    },
    error = function(error_message) {
      message <- paste(
        "Failed to write", table_name, "to SQL DB:", db_name,
        "\nThe reason given was:\n", error_message
      )

      email_subject <- paste(
        "FAILED |", get_script_name(), "|",
        Sys.getenv("INSTANCE"), "|", get_script_run_time()
      )

      #send_upload_email(message, email_subject)

      if (interactive()) {
        # write_to_sql_db is called from log_job_debug
        # calling log_job_failure on a log connection will result in and endless function call loop
        if (!is_log_con) {
          log_job_failure(message)
        }
        warning(message)
      } else if (!continue_on_error) {
        # write_to_sql_db is called from log_job_failure
        # calling log_job_failure on a log connection will result in and endless function call loop
        if (!is_log_con) {
          log_job_failure(message)
        }
        quit_non_interactive_run()
      }
    }
  )
}
