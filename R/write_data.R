#' Write to a MySQL Database with error checking and email alerting on failure
#'
#' @param conn a DBI database connection
#' @param table_name name of the table to write to
#' @param df_to_write data frame we will write to _table_name_
#' @param schema database we will write to
#' @param overwrite a logical that controls whether we will overwrite the table
#' @param db_name the name of the database written to
#' @param is_log_con if FALSE then log failures, if TRUE then do not attempt to log errors
#' @param continue_on_error if TRUE then continue execution on error, if FALSE then quit non interactive sessions on error
#' @param ... Additional parameters that will be passed to DBI::dbWriteTable
#'
#' @return No value is returned
#' @export
#'
#' @examples
#' \dontrun{
#' write_to_sql_db(
#'   conn = con,
#'   table_name = "my_table",
#'   df_to_write = rule_output,
#'   schema = Sys.getenv("ETL_DB_SCHEMA"),
#'   overwrite = FALSE,
#'   db_name = Sys.getenv("ETL_DB_NAME")
#'   append = TRUE
#' )
#' }
write_to_sql_db <- function(
  conn,
  table_name,
  df_to_write,
  schema,
  overwrite,
  db_name,
  is_log_con = FALSE,
  continue_on_error = FALSE,
  ...) {

  # CTSIT team specific check.
  # Safety measure for interactive sessions
  #if (interactive() && !get0('write_to_prod', ifnotfound = FALSE)) {
  #  table_name = paste0(table_name, "_test")
  #  print("write_to_prod not set to True, appending '_test' to table_name before write")
  #}

  result <- tryCatch(
    expr = {
      DBI::dbWriteTable(
        conn = conn,
        name = table_name,
        value = df_to_write,
        schema = schema,
        overwrite = overwrite,
        ...
      )
    },
    error = function(error_message) {
      message <- paste(
        "Failed to write", table_name, "to SQL DB:", db_name,
        "\nThe reason given was:\n", error_message
      )

      email_subject <- paste(
        "FAILED |", get_script_name(), "|",
        Sys.getenv("INSTANCE"), "|", get_script_run_time()
      )

      #send_upload_email(message, email_subject)

      if (interactive()) {
        # write_to_sql_db is called from log_job_debug
        # calling log_job_failure on a log connection will result in and endless function call loop
        if (!is_log_con) {
          log_job_failure(message)
        }
        warning(message)
      } else if (!continue_on_error) {
        # write_to_sql_db is called from log_job_failure
        # calling log_job_failure on a log connection will result in and endless function call loop
        if (!is_log_con) {
          log_job_failure(message)
        }
        quit_non_interactive_run()
      }
    }
  )
}


#' Write to a MySQL Database using the result of \code{\link{dataset_diff}}
#'
#' @param conn a DBI database connection
#' @param table_name name of the table to write to
#' @param primary_key name of the primary key (or vector of multiple keys) of the table to write to
#' @param data_diff_output list of dataframes returned by \code{\link{dataset_diff}}
#' @param insert boolean toggle to use the insert dataframe to insert rows in \code{table_name}
#' @param update boolean toggle to use the updates dataframe to update rows in \code{table_name}
#' @param delete boolean toggle to use the delete dataframe to delete rows in \code{table_name}
#'
#' @return a named list with these values:
#' \itemize{
#'   \item insert_n - the number of rows inserted to \code{table_name}
#'   \item update_n - the number of rows updated in \code{table_name}
#'   \item delete_n - the number of rows deleted in \code{table_name}
#' }
#' @export
#'
#' @examples
#' \dontrun{
#' conn <- connect_to_redcap_db()
#'
#'  ...
#'
#' diff_output <- dataset_diff(
#'   source = updates,
#'   source_pk = "id",
#'   target = original_table,
#'   target_pk = "id"
#' )
#'
#' sync_table(
#'   conn = con,
#'   table_name = table_name,
#'   primary_key = primary_key,
#'   data_diff_output = diff_output
#' )
#' }
sync_table <- function(
  conn,
  table_name,
  primary_key,
  data_diff_output,
  insert = F,
  update = T,
  delete = F
) {
  # TODO: consider exporting target_pk from dataset_diff
  # TODO: integrate logging
  insert_n <- 0
  update_n <- 0
  delete_n <- 0

  # TODO: detect "created/updated" and adjust values where appropriate

  if (insert) {
    insert_n <- DBI::dbAppendTable(conn, table_name, data_diff_output$insert_records)
  }

  if (update)  {
    dbx::dbxUpdate(
      conn = conn,
      table = table_name,
      records = data_diff_output$update_records,
      where_cols = primary_key
    )
    update_n <- nrow(data_diff_output$update_records)
  }

  if (delete) {
    dbx::dbxDelete(
      conn = conn,
      table = table_name,
      where = data_diff_output$delete_records
    )
    delete_n <- nrow(data_diff_output$delete_records)
  }

  result <- list(
    inserts = insert_n,
    updates = update_n,
    deletes = delete_n
  )
  return(result)
}

