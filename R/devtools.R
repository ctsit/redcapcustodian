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

#' Converts a MySQL schema file to a sqlite schema.
#' Facilitates easier creation of in-memory (i.e. sqlite) tables.
#'
#' @param schema_file_path, the path of the schema file to convert
#'
#' @importFrom magrittr "%>%"
#'
#' @return the translated schema as a character string
#'
#' @examples
#' \dontrun{
#' mem_conn <- DBI::dbConnect(RSQLite::SQLite(), dbname = ":memory:")
#' translated_schema <- convert_schema_to_sqlite("~/documents/my_cool_schema.sql")
#' DBI::dbSendQuery(mem_conn, schema)
#' }
#' @export
convert_schema_to_sqlite <- function(schema_file_path) {
  pl_to_sqlite <- system.file("", "to_sqlite.pl", package = "redcapcustodian")

  if (!file.exists(schema_file_path)) {
    stop(paste("Schema file does not exist at", schema_file_path))
  }
  # TODO: consider supporting raw SQL input, assume raw sql given if file does not exist
  # raw_sql <- readr::read_file(schema_file_path)
  # cmd <- echo "${raw_sql}" | perl to_sqlite.pl

  # convert to sqlite
  cmd <- paste("cat", schema_file_path, "|", "perl", pl_to_sqlite)

  result <- system(cmd, intern = TRUE) %>% paste(collapse = "")
  return(result)
}

#' mutate_columns_to_posixct
#'
#' Mutates column data types to POSIXct.
#' Especially useful when working with in-memory tables where dates are often converted to int.
#'
#' @param data - a dataframe to mutate
#' @param column_names - a vector of column names to mutate
#'
#' @return The input dataframe with revised data types
#' @export
#'
#' @importFrom magrittr "%>%"
#' @importFrom rlang .data
#'
#' @examples
#' \dontrun{
#' time_columns <- c("created", "updated")
#' mutate_columns_to_posixct(data, time_columns)
#' }
#' @export
mutate_columns_to_posixct <- function(data, column_names) {
  result <- data %>%
    dplyr::mutate(dplyr::across(
      dplyr::any_of(column_names),
      ~ as.POSIXct(., origin = "1970-01-01 00:00.00 UTC", tz = "UTC")
    ))

  return(result)
}

#' @title copy_entire_table_to_db
#' @description Copy and entire DBI table from one DBI connection to another.
#'   This is a developer tool designed as an aid to testing and development.
#'   It designed to be called via \code{purrr::walk2()} to clone sets of tables in
#'   a data-driven way to an ephemeral database created, generally with Duck
#'   DB.
#'
#'   \strong{Limitations}
#'
#'   \itemize{
#'     \item The table referenced in \code{table_name} must not exist on \code{target_conn}.
#'     \item This function is suitable for cloning small tables.
#'     \item When called via \code{purrr::walk2()}, all tables in the vector of
#'     table names will be copied to the single \code{target_conn} DBI object
#'     even if the source table is on different \code{source_conn} DBI objects.
#'   }
#' @param source_conn - the DBI connection object that holds the source table
#' @param table_name - the name of the table to be copied
#' @param target_conn - the DBI connection object to which the table will
#'   be copied
#'
#' @return No result
#' @export
#'
#' @examples
#' # Build the objects need for testing
#' test_data <- dplyr::tribble(
#'   ~a, ~b, ~c, ~d,
#'   "asdf", 1, TRUE, lubridate::ymd_hms("2023-01-14 12:34:56"),
#'   "qwer", 2, FALSE, lubridate::ymd_hms("2016-01-14 12:34:56")
#' )
#' table_name <- "test_data"
#' source_conn <- DBI::dbConnect(duckdb::duckdb(), dbdir = ":memory:")
#' DBI::dbWriteTable(conn = source_conn, name = table_name, value = test_data)
#'
#' # copy the table
#' target_conn <- DBI::dbConnect(duckdb::duckdb(), dbdir = ":memory:")
#' copy_entire_table_to_db(
#'   source_conn = source_conn,
#'   table_name = table_name,
#'   target_conn = target_conn
#' )
#'
#' dplyr::collect(dplyr::tbl(target_conn, table_name))
#'
#' \dontrun{
#' library(tidyverse)
#' library(lubridate)
#' library(dotenv)
#' library(DBI)
#' library(RMariaDB)
#' library(redcapcustodian)
#'
#' init_etl("my_script_name")
#'
#' rc_conn <- connect_to_redcap_db()
#' log_conn <- get_package_scope_var("log_con")
#'
#' # describe the tables you want to clone
#' test_tables <- tribble(
#'   ~conn, ~table,
#'   rc_conn, "redcap_user_information",
#'   rc_conn, "redcap_projects",
#'   log_conn, "redcap_summary_metrics"
#' )
#'
#' # make the target DB and clone the tables
#' target_conn <- DBI::dbConnect(
#'   duckdb::duckdb(),
#'   dbdir = ":memory:"
#' )
#' purrr::walk2(
#'   test_tables$conn,
#'   test_tables$table,
#'   copy_table_to_db,
#'   target_conn
#' )
#'
#' # Enumerate the tables you copied if you like
#' DBI::dbListTables(target_conn)
#'
#' # replace original connection objects
#' rc_conn <- target_conn
#' log_conn <- target_conn
#'
#' # At this point you can do destructive things on the original
#' #   connection objects because they point at the ephemeral
#' #   copies of the tables.
#' }
copy_entire_table_to_db <- function(source_conn, table_name, target_conn) {
  dplyr::tbl(source_conn, table_name) %>%
    dplyr::collect() %>%
    DBI::dbWriteTable(conn = target_conn, name = table_name, value = .)
}
