# Initialize all etl dependencies

Initialize all etl dependencies

## Usage

``` r
init_etl(
  script_name = "",
  project_name = "",
  project_instance = "",
  fake_runtime = NULL,
  log_db_drv = RMariaDB::MariaDB()
)
```

## Arguments

- script_name:

  name passed to [`set_script_name`](set_script_name.md)

- project_name:

  name passed to [`set_project_name`](set_project_name.md)

- project_instance:

  name passed to [`set_project_instance`](set_project_instance.md)

- fake_runtime:

  An optional asserted script run time passed to
  [`set_script_run_time`](set_script_run_time.md), defaults to the time
  this function is called

- log_db_drv, :

  an object that inherits from DBIDriver (e.g. RMariaDB::MariaDB()), or
  an existing DBIConnection object (in order to clone an existing
  connection).

## Examples

``` r
if (FALSE) { # \dontrun{
  init_etl("name_of_file")
} # }
```
