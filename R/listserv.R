
#' Enumerate bad email addresses described in LISTSERV email digests
#'
#' Connect to an imap mailbox, identify LISTSERV digest emails sent
#' after `messages_since_date`, and extract bounced email addresses
#' from those digest messages.
#'
#' @param url The IMAP URL of the host that houses the mailbox
#' @param username The username of the IMAP mailbox
#' @param password The password of the IMAP mailbox
#' @param messages_since_date The sent date of the oldest message that should be inspected
#'
#' @return A dataframe of bad email addresses
#' \itemize{
#'   \item email - a column of bad email address
#' }
#' @export
#' @importFrom magrittr "%>%"
#' @importFrom rlang .data
#'
#' @examples
#' \dontrun{
#' get_bad_emails_from_listserv_digest(
#'   username = "jdoe",
#'   password = "jane_does_password",
#'   url ="imaps://outlook.office365.com",
#'   messages_since_date = as.Date("2022-01-01", format = "%Y-%m-%d")
#'   )
#' }

get_bad_emails_from_listserv_digest <- function(username,
                                                password,
                                                url = "imaps://outlook.office365.com",
                                                messages_since_date) {
  utils::globalVariables(c("."))

  imap_con <- mRpostman::configure_imap(
    url = url,
    username = username,
    password = password
  )

  imap_con$select_folder("INBOX")
  error_emails <- imap_con$search_string(expr = "Daily error monitoring report", where = "SUBJECT")
  messages_since_date <- imap_con$search_since(date_char = format(messages_since_date, format = "%d-%b-%Y"))
  digest_emails <- dplyr::intersect(error_emails, messages_since_date)

  if (!is.na(digest_emails)) {
    bounced_email_addresses <- digest_emails %>%
      imap_con$fetch_body() %>%
      # key on Err First Last Address row
      stringr::str_extract_all("\\d{1} \\d{2}/\\d{2} \\d{2}/\\d{2}.*") %>%
      # flatten nested list of email -> address rows
      unlist() %>%
      # extract email address portion
      sub(".*\\s(.*@.*).*", "\\1", .) %>%
      # remove html encoded < and > characters
      sub("&lt;", "", .) %>%
      sub("&gt;", "", .) %>%
      # remove literal < and > characters
      sub("<", "", .) %>%
      sub(">", "", .) %>%
      # remove html newline
      sub("<br>", "", .) %>%
      unique()
  } else {
    bounced_email_addresses <- NA_character_
  }

  bounce_data <- dplyr::tibble(bounced_email_addresses) %>%
    dplyr::mutate(email = tolower(.data$bounced_email_addresses)) %>%
    dplyr::select(.data$email)

  return(bounce_data)
}
