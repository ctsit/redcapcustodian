# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working
with code in this repository.

## What this project is

`redcapcustodian` is an R package (v1.28.x) that provides a framework
for automating ETL work against REDCap systems and their underlying
MySQL databases. It ships three things together:

1.  **R package** — functions for credential management, DB connections,
    data diffing/syncing, logging, and email alerting.
2.  **Docker image** — built on `rocker/verse:4.4.1`, packages the R
    library for automated deployment.
3.  **`study_template/`** — a starting point for a downstream repository
    that builds on this image to implement study-specific ETL jobs.

## Commands

### Run tests

``` r

devtools::test()                          # all tests
devtools::test(filter = "logging")        # single test file (matches test-logging.R)
testthat::test_file("tests/testthat/test-logging.R")
```

### Build and check the package

``` r

devtools::check()                         # R CMD check
devtools::document()                      # regenerate NAMESPACE and man/ from roxygen2
devtools::build()                         # build tarball
```

### Build the Docker image

``` sh
./build.sh                               # builds and tags redcapcustodian:latest and redcapcustodian:<VERSION>
```

## Architecture

### Package-scoped state (`redcapcustodian.env`)

The package maintains a private environment (`redcapcustodian.env` in
`R/logging.R`) that acts as global state across ETL scripts. The
canonical way to initialize it is [`init_etl()`](reference/init_etl.md)
(`R/utils.R`), which calls: -
[`set_project_name()`](reference/set_project_name.md) /
[`set_project_instance()`](reference/set_project_instance.md) — read
from env vars `PROJECT` / `INSTANCE` -
[`set_script_name()`](reference/set_script_name.md) — auto-detected from
command args or RStudio context -
[`set_script_run_time()`](reference/set_script_run_time.md) — captured
at job start - [`init_log_con()`](reference/init_log_con.md) — connects
to the log DB and stores the connection

Use [`get_package_scope_var()`](reference/get_package_scope_var.md) /
[`set_package_scope_var()`](reference/set_package_scope_var.md) for
arbitrary package-scoped values.

### Database connection pattern

DB connections follow a `<PREFIX>_DB_*` environment variable
convention: - `REDCAP_DB_*` — the REDCap MySQL database (direct schema
access) - `LOG_DB_*` — the logging database (writes to `rcc_job_log` and
`etl_log`) - `ETL_DB_*` — an optional ETL target database -
`CREDENTIALS_DB` — path to a SQLite file used by
[`get_redcap_credentials()`](reference/get_redcap_credentials.md)

`connect_to_db(drv, prefix)` is the underlying generic;
[`connect_to_redcap_db()`](reference/connect_to_redcap_db.md) and
[`connect_to_log_db()`](reference/connect_to_log_db.md) are convenience
wrappers.

