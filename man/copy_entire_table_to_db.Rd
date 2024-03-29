% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/devtools.R
\name{copy_entire_table_to_db}
\alias{copy_entire_table_to_db}
\title{copy_entire_table_to_db}
\usage{
copy_entire_table_to_db(source_conn, table_name, target_conn)
}
\arguments{
\item{source_conn}{- the DBI connection object that holds the source table}

\item{table_name}{- the name of the table to be copied}

\item{target_conn}{- the DBI connection object to which the table will
be copied}
}
\value{
No result
}
\description{
Copy and entire DBI table from one DBI connection to another.
  This is a developer tool designed as an aid to testing and development.
  It designed to be called via \code{purrr::walk2()} to clone sets of tables in
  a data-driven way to an ephemeral database created, generally with Duck
  DB.

  \strong{Limitations}

  \itemize{
    \item The table referenced in \code{table_name} must not exist on \code{target_conn}.
    \item This function is suitable for cloning small tables.
    \item When called via \code{purrr::walk2()}, all tables in the vector of
    table names will be copied to the single \code{target_conn} DBI object
    even if the source table is on different \code{source_conn} DBI objects.
  }
}
\examples{
# Build the objects need for testing
test_data <- dplyr::tribble(
  ~a, ~b, ~c, ~d,
  "asdf", 1, TRUE, lubridate::ymd_hms("2023-01-14 12:34:56"),
  "qwer", 2, FALSE, lubridate::ymd_hms("2016-01-14 12:34:56")
)
table_name <- "test_data"
source_conn <- DBI::dbConnect(duckdb::duckdb(), dbdir = ":memory:")
DBI::dbWriteTable(conn = source_conn, name = table_name, value = test_data)

# copy the table
target_conn <- DBI::dbConnect(duckdb::duckdb(), dbdir = ":memory:")
copy_entire_table_to_db(
  source_conn = source_conn,
  table_name = table_name,
  target_conn = target_conn
)

dplyr::collect(dplyr::tbl(target_conn, table_name))

DBI::dbDisconnect(source_conn, shutdown = TRUE)
DBI::dbDisconnect(target_conn, shutdown = TRUE)

\dontrun{
library(tidyverse)
library(lubridate)
library(dotenv)
library(DBI)
library(RMariaDB)
library(redcapcustodian)

init_etl("my_script_name")

rc_conn <- connect_to_redcap_db()
log_conn <- get_package_scope_var("log_con")

# describe the tables you want to clone
test_tables <- tribble(
  ~conn, ~table,
  rc_conn, "redcap_user_information",
  rc_conn, "redcap_projects",
  log_conn, "redcap_summary_metrics"
)

# make the target DB and clone the tables
target_conn <- DBI::dbConnect(
  duckdb::duckdb(),
  dbdir = ":memory:"
)
purrr::walk2(
  test_tables$conn,
  test_tables$table,
  copy_table_to_db,
  target_conn
)

# Enumerate the tables you copied if you like
DBI::dbListTables(target_conn)

# replace original connection objects
rc_conn <- target_conn
log_conn <- target_conn

# At this point you can do destructive things on the original
#   connection objects because they point at the ephemeral
#   copies of the tables.
}
}
