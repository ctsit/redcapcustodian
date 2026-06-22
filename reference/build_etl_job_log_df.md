# Builds formatted rcc_job_log data frame from source data

Builds formatted rcc_job_log data frame from source data

## Usage

``` r
build_etl_job_log_df(job_duration, job_summary, level)
```

## Arguments

- job_duration, :

  the job duration in seconds

- job_summary, :

  the summary of the job performed

- level, :

  the log level (DEBUG, ERROR, INFO)

## Value

df_etl_log_job, the df matching the rcc_job_log table

## Examples

``` r
if (FALSE) { # \dontrun{
 build_etl_job_log_df(
   job_duration,
   job_summary,
   level
 )
} # }
```