#' Write to a MySQL Database based on the diff of source and target datasets.
#'
#' @param conn a DBI database connection
#' @param table_name name of the table to write to
#' @param source - a dataframe with content that needs to be reflected in target
#' @param source_pk - the primary key of source
#' @param target - a data frame that needs to reflect source
#' @param target_pk - the primary key of target
#' @param insert boolean toggle to use the insert dataframe to insert rows in \code{table_name}
#' @param update boolean toggle to use the updates dataframe to update rows in \code{table_name}
#' @param delete boolean toggle to use the delete dataframe to delete rows in \code{table_name}
#'
#' @return a named list with these values:
#' \itemize{
#'   \item insert_records - a dataframe of inserts
#'   \item update_records - a dataframe of updates
#'   \item delete_records - a dataframe of deletions
#'   \item insert_n - the number of rows inserted to \code{table_name}
#'   \item update_n - the number of rows updated in \code{table_name}
#'   \item delete_n - the number of rows deleted in \code{table_name}
#' }
#' @export
#'
#' @examples
#' \dontrun{
#' conn <- connect_to_redcap_db()
#'
#'  ...
#'
#' sync_table_2(
#'   conn = con,
#'   table_name = table_name,
#'   source = updates,
#'   source_pk = "id",
#'   target = original_table,
#'   target_pk = "id"
#' )
#' }
sync_table_2 <- function(
    conn,
    table_name,
    source,
    source_pk,
    target,
    target_pk,
    insert = F,
    update = T,
    delete = F
) {
  # TODO: integrate logging
  # TODO: detect "created/updated" and adjust values where appropriate
  update_records <- source %>%
    dplyr::anti_join(target) %>%
    dplyr::inner_join(target, by=source_pk) %>%
    dplyr::select(dplyr::any_of(target_pk), dplyr::any_of(names(source)), dplyr::ends_with(".x")) %>%
    dplyr::rename_with(., ~ gsub(".x", "", .x), dplyr::ends_with(".x"))

  ids_of_update_records <- update_records %>% dplyr::pull({{target_pk}})

  if (insert) {
    insert_records <- source %>%
      dplyr::anti_join(target) %>%
      dplyr::anti_join(update_records)
    insert_n <- DBI::dbAppendTable(conn, table_name, insert_records)
  } else {
    insert_records = NA
    insert_n <- 0
  }

  if (update)  {
    dbx::dbxUpdate(
      conn = conn,
      table = table_name,
      records = update_records,
      where_cols = target_pk
    )
    update_n <- nrow(update_records)
  } else {
    update_n <- 0
    update_records = NA
  }

  if (delete) {
    delete_records <-
      target %>%
      dplyr::anti_join(source) %>%
      dplyr::filter(! (!!as.symbol(target_pk)) %in% ids_of_update_records)

    dbx::dbxDelete(
      conn = conn,
      table = table_name,
      where = delete_records
    )
    delete_n <- nrow(delete_records)
  } else {
    delete_records <- NA
    delete_n <- 0
  }

  result <- list(
    insert_records = insert_records,
    update_records = update_records,
    delete_records = delete_records,
    insert_n = insert_n,
    update_n = update_n,
    delete_n = delete_n
  )
  return(result)
}
