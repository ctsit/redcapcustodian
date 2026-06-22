# Converts a MySQL schema file to a sqlite schema. Facilitates easier creation of in-memory (i.e. sqlite) tables.

Converts a MySQL schema file to a sqlite schema. Facilitates easier
creation of in-memory (i.e. sqlite) tables.

## Usage

``` r
convert_schema_to_sqlite(schema_file_path)
```

## Arguments

- schema_file_path, :

  the path of the schema file to convert

## Value

the translated schema as a character string

## Examples

``` r
if (FALSE) { # \dontrun{
mem_conn <- DBI::dbConnect(RSQLite::SQLite(), dbname = ":memory:")
translated_schema <- convert_schema_to_sqlite("~/documents/my_cool_schema.sql")
DBI::dbSendQuery(mem_conn, schema)
} # }
```
