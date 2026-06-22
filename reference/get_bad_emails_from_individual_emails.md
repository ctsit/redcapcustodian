# Scrape an inbox for bad email addresses in bounce messages

Connect to an imap mailbox, identify bad email addresses referenced in
bounce messages sent after \`messages_since_date\`, and extract the data
from those emails.

## Usage

``` r
get_bad_emails_from_individual_emails(
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

A dataframe of bounced email addresses

- email character email address the bounced

## Examples

``` r
if (FALSE) { # \dontrun{
get_bad_emails_from_individual_emails(
  username = "jdoe",
  password = "jane_does_password",
  url ="imaps://outlook.office365.com",
  messages_since_date = as.Date("2022-01-01", format = "%Y-%m-%d")
  )
} # }
```
