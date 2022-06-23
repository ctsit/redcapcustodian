#' Connect to db
#'
#' @param drv, an object that inherits from DBIDriver (e.g. RMariaDB::MariaDB()), or an existing DBIConnection object (in order to clone an existing connection).
#' @param prefix, the
#' @param continue_on_error if TRUE then continue execution on error, if FALSE then quit non interactive sessions on error
#' @return An S4 object. Run ?dbConnect for more information
#' @examples
#' \dontrun{
#' # connect to db using [prefix]_DB_* environment variables
#' con <- connect_to_db(drv = RMariaDB::MariaDB(), prefix = "RCC")
#'
#' # connect to sqlite db
#' con <- connect_to_db(drv = RSQLite::SQLite())
#' }
#' @export
connect_to_db <- function(drv, prefix = "", continue_on_error = FALSE) {
    # might not be necessary
    # if (!inherits(drv, "DBIDriver")) {
    #     stop("Invalid DBIDriver")
    # }

    db_name <- Sys.getenv(paste0(prefix, "_DB_NAME"))
    host <- Sys.getenv(paste0(prefix, "_DB_HOST"))
    user <- Sys.getenv(paste0(prefix, "_DB_USER"))
    password <- Sys.getenv(paste0(prefix, "_DB_PASSWORD"))

    result <- tryCatch(
        expr = {
            DBI::dbConnect(
                drv = drv,
                dbname = db_name,
                host = host,
                user = user,
                password = password,
            )
        },
        error = function(error_message) {
            message <- paste(
                "Failed to connect to log DB:", db_name,
                "\nThe reason given was:\n", error_message
            )

            if (interactive()) {
                warning(message)
            } else if (!continue_on_error) {
                quit_non_interactive_run()
            }

            return(FALSE)
        }
    )

    return(result)
}
