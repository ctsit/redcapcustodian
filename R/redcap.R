#' Connect to the Primary REDCap MySQL Database
#' Assigns package-scoped conn
#'
#' @return An S4 object. Run ?dbConnect for more information
#'
#' @export
#' @examples
#' \dontrun{
#' conn <- connect_to_redcap_db()
#' }
connect_to_redcap_db <- function() {
  # verify the environment exists,
  # that `conn` is a member,
  # and that the DB connection is still valid
  # before disconnecting
  if (exists("redcapcustodian.env") &&
      "conn" %in% names(redcapcustodian.env) &&
      DBI::dbIsValid(redcapcustodian.env$conn)
      ) {
    conn <- redcapcustodian.env$conn
    warning(glue::glue("Disconnecting from REDCap database {dbGetInfo(conn)$host}:{dbGetInfo(conn)$dbname}, before reconnect"))
    DBI::dbDisconnect(conn)
  }

  if (Sys.getenv("REDCAP_DB_PORT") == '') port = "3306" else
    { port = Sys.getenv("REDCAP_DB_PORT") }
  conn = DBI::dbConnect(
    RMariaDB::MariaDB(),
    dbname = Sys.getenv("REDCAP_DB_NAME"),
    host = Sys.getenv("REDCAP_DB_HOST"),
    user = Sys.getenv("REDCAP_DB_USER"),
    password = Sys.getenv("REDCAP_DB_PASSWORD"),
    port = port
  )

  assign(
    "conn",
    conn,
    envir = redcapcustodian.env
  )

  return(redcapcustodian.env$conn)
}

#' Get connection to the primary REDCap database
#'
#' @return The existing connection object to the REDCap database
#'
#' @export
#' @examples
#' \dontrun{
#' conn <- get_redcap_db_connection()
#' }
get_redcap_db_connection <- function() {
  if (exists("redcapcustodian.env") &&
    "conn" %in% names(redcapcustodian.env) &&
    DBI::dbIsValid(redcapcustodian.env$conn)
  ) {
    return(redcapcustodian.env$conn)
  } else {
    warning("You have no connection!")
  }
}

#' Get all user emails in redcap_user_information as tall data
#'
#' @param conn A DBI Connection object
#'
#' @return a dataframe with these columns:
#' \itemize{
#'   \item ui_id - ui_id for the associated user in REDCap's redcap_user_information table
#'   \item username - REDCap username
#'   \item email_field_name - the name of the column containing the email address
#'   \item email - the email address in email_field_name
#' }
#'
#' @export
#' @importFrom rlang .data
#' @importFrom magrittr "%>%"
#' @examples
#' \dontrun{
#' conn <- dbConnect(RSQLite::SQLite(), dbname = ":memory:")
#' create_test_table(conn, "redcap_user_information")
#' get_redcap_emails(conn)
#' }
get_redcap_emails <- function(conn) {
  redcap_email_query <- "select ui_id, username, user_email, user_email2, user_email3 from redcap_user_information"
  redcap_emails <- DBI::dbGetQuery(conn, statement = redcap_email_query) %>%
    tidyr::pivot_longer(dplyr::starts_with("user_email"),
                 names_to="email_field_name",
                 values_to="email",
                 values_drop_na = TRUE) %>%
    dplyr::filter(.data$email != "")

  return(redcap_emails)
}

