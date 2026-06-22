# Create a REDCap data dictionary from a dataframe

Create a REDCap data dictionary from a dataframe

## Usage

``` r
dataframe_to_redcap_dictionary(df, form_name, record_id_col = NULL)
```

## Arguments

- df:

  the dataframe to generate the data dictionary for

- form_name:

  the form name to display in REDCap

- record_id_col:

  a column in the dataframe that uniquely identifies each record

## Value

A redcap data dictionary

## Examples

``` r
if (FALSE) { # \dontrun{

df <- data.frame(
  pk_col = c("a1", "a2", "a3"),
  integer_col = c(1, 2, 3),
  numeric_col = 5.9,
  character_col = c("a", "b", "c"),
  date_col = as.Date("2011-03-07"),
  date_time_col = as.POSIXct(strptime("2011-03-27 01:30:00", "%Y-%m-%d %H:%M:%S")),
  email_col = c("test@example.com", "test.2@example.edu", "3test@example.net")
)

redcap_data_dictionary <- dataframe_to_redcap_dictionary(df, "test_form")
redcap_data_dictionary <- dataframe_to_redcap_dictionary(df, "test_form", "character_col")
} # }
```
