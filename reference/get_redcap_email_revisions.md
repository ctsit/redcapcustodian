# Get redcap user email revisions

Get redcap user email revisions

## Usage

``` r
get_redcap_email_revisions(bad_redcap_user_emails, person)
```

## Arguments

- bad_redcap_user_emails:

  bad redcap user email data

- person:

  institutional person data keyed on user_id

## Value

a dataframe with these columns:

- ui_id - ui_id for the associated user in REDCap's
  redcap_user_information table

- username - REDCap username

- email_field_name - the name of the column containing the email address

- corrected_email - the corrected email address to be placed in the
  column from email_field_name

## Examples

``` r
if (FALSE) { # \dontrun{
conn <- dbConnect(RSQLite::SQLite(), dbname = ":memory:")
bad_emails <- get_bad_redcap_user_emails()
persons <- get_institutional_person_data(conn)
email_revisions <- get_redcap_email_revisions(bad_emails, persons)
} # }
```