Tests use **DuckDB**
([`duckdb::duckdb()`](https://r.duckdb.org/reference/duckdb.html)) as an
in-memory substitute for the log DB — pass it to
`init_etl(log_db_drv = duckdb::duckdb())`.

### Data sync pattern (`dataset_diff` → `sync_table`)

The core ETL pattern in `R/dataset_diff.R` and `R/write_data.R`:

1.  `dataset_diff(source, source_pk, target, target_pk)` computes
    `insert_records`, `update_records`, `delete_records`.
2.  `sync_table(conn, table_name, primary_key, data_diff_output)` writes
    those diffs back via
    [`DBI::dbAppendTable`](https://dbi.r-dbi.org/reference/dbAppendTable.html)
    (inserts),
    [`dbx::dbxUpdate`](https://rdrr.io/pkg/dbx/man/dbxUpdate.html)
    (updates),
    [`dbx::dbxDelete`](https://rdrr.io/pkg/dbx/man/dbxDelete.html)
    (deletes). All three flags default off except `update = TRUE`.
3.  [`sync_table_2()`](reference/sync_table_2.md) is a combined wrapper
    that calls `dataset_diff` internally and returns both the diff and
    the row counts.

### Logging

Two log tables (schemas in `inst/schema/`): - `rcc_job_log` — one row
per job run; columns include `level` (SUCCESS/DEBUG/ERROR),
`job_summary_data`, `job_duration`. - `etl_log` — one row per record
written; used by
[`write_info_log_entry()`](reference/write_info_log_entry.md) /
[`write_error_log_entry()`](reference/write_error_log_entry.md).

Public API: [`log_job_success()`](reference/log_job_success.md),
[`log_job_failure()`](reference/log_job_failure.md),
[`log_job_debug()`](reference/log_job_debug.md) — all require
[`init_etl()`](reference/init_etl.md) to have been called first.

### Email

[`send_email()`](reference/send_email.md) (`R/logging.R`) wraps
`sendmailR`. Configuration comes from env vars: `SMTP_SERVER`,
`EMAIL_FROM`, `EMAIL_TO`, `EMAIL_CC`. Optional attachments accept CSV,
XLSX, ZIP, or TXT.

### Credential management

[`get_redcap_credentials()`](reference/get_redcap_credentials.md)
(`R/get_redcap_credentials.R`) queries a SQLite `credentials` table from
the path in `CREDENTIALS_DB`.
[`scrape_user_api_tokens()`](reference/scrape_user_api_tokens.md)
(`R/credential_management.R`) reads tokens directly from the REDCap
MySQL database for a given username.

### REDCap-specific helpers

- [`connect_to_redcap_db()`](reference/connect_to_redcap_db.md) /
  [`get_redcap_db_connection()`](reference/get_redcap_db_connection.md)
  — manage the package-scoped MySQL connection to REDCap.
- [`sync_metadata()`](reference/sync_metadata.md) (`R/multi_instance.R`)
  — copies a data dictionary between REDCap projects via the API.
- [`expire_user_project_rights()`](reference/expire_user_project_rights.md)
  (`R/user_rights.R`) — bulk-expires user rights directly in the REDCap
  DB.
- [`get_project_life_cycle()`](reference/get_project_life_cycle.md)
  (`R/project_life_cycle.R`) — reconstructs project history from REDCap
  log event tables.

### Testing conventions

- Tests use in-memory SQLite or DuckDB; never a live DB.
- `inst/testdata/` holds CSV + SQL schema pairs (`redcap_projects`,
  `redcap_user_information`). Load them with
  `create_test_table(conn, "redcap_projects")` or
  `create_test_tables(conn)` (`R/devtools.R`).
- `tests/testthat/helper.R` defines shared helpers; `setup.R` loads
  common libraries.
- [`disable_non_interactive_quit()`](reference/disable_non_interactive_quit.md)
  must be called in tests that exercise code paths that would otherwise
  call [`q()`](https://rdrr.io/r/base/quit.html) on failure.
- [`convert_schema_to_sqlite()`](reference/convert_schema_to_sqlite.md)
  translates MySQL schemas to SQLite for in-memory testing (uses
  `inst/to_sqlite.pl`).

### Environment / configuration

Scripts use
[`dotenv::load_dot_env()`](https://rdrr.io/pkg/dotenv/man/load_dot_env.html)
to load `.env` files. `study_template/example.env` documents all
supported env vars. `TIME_ZONE` is used throughout for consistent
datetime handling via
[`lubridate::with_tz()`](https://lubridate.tidyverse.org/reference/with_tz.html).

### ETL script lifecycle

Each deployed ETL script follows this pattern:

``` r

library(redcapcustodian)
library(dotenv)
dotenv::load_dot_env()
init_etl("script_name.R")   # sets up logging, sets script_run_time
# ... do work ...
log_job_success(rjson::toJSON(summary_list))
```

`etl/run_etl.R` is a generic wrapper that runs any Rscript via
[`callr::rscript()`](https://callr.r-lib.org/reference/rscript.html) and
emails the log on failure.
