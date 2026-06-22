# Connect to db

Connect to db

## Usage

``` r
connect_to_db(drv, prefix = "", continue_on_error = FALSE)
```

## Arguments

- drv, :

  an object that inherits from DBIDriver (e.g. RMariaDB::MariaDB()), or
  an existing DBIConnection object (in order to clone an existing
  connection).

- prefix, :

  the

- continue_on_error:

  if TRUE then continue execution on error, if FALSE then quit non
  interactive sessions on error

## Value

An S4 object. Run ?dbConnect for more information

## Examples

``` r
if (FALSE) { # \dontrun{
# connect to db using [prefix]_DB_* environment variables
con <- connect_to_db(drv = RMariaDB::MariaDB(), prefix = "RCC")

# connect to sqlite db
con <- connect_to_db(drv = RSQLite::SQLite())
} # }
```
