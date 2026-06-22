# Provide the exact length of the time span between start time and end time

Provide the exact length of the time span between start time and end
time

## Usage

``` r
get_job_duration(start_time, end_time)
```

## Arguments

- start_time, :

  a lubridate::duration object representing the start time

- end_time, :

  a lubridate::duration object representing the end time

## Value

the exact length of the time span between start time and end time

## Examples

``` r
if (FALSE) { # \dontrun{
get_job_duration(
  start_time = get_script_run_time(),
  end_time = get_current_time()
)
} # }
```
