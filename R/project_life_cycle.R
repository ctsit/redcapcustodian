#' get_project_life_cycle
#'
#' The redcap_log_event table is among the largest redcap tables. In the test
#' instance where this script was developed it had 2.2m rows The production system
#' had 29m rows in the corresponding redcap_data table. A row count in the
#' millions is completely normal. Fortunately, project history is easy to
#' extract by querying for a specific of list description and that field is
#' indexed:
#'
#'   description
#'     description is indexed by default
#'     description has a cardinality of 1076
#'     description like "%delete%project%" represents 0.07% of the 2.2 million rows
#'
#' Deletion Events
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
#' All that said, the query for the large list of descriptions is very slow.
#' A much faster query is to query for `object_type == "redcap_projects"`.
#' What's more, this query can then be filtered by `ts >= start_date`` to make
#' it even faster and to allow incremental queries. This comes at a small
#' cost because these descriptions are not are not included when searching for
#' `object_type == "redcap_projects"`:
#'
#'   Create project (API)
#'   Create project folder
#'   Delete project bookmark
#'   Send request to copy project
#'   Send request to create project
#'   Send request to delete project
#'   Send request to move project to production status
#'
#' Among other things, their loss means we cannot tell who requested things or
#' when they requested it.
#'
#' @param rc_conn - a DBI connection to a REDCap database
#' @param start_date - an optional minimum date for query results
#' @param cache_file - an optional path to the cache_file. Defaults to NA.
#' @param read_cache - a boolean to indicate if the cache should be read. Defaults to TRUE
#'
#' @return - a dataframe of redcap_log_event rows with added columns `log_event_table` (an index) and `event_date`
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
        dplyr::arrange(.data$project_id, .data$ts) %>%
        dplyr::collect() %>%
        dplyr::filter(.data$description %in% !!redcapcustodian::project_life_cycle_descriptions) %>%
        dplyr::mutate(event_date = lubridate::ymd(stringr::str_sub(.data$ts, start = 1, end = 8)))
    } else {
      minimum_ts <- format(start_date, "%Y%m%d%H%M%S") %>% as.numeric()
      project_life_cycle_from_one_table <- dplyr::tbl(rc_conn, log_event_table_name) %>%
        dplyr::filter(.data$object_type == "redcap_projects") %>%
        dplyr::filter(.data$ts >= minimum_ts) %>%
        dplyr::arrange(.data$project_id, .data$ts) %>%
        dplyr::collect() %>%
        dplyr::filter(.data$description %in% !!redcapcustodian::project_life_cycle_descriptions) %>%
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
      dplyr::mutate(log_event_table = as.numeric(.data$log_event_table))
    # Write to the cache if there is a cache_file path
    fs::path
    if (!is.na(cache_file)) {
      saveRDS(project_life_cycle, file = cache_file)
    }
  }

  return(project_life_cycle)
}
