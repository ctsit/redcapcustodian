# Attempts to connect to the DB using all LOG_DB\_\* environment variables. Returns an empty list if a connection is established, returns an \`error_list\` entry otherwise.

Attempts to connect to the DB using all LOG_DB\_\* environment
variables. Returns an empty list if a connection is established, returns
an \`error_list\` entry otherwise.

## Usage

``` r
verify_log_connectivity(drv = RMariaDB::MariaDB())
```

## Arguments

- drv, :

  an object that inherits from DBIDriver (e.g. RMariaDB::MariaDB()), or
  an existing DBIConnection object (in order to clone an existing
  connection).

## Value

An \`error_list\` entry

## Examples

``` r
if (FALSE) { # \dontrun{
 verify_log_connectivity(RMariaDB::MariaDB())
} # }
```
