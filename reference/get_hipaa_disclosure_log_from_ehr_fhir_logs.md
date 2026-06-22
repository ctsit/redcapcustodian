# get_hipaa_disclosure_log_from_ehr_fhir_logs

Read a data needed for a HIPAA disclosure log from a REDCap database
given a DBI connection object to the REDCap database and some optional
parameters to narrow the returned result.

Optionally filter the data with the data range \`\[start_date,
end_date)\`.

## Usage

``` r
get_hipaa_disclosure_log_from_ehr_fhir_logs(
  conn,
  ehr_id = NA_real_,
  start_date = as.Date(NA),
  end_date = as.Date(NA)
)
```

## Arguments

- conn:

  a DBI connection object to the REDCap database

- ehr_id:

  a vector of REDCap EHR_IDs for the EHR(s) of interest (optional)

- start_date:

  The first date from which we should return results (optional)

- end_date:

  The last date (non-inclusive) from which we should return results
  (optional)

## Value

A dataframe suitable for generating a HIPAA disclosure log

## Examples

``` r
if (FALSE) { # \dontrun{
library(tidyverse)
library(lubridate)
library(REDCapR)
library(dotenv)
library(redcapcustodian)
library(DBI)
library(RMariaDB)

init_etl("export_fhir_traffic_log")
conn <- connect_to_redcap_db()

get_hipaa_disclosure_log_from_ehr_fhir_logs(conn)
} # }
```
