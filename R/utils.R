utils::globalVariables(".")

#' Prevent \code{\link{quit_non_interactive_run}} from quitting.
#' This is not meant to be used outside of tests. See test-write.R for an example.
#'
#' @export
#'
#' @examples
#' \dontrun{
#'  disable_non_interactive_quit()
#'}
disable_non_interactive_quit <- function() {
  Sys.setenv("NON_INTERACTIVE_QUIT_ENABLED" = FALSE)
}

#' Provide the exact length of the time span between start time and end time
#'
#'
#' @param start_time, a lubridate::duration object representing the start time
#' @param end_time, a lubridate::duration object representing the end time
#'
#' @return the exact length of the time span between start time and end time
#' @export
#' @examples
#' \dontrun{get_job_duration(get_script_run_time(),get_current_time()}
#'
get_job_duration <- function(start_time, end_time) {
  return(lubridate::time_length(end_time - start_time))
}

#' Get the value from the redcapcustodian.env environment
#'
#' @param key The identifying string to lookup
#'
#' @export
#' @examples
#' \dontrun{
#'   get_package_scope_var("hello")
#' }
get_package_scope_var  <- function(key) {
  return(get(key, redcapcustodian.env))
}

#' Initialize all etl dependencies
#'
#' @param script_name name passed to \code{\link{set_script_name}}
#' @param fake_runtime An optional asserted script run time passed to \code{\link{set_script_run_time}}, defaults to the time this function is called
#' @param log_db_drv, an object that inherits from DBIDriver (e.g. RMariaDB::MariaDB()), or an existing DBIConnection object (in order to clone an existing connection).
#'
#' @export
#' @examples
#' \dontrun{
#'   init_etl("name_of_file")
#' }
#'
init_etl <- function(script_name = "", fake_runtime = NULL, log_db_drv = RMariaDB::MariaDB()) {
  set_script_name(script_name)
  if (!is.null(fake_runtime)) {
    set_script_run_time(fake_runtime)
  } else {
    set_script_run_time()
  }
  init_log_con(log_db_drv)
}

#' Check if the provided connection is a DBI connection object
#'
#' @param con a DBI connection
#'
#' @return The result of the test
#' @export
#'
#' @examples
#' \dontrun{
#'  conn = connect_to_local_db()
#'  is_db_con(
#'    con = conn
#'  )
#'}
is_db_con <- function(con) {
  return(inherits(con, "DBIConnection"))
}

#' Check if "CI" environment variable is set to TRUE
#'
#' @return TRUE/FALSE
#'
#' @export
#'
#' @examples
#' \dontrun{
#'   is_on_ci()
#' }
#'
is_on_ci <- function() {
  return(Sys.getenv("CI") == TRUE)
}

#' Assign a value to the redcapcustodian.env environment, retrievable with \code{\link{get_package_scope_var}}
#'
#' @param key The identifying string to store as the lookup key
#' @param value The value to store
#'
#' @export
#' @examples
#' \dontrun{
#'   set_package_scope_var("hello", "world")
#'   hello <- get_package_scope_var("hello")
#' }
set_package_scope_var  <- function(key, value) {
  assign(key, value, envir = redcapcustodian.env)
}

#' Assign a value to the redcapcustodian.env environment, retrievable with \code{\link{get_package_scope_var}}
#'
#' @param key The identifying string to store as the lookup key
#' @param value The value to store
#'
#' @export
#' @examples
#' \dontrun{
#'   set_package_scope_var("hello", "world")
#'   hello <- get_package_scope_var("hello")
#' }
set_package_scope_var  <- function(key, value) {
  assign(key, value, envir = redcapcustodian.env)
}

#' Quit a non interactive R session
#'
#' @export
#' @examples
#' \dontrun{
#'   quit_non_interactive_run()
#' }
quit_non_interactive_run <- function() {
  if (interactive()) {
    warning("quit_non_interactive_run was called for an interactive session.")
  }

  if (!interactive() && isTRUE(Sys.getenv("NON_INTERACTIVE_QUIT_ENABLED"))) {
    q()
  }
}
