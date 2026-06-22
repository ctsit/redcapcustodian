# Connect to the log db

Connect to the log db

## Usage

``` r
connect_to_log_db(drv, continue_on_error = FALSE)
```

## Arguments

- drv, :

  an object that inherits from DBIDriver (e.g. RMariaDB::MariaDB()), or
  an existing DBIConnection object (in order to clone an existing
  connection).

- continue_on_error:

  if TRUE then continue execution on error, if FALSE then quit non
  interactive sessions on error

## Value

An S4 object. Run ?dbConnect for more information

## Examples

``` r

if (FALSE) { # \dontrun{
# connect to log db using LOG_DB_* environment variables
con <- connect_to_log_db()

# connect to sqlite log db
con <- connect_to_log_db(drv = RSQLite::SQLite())
} # }
```
