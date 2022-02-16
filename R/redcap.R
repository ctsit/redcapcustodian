#' Connect to the Primary REDCap MySQL Database
#' Assigns package-scoped conn
#'
#' @return An S4 object. Run ?dbConnect for more information
#'
#' @export
#' @examples
#' \dontrun{
#' conn <- connect_to_redcap_db()
#' }
connect_to_redcap_db <- function() {
  # verify the environment exists,
  # that `conn` is a member,
  # and that the DB connection is still valid
  # before disconnecting
  if (exists("redcapcustodian.env") &&
      "conn" %in% names(redcapcustodian.env) &&
      DBI::dbIsValid(redcapcustodian.env$conn)
      ) {
    conn <- redcapcustodian.env$conn
    warning(glue::glue("Disconnecting from REDCap database {dbGetInfo(conn)$host}:{dbGetInfo(conn)$dbname}, before reconnect"))
    DBI::dbDisconnect(conn)
  }

  if (Sys.getenv("REDCAP_DB_PORT") == '') port = "3306" else
    { port = Sys.getenv("REDCAP_DB_PORT") }
  conn = DBI::dbConnect(
    RMariaDB::MariaDB(),
    dbname = Sys.getenv("REDCAP_DB_NAME"),
    host = Sys.getenv("REDCAP_DB_HOST"),
    user = Sys.getenv("REDCAP_DB_USER"),
    password = Sys.getenv("REDCAP_DB_PASSWORD"),
    port = port
  )

  assign(
    "conn",
    conn,
    envir = redcapcustodian.env
  )

  return(redcapcustodian.env$conn)
}

#' Get connection to the primary REDCap database
#'
#' @return The existing connection object to the REDCap database
#'
#' @export
#' @examples
#' \dontrun{
#' conn <- get_redcap_db_connection()
#' }
get_redcap_db_connection <- function() {
  if (exists("redcapcustodian.env") &&
    "conn" %in% names(redcapcustodian.env) &&
    DBI::dbIsValid(redcapcustodian.env$conn)
  ) {
    return(redcapcustodian.env$conn)
  } else {
    warning("You have no connection!")
  }
}

#' Get all user emails in redcap_user_information as tall data
#'
#' @param conn A DBI Connection object
#'
#' @return a dataframe with these columns:
#' \itemize{
#'   \item ui_id - row_id of table
#'   \item username - REDCap username"
#'   \item email_field_name - the name of the column containing the email address
#'   \item email - the email address in email_field_name
#' }
#'
#' @export
#' @importFrom rlang .data
#' @importFrom magrittr "%>%"
#' @examples
#' \dontrun{
#' conn <- dbConnect(RSQLite::SQLite(), dbname = ":memory:")
#' create_test_table(conn, "redcap_user_information")
#' get_redcap_emails(conn)
#' }
get_redcap_emails <- function(conn) {
  redcap_email_query <- "select ui_id, username, user_email, user_email2, user_email3 from redcap_user_information"
  redcap_emails <- DBI::dbGetQuery(conn, statement = redcap_email_query) %>%
    tidyr::pivot_longer(dplyr::starts_with("user_email"),
                 names_to="email_field_name",
                 values_to="email",
                 values_drop_na = TRUE) %>%
    dplyr::filter(.data$email != "")

  return(redcap_emails)
}
