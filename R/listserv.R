
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
  imap_con <- mRpostman::configure_imap(
    url = url,
    username = username,
    password = password
  )

  imap_con$select_folder("INBOX")
  emails_by_subject_search <- imap_con$search_string(expr = "Daily error monitoring report", where = "SUBJECT")
  emails_by_since_search <- imap_con$search_since(date_char = format(messages_since_date, format = "%d-%b-%Y"))
  emails_found <- dplyr::intersect(emails_by_subject_search, emails_by_since_search)

  if (length(emails_found) > 0) {
    bounced_email_addresses <- emails_found %>%
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


#' Scrape an inbox for bad email addresses in bounce messages
#'
#' Connect to an imap mailbox, identify bad email addresses referenced in bounce
#' messages sent after `messages_since_date`, and extract the data from those emails.
#'
#' @param url The IMAP URL of the host that houses the mailbox
#' @param username The username of the IMAP mailbox
#' @param password The password of the IMAP mailbox
#' @param messages_since_date The sent date of the oldest message that should be inspected
#'
#' @return A dataframe of bounced email addresses
#' \itemize{
#'   \item{\code{email}}{character email address the bounced}
#' }
#' @export
#' @importFrom magrittr "%>%"
#' @importFrom rlang .data
#'
#' @examples
#' \dontrun{
#' get_bad_emails_from_individual_emails(
#'   username = "jdoe",
#'   password = "jane_does_password",
#'   url ="imaps://outlook.office365.com",
#'   messages_since_date = as.Date("2022-01-01", format = "%Y-%m-%d")
#'   )
#' }
get_bad_emails_from_individual_emails <- function(username,
                                                  password,
                                                  url = "imaps://outlook.office365.com",
                                                  messages_since_date) {
  imap_con <- mRpostman::configure_imap(
    url = url,
    username = username,
    password = password
  )

  imap_con$select_folder("INBOX")

  emails_found <- imap_con$search(
    request = mRpostman::AND(
      # NOTE: "Undelivered Mail Returned to Sender" does not get hits due to SUBJECT being a vector
      # in instances where it appears, mRpostman doesn't want to read this
      #mRpostman::string(expr = "Undelivered Mail Returned to Sender", where = "SUBJECT"),
      mRpostman::string(expr = "Undeliverable", where = "SUBJECT"),
      # NOTE: using on(date_char = ...) with first of month may be most performant
      mRpostman::sent_since(date_char = format(messages_since_date, format = "%d-%b-%Y"))
    )
  )

  patterns <- c(
    "Original-Recipient: rfc822;.*",
    "Final-Recipient: rfc822;.*"
  )

  # remove literal ".*" for extraction
  preceders <- stringr::str_remove(patterns, "[.]\\*")

  data_from_emails <- c()

  if (length(emails_found) > 0) {
    for (email in emails_found) {

      data_row <- email %>%
        imap_con$fetch_body() %>%
        stringr::str_extract_all(patterns) %>%
        unlist() %>%
        stringr::str_remove_all(preceders) %>%
        # extract email address itself
        sub(".*\\s(.*@.*).*", "\\1", .)

      data_from_emails <- append(data_from_emails, data_row)
    }
  }

  bounced_email_addresses <- dplyr::tibble(email = data_from_emails %>%
                                          unlist() %>%
                                          stringr::str_remove_all("rfc822;") %>%
                                          unique()
                                          )

  return(bounced_email_addresses)
}
