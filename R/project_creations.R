#' get_project_creations
#'
#' @description
#' get_project_creations runs speedy queries against the REDCap log event
#' tables to get every project-creation event on the system.
#'
#' @details
#' The redcap_log_event table is among the largest redcap tables. In the test
#' instance where this script was developed, it had 2.2m rows The production system
#' had 29m rows in the corresponding redcap_data table. A row count in the
#' millions is completely normal.
#'
#' redcap_log_event2 and higher have the page_project key that indexes by
#' project_id and page. That allows a speedy query of
#' page == "ProjectGeneral/create_project.php" to narrow the scope of the
#' query to project-creation events only. That index can be added to the
#' redcap_log_event table to allow a speedy query on it there as well.
#'
#' What's more, this query can then be filtered by `ts >= start_date` to make
#' it even faster and to allow incremental queries.
#'
#' Because it filters on `page`, this query does not capture project creation
#' via the REDCap API: API-driven creation ("Create project (API)") does not
#' hit `ProjectGeneral/create_project.php` and so is not returned here. Use
#' `get_project_life_cycle()` if you need those events too.
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
#'   \item `description_base_name` The description with project-level details removed
#' }
#'
#' @export
#'
#' @examples
#' \dontrun{
#' project_creations <- get_project_creations(rc_conn = rc_conn, read_cache = TRUE)
#' }
get_project_creations <- function(rc_conn,
                                   start_date = as.Date(NA),
                                   cache_file = NA_character_,
                                   read_cache = TRUE) {

  get_project_creations_by_log_table <- function(log_event_table_name, rc_conn, start_date) {

    if(is.na(start_date)) {
      project_creations_from_one_table <- dplyr::tbl(rc_conn, log_event_table_name) %>%
        dplyr::filter(.data$object_type == "redcap_projects" & .data$page == "ProjectGeneral/create_project.php") %>%
        dplyr::collect() %>%
        dplyr::mutate(event_date = lubridate::ymd(stringr::str_sub(.data$ts, start = 1, end = 8)))
    } else {
      minimum_ts <- format(start_date, "%Y%m%d%H%M%S") %>% as.numeric()
      project_creations_from_one_table <- dplyr::tbl(rc_conn, log_event_table_name) %>%
        dplyr::filter(.data$object_type == "redcap_projects" & .data$page == "ProjectGeneral/create_project.php") %>%
        dplyr::filter(.data$ts >= minimum_ts) %>%
        dplyr::collect() %>%
        dplyr::mutate(event_date = lubridate::ymd(stringr::str_sub(.data$ts, start = 1, end = 8)))
    }

    return(project_creations_from_one_table)
  }

  if (read_cache & fs::file_exists(cache_file)) {
    project_creations <- readRDS(cache_file)
  } else {
    project_creations <- purrr::map_dfr(
      redcapcustodian::log_event_tables,
      get_project_creations_by_log_table,
      rc_conn,
      start_date,
      .id = "log_event_table"
    ) %>%
      dplyr::mutate(log_event_table = as.numeric(.data$log_event_table)) %>%
      dplyr::mutate(description_base_name = .data$description) %>%
      dplyr::mutate(description_base_name = stringr::str_replace_all(.data$description_base_name, "\n", "  ")) %>%
      dplyr::mutate(description_base_name = stringr::str_replace(.data$description_base_name, "^Copy project as PID.*", "Copy project as")) %>%
      dplyr::mutate(description_base_name = stringr::str_replace(.data$description_base_name, "^Copy project from PID.*", "Copy project from"))
    # Write to the cache if there is a cache_file path
    if (!is.na(cache_file)) {
      saveRDS(project_creations, file = cache_file)
    }
  }

  return(project_creations)
}
