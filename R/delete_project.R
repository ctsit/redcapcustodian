#' Delete a Project from REDCap
#'
#' Deletes specified projects from the REDCap system by setting the `date_deleted` field.
#' It will also log the event in the appropriate `log_event_table` for each project.
#'
#' @param project_id A project ID or vector of project IDs to be deleted.
#' @param conn A DBI connection object to the database that holds the `redcap_projects`
#'             and `redcap_log_event*` tables.
#'
#'
#' @return A list containing:
#' \itemize{
#'   \item n: the number of projects deleted
#'   \item number_rows_logged: the number of rows logged for the deletion event
#'   \item project_ids_deleted: a vector of project IDs that were deleted
#'   \item data: a data frame with each input project_id and its status after trying to delete it
#' }
#'
#' @examples
#' \dontrun{
#' conn <- DBI::dbConnect(...)
#' delete_project(c(1, 2, 3), conn)
#' }
#' @export

delete_project <- function(project_id, conn) {
  redcap_projects <- DBI::dbGetQuery(
    conn,
    sprintf(
      "select
        project_id,
        date_deleted,
        log_event_table
     from redcap_projects
     where project_id in (%s)",
      paste0(project_id, collapse = ",")
    )
  )

  projects_to_delete <- redcap_projects[is.na(redcap_projects$date_deleted), ]
  redcap_project_ids <- projects_to_delete$project_id
  redcap_log_tables <- projects_to_delete$log_event_table


  if (nrow(projects_to_delete) > 0) {
    delete_sql <- sprintf(
      "UPDATE redcap_projects SET date_deleted = NOW() WHERE project_id IN (%s)",
      paste0(redcap_project_ids, collapse = ",")
    )

    tryCatch(
      {
        deleted_projects <- DBI::dbExecute(conn, delete_sql)
      },
      error = function(error_message) {
        print(error_message)
        return(FALSE)
      }
    )

    # Define logging parameters
    ts <- format(Sys.time(), "%Y%m%d%H%M%S") # Time stamp
    user <- "admin" # Placeholder for user
    ip <- "192.168.65.1" # Placeholder for IP address
    page <- "rcc.billing::delete_abandoned_projects"
    event <- "MANAGE"
    object_type <- "redcap_projects"
    description <- "Delete project"
    legacy <- 0
    change_reason <- NULL

    tryCatch(
      {
        inserted_rows <- purrr::map2(
          redcap_log_tables,
          redcap_project_ids,
          ~ {
            pk <- .y
            data_values <- sprintf("project_id = %d", .y)

            DBI::dbExecute(
              conn,
              sprintf(
                "INSERT INTO %s
                (log_event_id, project_id, ts, user, ip, page, event,
                 object_type, sql_log, pk, event_id, data_values,
                 description, legacy, change_reason)
               VALUES
                (NULL, %d, '%s', '%s', '%s', '%s', '%s',
                 '%s', '%s', '%d', NULL, '%s',
                 '%s', %d, %s)",
                .x, # Log table
                .y, # Project ID
                ts,
                user,
                ip,
                page,
                event,
                object_type,
                delete_sql,
                pk,
                data_values,
                description,
                legacy,
                ifelse(is.null(change_reason), "NULL", sprintf("'%s'", change_reason)) # Change reason
              )
            )
          }
        )
      },
      error = function(error_message) {
        print(error_message)
        return(FALSE)
      }
    )
  } else {
    deleted_projects <- NULL
    inserted_rows <- NULL
    redcap_project_ids <- NULL
  }

  status_df <- data.frame(project_id = project_id)

  # Assign status based on conditions
  status_df$status <- ifelse(
    !status_df$project_id %in% redcap_projects$project_id,
    "does not exist",
    ifelse(
      status_df$project_id %in% projects_to_delete$project_id,
      "deleted",
      "previously deleted"
    )
  )

  result <- list(
    n = deleted_projects,
    number_rows_logged = length(inserted_rows),
    project_ids_deleted = redcap_project_ids,
    data = status_df
  )

  return(result)
}
