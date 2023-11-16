#' @title get_table_checksum
#'
#' @description
#' Fetch the checksum of a MySQL table accessed via DBI connection object.
#'
#' @param table_name The name of a table in the database described by `conn`
#' @param conn A DBI Connection object to a MySQL database
#'
#' @return A one row dataframe with these columns:
#' \describe{
#'   \item{host}{MySQL host name found on the DBI connection object}
#'   \item{database_name}{MySQL database name returned by the query}
#'   \item{table}{MySQL table name}
#'   \item{checksum}{checksum returned by "CHECKSUM TABLE <table_name>"}
#'   \item{elapsed_time}{elapsed time required for the query and fetch of the checksum}
#' }
#' @export
#'
#' @examples
#' \dontrun{
#' get_table_checksum("redcap_user_information", rc_conn)
#' }
get_table_checksum <- function(table_name, conn) {
  sql <- paste("CHECKSUM TABLE", table_name)

  elapsed_time <- system.time({
    query_object <- DBI::dbSendQuery(conn, sql)
    checksum_of_table <- DBI::dbFetch(query_object)
  })[3]

  result <- checksum_of_table |>
    dplyr::mutate(
      host = DBI::dbGetInfo(conn)$host,
      elapsed_time = elapsed_time,
      database_name = stringr::str_split(.data$Table, "\\.")[[1]][1],
      table = stringr::str_split(.data$Table, "\\.")[[1]][2]
    ) |>
    dplyr::select(
      "host",
      "database_name",
      "table",
      checksum = "Checksum",
      "elapsed_time"
    )

  DBI::dbClearResult(query_object)

  return(result)
}

#' @title evaluate_checksums
#'
#' @description
#' Transform the output of `get_table_checksum()` from a source and target
#' copy of a MySQL database copy operation and compare the checksums.
#'
#' @param source_checksums The output of `get_table_checksum()` for the
#'   source MySQL database of a database copy operation
#' @param target_checksums The output of `get_table_checksum()` for the
#'   target MySQL database of a database copy operation
#'
#' @return A dataframe with these columns:
#' \describe{
#'   \item{table}{MySQL table name}
#'   \item{checksum_source}{checksum of source table returned by "CHECKSUM TABLE <table_name>"}
#'   \item{checksum_target}{checksum of target table returned by "CHECKSUM TABLE <table_name>"}
#'   \item{elapsed_time_source}{elapsed time required for the query and fetch of the checksum of the source table}
#'   \item{elapsed_time_target}{elapsed time required for the query and fetch of the checksum of the target table}
#'   \item{matches}{a boolean indicating if the source and target checksums match}
#' }
#' @export
#'
#' @examples
#' \dontrun{
#' evaluate_checksums(source_checksums, target_checksums)
#' }
evaluate_checksums <- function(source_checksums, target_checksums) {
  result <-
    dplyr::bind_rows(
      source_checksums |> dplyr::mutate(copy = "source"),
      target_checksums |> dplyr::mutate(copy = "target")
    ) |>
    tidyr::pivot_wider(
      id_cols = c("table"),
      names_from = "copy",
      values_from = c("checksum", "elapsed_time")
    ) |>
    dplyr::mutate(matches = .data$checksum_source == .data$checksum_target)

  return(result)
}
