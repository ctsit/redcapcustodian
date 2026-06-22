# Write an success job log entry

Write an success job log entry

## Usage

``` r
write_success_job_log_entry(con, job_duration, job_summary)
```

## Arguments

- con, :

  a DB connection

- job_duration, :

  the duration of the job in seconds

- job_summary, :

  the summary of the job performed as JSON

## Examples

``` r
if (FALSE) { # \dontrun{
 write_success_job_log_entry(
   conn = con,
   job_duration = 30,
   job_summary = as.json("Update vaccination status")
 )
} # }
```
