# Initialize the connection to the log db and set redcapcustodian.env\$log_con

Initialize the connection to the log db and set
redcapcustodian.env\$log_con

## Usage

``` r
init_log_con(drv = RMariaDB::MariaDB())
```

## Arguments

- drv, :

  an object that inherits from DBIDriver (e.g. RMariaDB::MariaDB()), or
  an existing DBIConnection object (in order to clone an existing
  connection).

## Examples

``` r
if (FALSE) { # \dontrun{
 # use a sqlite db instead
 init_log_con(drv = RSQLite::SQLite())
} # }
```
