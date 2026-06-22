# Format and write summary metrics to the redcap_summary_metrics table in your LOG_DB

Format and write summary metrics to the redcap_summary_metrics table in
your LOG_DB

## Usage

``` r
write_summary_metrics(
  reporting_period_start,
  reporting_period_end,
  metric_type,
  metric_dataframe,
  conn = NULL
)
```

## Arguments

- reporting_period_start:

  a datetime object, e.g. ymd_hms("2022-11-01 00:00:00")

- reporting_period_end:

  a datetime object, e.g. ymd_hms("2022-12-01 00:00:00")

- metric_type:

  a character string representing the metric type, e.g. "flux", "state"

- metric_dataframe:

  A wide data frame of key-value pairs with a single row of data

- conn:

  A DBI connection object to the database that holds the
  \`redcap_summary_metrics\` table. Can be left as NULL if the
  connection is available on the package scope var "log_con".

## Value

nothing

## Examples

``` r
if (FALSE) { # \dontrun{
 write_summary_metrics(
   reporting_period_start = ymd_hms("2022-01-01 00:00:00", tz=Sys.getenv("TIME_ZONE")),
   reporting_period_end = ceiling_date(reporting_period_start, "month", change_on_boundary = T),
   metric_type = "state",
   metric_dataframe = my_cool_df,
   conn = my_conn
 )
} # }
```
