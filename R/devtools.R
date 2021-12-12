#' Create a test table from package schema and data files
#'
#' Creates tables from files in inst/testdata that match the patterns <table_name>_schema.sql and <table_name>.csv
#'
#' @param conn A DBI Connection object
#' @param table_name The name of a table used in testing
#' @param data_file The name of a file with alternative contents for `table_name`
#' @param empty A boolean to request that the table be created empty
#'
#' @return NA
#' @export
#'
#' @examples
#' \dontrun{
#' conn <- dbConnect(RSQLite::SQLite(), dbname = ":memory:")
#' create_test_table(conn, "redcap_user_information")
#'
#' }
create_test_table <- function(conn, table_name, data_file = NA_character_, empty = F) {
  # Create empty table
  schema_file_name <- paste0(table_name, "_schema.sql")
  schema <- readr::read_file(file=system.file("testdata", schema_file_name, package = "redcapcustodian"))
  DBI::dbSendQuery(conn, schema)
  # Populate table
  if (!empty) {
    table_file_name <- dplyr::if_else(is.na(data_file), paste0(table_name, ".csv"), data_file)
    table_data <- readr::read_csv(file=system.file("testdata", table_file_name, package = "redcapcustodian"))
    DBI::dbAppendTable(conn=conn,
                  name=table_name,
                  value=table_data
    )
  }
}
