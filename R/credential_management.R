#' Gather all API tokens on a specified REDCap server for a given user
#'
#' @param conn a DBI database connection to a REDCap instance, such as that from \code{\link{get_redcap_db_connection}}
#' @param username_to_scrape a REDCap username, defaults to your system's username
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
scrape_user_api_tokens <- function(conn, username_to_scrape = Sys.info()[["user"]]) {
  # collect super API token if one exists
  super_credentials <- dplyr::tbl(conn, "redcap_user_information") %>%
    dplyr::filter(.data$username == username_to_scrape) %>%
    dplyr::select("username", "api_token") %>%
    dplyr::collect() %>%
    dplyr::mutate(project_id = 0) %>%
    dplyr::filter(!is.na(.data$api_token)) %>%
    dplyr::mutate(app_title = "Super API Token")

  credentials <- dplyr::tbl(conn, "redcap_user_rights") %>%
    dplyr::filter(.data$username == username_to_scrape) %>%
    dplyr::filter(!is.na(.data$api_token)) %>%
    dplyr::select(
      "project_id",
      "username",
      "api_token"
    ) %>%
    # add project information
    dplyr::left_join(
      dplyr::tbl(conn, "redcap_projects") %>%
        dplyr::select(
          "project_id",
          "app_title",
          "date_deleted"
        ),
      by = "project_id"
    ) %>%
    dplyr::collect() %>%
    # filter out deleted projects
    dplyr::filter(is.na(.data$date_deleted)) |>
    dplyr::select(-"date_deleted") |>
    # bind_rows used over rbind to avoid need to align column order
    dplyr::bind_rows(super_credentials) %>%
    dplyr::rename(
      project_display_name = "app_title",
      token = "api_token" # rename for compatibility with REDCapR credential objects
    )

  return(credentials)
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


#' Generate an API token for a REDCap project and assign it to a specified user
#'
#' @param conn a DBI database connection, such as that from \code{\link{get_redcap_db_connection}}
#' @param username a REDCap username \cr
#' This user must already have access to the project, i.e. they must appear in the project's User Rights
#' @param project_id The project id of the project for which you wish to generate a token
#' @return nothing
#'
#' @export
#' @examples
#' \dontrun{
#'   conn <- get_redcap_db_connection()
#'   my_new_token <- set_project_api_token(conn, "admin", 15)
#' }
set_project_api_token <- function(conn, username, project_id) {
  # inspired by Classes/RedCapDB.php::setAPIToken
  # Mersenne-Twister is R's default RNG, see ?Random
  # TODO: clone REDCap Core's getRandomHash to complete match
  salt <- sample(64:128, 1)

  token <- paste(username, project_id, salt, sep = "&") %>%
    digest::digest(algo = "md5") %>%
    toupper()

  # TODO: create new row if user does not already have access to this project
  # TODO: consider respecting existing API tokens
  sql <- paste0(
    "UPDATE `redcap_user_rights` ",
    "SET api_token = '", token, "' ",
    "WHERE username = '", username, "' ",
    "AND project_id = ", project_id, " ",
    "LIMIT 1"
  )

  DBI::dbExecute(conn, sql)
}

save_credentials <- function(
    file_path,
    project_id = "0",
    token) {

}
