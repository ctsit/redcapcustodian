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
