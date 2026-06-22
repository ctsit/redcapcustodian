# Enumerate bad email addresses described in LISTSERV email digests

Connect to an imap mailbox, identify LISTSERV digest emails sent after
\`messages_since_date\`, and extract bounced email addresses from those
digest messages.

## Usage

``` r
get_bad_emails_from_listserv_digest(
  username,
  password,
  url = "imaps://outlook.office365.com",
  messages_since_date
)
```

## Arguments

- username:

  The username of the IMAP mailbox

- password:

  The password of the IMAP mailbox

- url:

  The IMAP URL of the host that houses the mailbox

- messages_since_date:

  The sent date of the oldest message that should be inspected

## Value

A dataframe of bad email addresses

- email - a column of bad email address

## Examples

``` r
if (FALSE) { # \dontrun{
get_bad_emails_from_listserv_digest(
  username = "jdoe",
  password = "jane_does_password",
  url ="imaps://outlook.office365.com",
  messages_since_date = as.Date("2022-01-01", format = "%Y-%m-%d")
  )
} # }
```