#' Get redcap user email revisions
#'
#' @param bad_redcap_user_emails bad redcap user email data
#' @param person institutional person data keyed on user_id
#'
#' @return a dataframe with these columns:
#' \itemize{
#'   \item ui_id - ui_id for the associated user in REDCap's redcap_user_information table
#'   \item username - REDCap username
#'   \item email_field_name - the name of the column containing the email address
#'   \item corrected_email - the corrected email address to be placed in the column from email_field_name
#' }
#'
#' @export
#' @importFrom rlang .data
#' @importFrom magrittr "%>%"
#' @examples
#' \dontrun{
#' conn <- dbConnect(RSQLite::SQLite(), dbname = ":memory:")
#' bad_emails <- get_bad_redcap_user_emails()
#' persons <- get_institutional_person_data(conn)
#' email_revisions <- get_redcap_email_revisions(bad_emails, persons)
#' }
get_redcap_email_revisions <- function(bad_redcap_user_emails, person) {
  person_data_for_redcap_users_with_bad_emails <- person %>%
    dplyr::select(.data$user_id, .data$email) %>%
    dplyr::filter(.data$user_id %in% bad_redcap_user_emails$username)

  replacement_email_addresses_for_bad_redcap_emails <- bad_redcap_user_emails %>%
    dplyr::inner_join(person_data_for_redcap_users_with_bad_emails, by = c("username" = "user_id"), suffix = c(".bad", ".replacement")) %>%
    dplyr::filter(.data$email.bad != .data$email.replacement) %>%
    dplyr::filter(!is.na(.data$email.replacement)) %>%
    dplyr::mutate(corrected_email = .data$email.replacement) %>%
    dplyr::select(
      .data$ui_id,
      .data$username,
      .data$email_field_name,
      .data$corrected_email
    )

  redcap_email_revisions <- replacement_email_addresses_for_bad_redcap_emails %>%
    dplyr::bind_rows(bad_redcap_user_emails) %>%
    dplyr::group_by(.data$ui_id, .data$email_field_name) %>%
    # columnar equivalent of coalesce for each row
    # ensures retention of corrected_email where marked for deletion
    # https://stackoverflow.com/a/60645992/7418735
    dplyr::summarise_all(~ na.omit(.)[1]) %>%
    dplyr::ungroup()

  return(redcap_email_revisions)
}

#' Updates bad redcap email addresses in redcap_user_information
#'
#' @param conn A DBI Connection object
#' @param redcap_email_revisions a df returned by \code{\link{get_redcap_email_revisions}}
#'
#' @examples
#' \dontrun{
#' conn <- connect_to_redcap_db()
#' bad_emails <- get_bad_emails_from_listserv_digest(
#'   username = "jdoe",
#'   password = "jane_does_password",
#'   url ="imaps://outlook.office365.com",
#'   messages_since_date = as.Date("2022-01-01", format = "%Y-%m-%d")
#'   )
#' bad_redcap_user_emails <- get_redcap_emails(conn) %>%
#'   filter(email %in% bad_emails)
#'
#' person_data <- get_institutional_person_data()
#' redcap_email_revisions <- get_redcap_email_revisions(bad_redcap_email_output, person_data)
#'
#' update_redcap_email_addresses(conn, redcap_email_revisions)
#' }
update_redcap_email_addresses <- function(conn, redcap_email_revisions) {
  # break down updated emails by field
  # columns (e.g. user_email<n>) cannot be parameterized
  # pivot_wider cannot be used as NAs in non-replacement fields result in overwrites
  # the solution is to create a list of lists, one list for each email_field_name
  redcap_email_change_groups <- redcap_email_revisions %>%
    dplyr::select(.data$email_field_name, .data$corrected_email, .data$ui_id) %>%
    dplyr::group_split(.data$email_field_name, .key = "email_field_name", .keep = FALSE) %>%
    # RMySQL prepared statements do not allow named parameters
    lapply(as.list) %>%
    lapply(unname) %>%
    purrr::set_names(nm = c(paste0("user_email", seq_along(.))))

  DBI::dbExecute(
    conn,
    paste0(
      "UPDATE redcap_user_information ",
      "SET user_email = ? ",
      "WHERE ui_id = ?"
    ),
    redcap_email_change_groups$user_email1
  )

  DBI::dbExecute(
    conn,
    paste0(
      "UPDATE redcap_user_information ",
      "SET user_email2 = ? ",
      "WHERE ui_id = ?"
    ),
    redcap_email_change_groups$user_email2
  )

  DBI::dbExecute(
    conn,
    paste0(
      "UPDATE redcap_user_information ",
      "SET user_email3 = ? ",
      "WHERE ui_id = ?"
    ),
    redcap_email_change_groups$user_email3
  )
}
