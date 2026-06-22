# Verifies all dependencies required to write log entries.

Verifies all dependencies required to write log entries.

## Usage

``` r
verify_log_dependencies(drv = RMariaDB::MariaDB())
```

## Arguments

- drv, :

  an object that inherits from DBIDriver (e.g. RMariaDB::MariaDB()), or
  an existing DBIConnection object (in order to clone an existing
  connection).

## Value

A list of \`error_list\` entries.

## Examples

``` r
if (FALSE) { # \dontrun{
 verify_log_dependencies(
     drv = RMariaDB::MariaDB()
 )
} # }
```
