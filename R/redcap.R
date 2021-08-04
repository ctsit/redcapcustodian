#' Connect to the Primary REDCap MySQL Database
#'
#' @return An S4 object. Run ?dbConnect for more information
#'
#' @export
#' @examples
#' \dontrun{
#' con <- connect_to_redcap_db()
#' }
connect_to_redcap_db <- function() {
  if (Sys.getenv("REDCAP_DB_PORT") == '') port = "3306" else
    { port = Sys.getenv("REDCAP_DB_PORT") }
  DBI::dbConnect(
    RMariaDB::MariaDB(),
    dbname = Sys.getenv("REDCAP_DB_NAME"),
    host = Sys.getenv("REDCAP_DB_HOST"),
    user = Sys.getenv("REDCAP_DB_USER"),
    password = Sys.getenv("REDCAP_DB_PASSWORD"),
    port = port
  )
}
