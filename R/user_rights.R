#' Expire user rights to REDCap projects
#'
#' Expire user rights on one or more REDCap projects based
#' on list of users to expire or users to exclude from expiration
#'
#' @param conn, DBI Connection object to a REDCap database
#' @param project_ids, a vector of project IDs whose users need expiration
#' @param usernames, a vector of usernames to expire across the vector of project IDs
#' @param all_users_except, a vector of usernames who will be excluded from expiration
#' @param expiration_date, the expiration date to be applied to the users. Defaults to today.
#'
#' @return a list of the update count and data written
#' \itemize{
#'   \item updates - the number of records revised
#'   \item data - the dataframe of changes applied to redcap_user_rights
#' }
#'
#' @importFrom magrittr "%>%"
#' @importFrom rlang .data
#' @export
#'
#' @examples
#' conn <- DBI::dbConnect(RSQLite::SQLite(), dbname = ":memory:")
#'
#' DBI::dbCreateTable(
#'   conn,
#'   name = "redcap_user_rights",
#'   fields = user_rights_test_data$redcap_user_rights
#' )
#' DBI::dbAppendTable(
#'   conn,
#'   name = "redcap_user_rights",
#'   value = user_rights_test_data$redcap_user_rights
#' )
#'
#' usernames <- c("bob", "dan")
#'
#' expire_user_project_rights(
#'   conn = conn,
#'   project_ids = c(34),
#'   usernames = usernames
#' )
expire_user_project_rights <- function(conn,
                                    project_ids,
                                    usernames = NULL,
                                    all_users_except = NULL,
                                    expiration_date = as.Date(NA)) {
  expiration_date <- dplyr::if_else(
    is.na(expiration_date), lubridate::today(), expiration_date
  )

  if (is.null(usernames)) {
    redcap_user_rights <-
      dplyr::tbl(conn, "redcap_user_rights") %>%
      dplyr::filter(.data$project_id %in% project_ids) %>%
      dplyr::filter(is.na(.data$expiration) | .data$expiration > local(expiration_date)) %>%
      dplyr::collect()
  } else {
    redcap_user_rights <-
      dplyr::tbl(conn, "redcap_user_rights") %>%
      dplyr::filter(.data$project_id %in% project_ids) %>%
      dplyr::filter(is.na(.data$expiration) | .data$expiration > local(expiration_date)) %>%
      dplyr::filter(.data$username %in% usernames) %>%
      dplyr::collect()
  }

  users_to_expire <- redcap_user_rights %>%
    dplyr::filter(is.null(all_users_except) | !.data$username %in% all_users_except)

  update_records <- users_to_expire %>%
    dplyr::mutate(expiration = expiration_date) %>%
    dplyr::select("project_id", "username", "expiration")

  diff_data <- list(update_records = update_records)

  sync_result <- sync_table(
    conn = conn,
    table_name = "redcap_user_rights",
    primary_key = c("project_id", "username"),
    data_diff_output = diff_data
  )

  result <- list(
    updates = sync_result$updates,
    data = update_records
  )

  return(result)
}
