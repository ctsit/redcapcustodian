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
  res <- DBI::dbSendQuery(conn, schema)
  # close result set to avoid warning
  DBI::dbClearResult(res)

  # Populate table
  if (!empty) {
    table_file_name <- dplyr::if_else(is.na(data_file), paste0(table_name, ".csv"), data_file)
    table_data <- readr::read_csv(file=system.file("testdata", table_file_name, package = "redcapcustodian"),
                                  na = c("", "NA", "NULL"))
    DBI::dbAppendTable(conn=conn,
                  name=table_name,
                  value=table_data
    )
  }
}


#' Provides a list of table names which have schema and data files as part of the package
#'
#' @return A list of table names which have schema and data files as part of the package
#' @export
#'
#' @examples
#' get_test_table_names()
get_test_table_names <- function() {
  table_names <- c(
    "redcap_projects",
    "redcap_user_information"
  )
  return (table_names)
}


#' A wrapper around \code{\link{create_test_table}} to create all tables, or a specified subset of them
#'
#' @param conn A DBI Connection object
#' @param table_names A character list of the names of all tables you wish
#' to create, if nothing is provided, the result of
#' \code{\link{get_test_table_names}} will be used to create all test tables
#'
#' @return NA
#' @export
#'
#' @examples
#' \dontrun{
#' conn <- dbConnect(RSQLite::SQLite(), dbname = ":memory:")
#' create_test_tables(conn) # create all test tables
#'
#' }
create_test_tables <- function(conn, table_names = c()) {
  if (length(table_names) == 0) {
    table_names <- get_test_table_names()
  }

  purrr::pmap(
    .l  = list(
      "conn" = c(conn),
      "table_name" = c(table_names)
    ),
    .f = create_test_table
  )

}
