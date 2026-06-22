# Prevent [`quit_non_interactive_run`](quit_non_interactive_run.md) from quitting. This is not meant to be used outside of tests. See test-write.R for an example.

Prevent [`quit_non_interactive_run`](quit_non_interactive_run.md) from
quitting. This is not meant to be used outside of tests. See
test-write.R for an example.

## Usage

``` r
disable_non_interactive_quit()
```

## Examples

``` r
if (FALSE) { # \dontrun{
 disable_non_interactive_quit()
} # }
```
