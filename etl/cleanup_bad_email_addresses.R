# Locate bad UF addresses in REDCap replace them if possible, erase them if not,
# then disable accounts with no primary email address

# library(furrr)
library(tidyverse)
library(lubridate)
library(REDCapR)
library(dotenv)
library(redcapcustodian)
library(DBI)
library(RMariaDB)

set_script_name("cleanup_bad_email_addresses")
set_script_run_time()
conn <- connect_to_redcap_db()

redcap_emails <- get_redcap_emails(conn)

# get list errors directly from an inbox
earliest_date <- now(tzone = "America/New_York") - ddays(31)
bounce_data <- get_bad_emails_from_listserv_digest(
  username = Sys.getenv("IMAP_USERNAME"),
  password = Sys.getenv("IMAP_PASSWORD"),
  messages_since_date = earliest_date
)

bad_redcap_user_emails <- redcap_emails %>%
  inner_join(bounce_data, by = c("email"))

person <- get_institutional_person_data()
redcap_email_revisions <- get_redcap_email_revisions(bad_redcap_user_emails, person)
update_redcap_email_addresses(conn, redcap_email_revisions)
number_users_suspended <- suspend_users_with_no_primary_email(conn)

dbDisconnect(conn)

# TODO:
# Add logging of write events
# Maybe send email on failure?
