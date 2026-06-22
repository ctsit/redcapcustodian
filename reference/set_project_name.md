# Sets the package-scoped value of project_name

Sets the package-scoped value of project_name

## Usage

``` r
set_project_name(project_name = "")
```

## Arguments

- project_name:

  Defaults to NULL. If provided and not NULL, this value is used. If
  NULL, the function attempts to fetch the value from the environment
  variable.

## Value

the package-scoped value of project_name

## Examples

``` r
if (FALSE) { # \dontrun{
project_name <- set_project_name()
project_name <- set_project_name("project_name")
} # }
```
