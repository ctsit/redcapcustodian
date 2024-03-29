#' get_project_life_cycle
#'
#' @description
#' get_project_life_cycle runs speedy queries against the REDCap log event
#' tables to get all of the events in the life cycle of every project on
#' the system.
#'
#' @details
#' The redcap_log_event table is among the largest redcap tables. In the test
#' instance where this script was developed, it had 2.2m rows The production system
#' had 29m rows in the corresponding redcap_data table. A row count in the
#' millions is completely normal.
#'
#' The fastest way to query is to query for `object_type == "redcap_projects"`.
#' What's more, this query can then be filtered by `ts >= start_date`` to make
#' it even faster and to allow incremental queries. This comes at a small
#' cost because these descriptions are not included when searching for
#' `object_type == "redcap_projects"`:
#'
#' \itemize{
#'   \item Create project (API)
#'   \item Create project folder
#'   \item Delete project bookmark
#'   \item Send request to copy project
#'   \item Send request to create project
#'   \item Send request to delete project
#'   \item Send request to move project to production status
#' }
#'
#' Among other things, their loss means we cannot tell who requested things or
#' when they requested it.
#'
#' Deletion Events Notes
#'
#' Every project deletion is composed of multiple events. The simplest event
#' is a deletion by a user followed by a permanent deletion by the system via
#' a cron job 30 days later. While admins can always do this, users are only
#' allowed to delete non-production projects. For production projects, users
#' must submit a request to delete.  An admin then deletes the project.  30
#' days later the system will permanently delete the project via a cron job.
#' As a project can be undeleted before the permanent deletion and/or changes
#' status, the above sequences can have sub-loops and intermingle.
#'
#' To address who wanted a project deleted and got it done, one must find the
#' last "Send request to delete project" or "Delete project" event to get the
#' username and the "Permanently delete project" event to verify the deletion.
#' If both a request and a delete event precede the "Permanently delete
#' project" event, the username on the request should be consider the
#' deleter. The admin who executed the task is just the custodian.
#'
#' @param rc_conn - a DBI connection to a REDCap database
#' @param start_date - an optional minimum date for query results
#' @param cache_file - an optional path to the cache_file. Defaults to NA.
#' @param read_cache - a boolean to indicate if the cache should be read. Defaults to TRUE
#'
#' @return - a dataframe of redcap_log_event rows with these added columns:
#' \itemize{
#'   \item `log_event_table` an index for the event table read
#'   \item `event_date` a date object for the event
#'   \item `description_base_name` The description with project or report level details removed
#' }
#'
#' @export
#'
#' @examples
#' \dontrun{
#' project_life_cycle <- get_project_life_cycle(rc_conn = rc_conn, read_cache = TRUE)
#' }
get_project_life_cycle <- function(rc_conn,
                                   start_date = as.Date(NA),
                                   cache_file = NA_character_,
                                   read_cache = TRUE) {

  get_project_life_cycle_by_log_table <- function(log_event_table_name, rc_conn, start_date) {

    if(is.na(start_date)) {
      project_life_cycle_from_one_table <- dplyr::tbl(rc_conn, log_event_table_name) %>%
        dplyr::filter(.data$object_type == "redcap_projects") %>%
        dplyr::collect() %>%
        dplyr::mutate(event_date = lubridate::ymd(stringr::str_sub(.data$ts, start = 1, end = 8)))
    } else {
      minimum_ts <- format(start_date, "%Y%m%d%H%M%S") %>% as.numeric()
      project_life_cycle_from_one_table <- dplyr::tbl(rc_conn, log_event_table_name) %>%
        dplyr::filter(.data$object_type == "redcap_projects") %>%
        dplyr::filter(.data$ts >= minimum_ts) %>%
        dplyr::collect() %>%
        dplyr::mutate(event_date = lubridate::ymd(stringr::str_sub(.data$ts, start = 1, end = 8)))
    }

    # pid <- project_life_cycle_from_one_table %>%summarise(min = min(project_id)) %>% pull(min)
    # saveRDS(project_life_cycle_from_one_table, file = paste0("output/", pid, ".rds"))

    return(project_life_cycle_from_one_table)
  }

  if (read_cache & fs::file_exists(cache_file)) {
    project_life_cycle <- readRDS(cache_file)
  } else {
    project_life_cycle <-
      project_life_cycle <- purrr::map_dfr(
        redcapcustodian::log_event_tables,
        get_project_life_cycle_by_log_table,
        rc_conn,
        start_date,
        .id = "log_event_table"
      ) %>%
      dplyr::mutate(log_event_table = as.numeric(.data$log_event_table)) %>%
      dplyr::mutate(description_base_name = .data$description) %>%
      dplyr::mutate(description_base_name = stringr::str_replace_all(.data$description_base_name, "\n", "  ")) %>%
      dplyr::mutate(description_base_name = stringr::str_replace(.data$description_base_name, "^Copy project as PID.*", "Copy project as")) %>%
      dplyr::mutate(description_base_name = stringr::str_replace(.data$description_base_name, "^Copy project from PID.*", "Copy project from")) %>%
      dplyr::mutate(description_base_name = stringr::str_replace(.data$description_base_name, "^Copy report \\(report.*", "Copy report")) %>%
      dplyr::mutate(description_base_name = stringr::str_replace(.data$description_base_name, "^Create report \\(report.*", "Create report")) %>%
      dplyr::mutate(description_base_name = stringr::str_replace(.data$description_base_name, "^Delete report \\(report.*", "Delete report")) %>%
      dplyr::mutate(description_base_name = stringr::str_replace(.data$description_base_name, "^Edit report \\(report.*", "Edit report")) %>%
      dplyr::mutate(description_base_name = stringr::str_replace(.data$description_base_name, "^Permanently delete project.*", "Permanently delete project"))
    # Write to the cache if there is a cache_file path
    fs::path
    if (!is.na(cache_file)) {
      saveRDS(project_life_cycle, file = cache_file)
    }
  }

  return(project_life_cycle)
}
