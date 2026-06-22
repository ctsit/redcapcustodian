# Updates bad redcap email addresses in redcap_user_information

Updates bad redcap email addresses in redcap_user_information

## Usage

``` r
update_redcap_email_addresses(
  conn,
  redcap_email_revisions,
  redcap_email_original
)
```

## Arguments

- conn:

  A DBI Connection object

- redcap_email_revisions:

  a df returned by
  [`get_redcap_email_revisions`](get_redcap_email_revisions.md)

- redcap_email_original:

  a df of original redcap_user_information email data

## Examples

``` r
if (FALSE) { # \dontrun{
conn <- connect_to_redcap_db()
bad_emails <- get_bad_emails_from_listserv_digest(
  username = "jdoe",
  password = "jane_does_password",
  url = "imaps://outlook.office365.com",
  messages_since_date = as.Date("2022-01-01", format = "%Y-%m-%d")
)
bad_redcap_user_emails <- get_redcap_emails(conn)$tall %>%
  filter(email %in% bad_emails)

person_data <- get_institutional_person_data()
redcap_email_revisions <- get_redcap_email_revisions(bad_redcap_email_output, person_data)

update_redcap_email_addresses(
  conn,
  redcap_email_revisions,
  redcap_email_original = get_redcap_emails(conn)$wide
)
} # }
```
