#' Gather all API tokens on a specified REDCap server for a given user
#'
#' @param conn a DBI database connection to a REDCap instance, such as that from \code{\link{get_redcap_db_connection}}
#' @param username_to_scrape a REDCap username
#'
#' @return A dataframe of all tokens assigned to the user containing the following:
#' \itemize{
#'   \item project_id - The project ID in REDCap (0 if super token)
#'   \item username - The username from REDCap
#'   \item token - The API token associated with the project ID
#'   \item project_display_name - The name of the project as it appears in the REDCap GUI
#' }
#'
#' @export
#' @examples
#' \dontrun{
#'   conn <- get_redcap_db_connection()
#'   my_credentials <- scrape_user_api_tokens(conn, "admin")
#'
#' }
scrape_user_api_tokens <- function(conn, username_to_scrape) {
  # collect super API token if one exists
  super_credentials <- dplyr::tbl(conn, "redcap_user_information") %>%
    dplyr::filter(.data$username == username_to_scrape) %>%
    dplyr::select(.data$username, .data$api_token) %>%
    dplyr::collect() %>%
    dplyr::mutate(project_id = 0) %>%
    dplyr::filter(!is.na(.data$api_token)) %>%
    dplyr::mutate(app_title = "Super API Token")

  credentials <- dplyr::tbl(conn, "redcap_user_rights") %>%
    dplyr::filter(.data$username == username_to_scrape) %>%
    dplyr::filter(!is.na(.data$api_token)) %>%
    dplyr::select(
      .data$project_id,
      .data$username,
      .data$api_token
    ) %>%
    # add project information
    dplyr::left_join(
      dplyr::tbl(conn, "redcap_projects") %>%
        dplyr::select(
          .data$project_id,
          .data$app_title
        ),
      by = "project_id"
    ) %>%
    dplyr::collect() %>%
    # bind_rows used over rbind to avoid need to align column order
    dplyr::bind_rows(super_credentials) %>%
    dplyr::rename(
      project_display_name = .data$app_title,
      token = .data$api_token # rename for compatibility with REDCapR credential objects
    )

  return(credentials)
}


#' Store credentials in a local SQLite db
#'
#' @param credential_df a dataframe containing user credentials, such as that from \code{\link{scrape_user_api_tokens}}
#' @param local_conn a dataframe containing user credentials, such as that from \code{\link{scrape_user_api_tokens}}
#'
#' @return The newly created super token
#'
#' @export
#' @examples
#' \dontrun{
#'   conn <- get_redcap_db_connection()
#'   my_new_super_token <- set_super_api_token(conn, "admin")
#' }
set_super_api_token <- function(credential_df, local_conn) {
  cred_conn <- DBI::dbConnect(RSQLite::SQLite(), "credentials/credentials.db")
}

###############################################################################
#                         Creation of new credentials                         #
###############################################################################


#' Generate and set a Super API token for a provided REDCap user
#'
#' @param conn a DBI database connection, such as that from \code{\link{get_redcap_db_connection}}
#' @param username a REDCap username
#'
#' @return The newly created super token
#'
#' @export
#' @examples
#' \dontrun{
#'   conn <- get_redcap_db_connection()
#'   my_new_super_token <- set_super_api_token(conn, "admin")
#' }
set_super_api_token <- function(conn, username) {
  # copied from Classes/RedCapDB.php::setAPITokenSuper
  token <- paste0(username)
  digest::digest(token, algo = "md5")

  sql <- paste0(
    "UPDATE redcap_user_information",
    "SET api_token = ", token,
    "WHERE username = ", username,
    "LIMIT 1"
  )
}


#' Generate an API token for a REDCap project
#'
#' @param conn a DBI database connection, such as that from \code{\link{get_redcap_db_connection}}
#' @param username a REDCap username
#' @param project_id The project id of the project you wish to generate a token for
#' @return The newly created token
#'
#' @export
#' @examples
#' \dontrun{
#'   conn <- get_redcap_db_connection()
#'   my_new_token <- set_project_api_token(conn, "admin", 15)
#' }
set_project_api_token <- function(conn, username, project_id) {
  # copied from Classes/RedCapDB.php::setAPIToken
  token <- paste0(username, project_id)
  sql <- paste0(
    "UPDATE redcap_user_rights",
    "SET api_token = ", token,
    "WHERE username = ", username,
    "AND project_id = ", project_id,
    "LIMIT 1"
  )
}



save_credentials <- function(
                             file_path,
                             project_id = "0",
                             token
                             ) {

}
