# Sets the package-scoped value of script_run_time

Sets the package-scoped value of script_run_time

## Usage

``` r
set_script_run_time(fake_runtime = lubridate::NA_POSIXct_)
```

## Arguments

- fake_runtime:

  An asserted script run time

## Value

the package-scoped value of script_run_time

## Examples

``` r
set_script_run_time()
#> [1] "2026-08-13 20:30:01 UTC"
set_script_run_time(fake_runtime =
                    as.POSIXct("2021-02-23 02:23:00",
                               tz="",
                               format="%Y-%m-%d %H:%M:%OS")
                   )
#> [1] "2021-02-23 02:23:00 UTC"
```
