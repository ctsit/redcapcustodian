# Sets the package-scoped value of project_instance

Sets the package-scoped value of project_instance

## Usage

``` r
set_project_instance(project_instance = "")
```

## Arguments

- project_instance:

  Defaults to NULL. If provided and not NULL, this value is used. If
  NULL, the function attempts to fetch the value from the environment
  variable.

## Value

the package-scoped value of project_instance

## Examples

``` r
if (FALSE) { # \dontrun{
project_instance <- set_project_instance()
project_instance <- set_project_instance("project_instance")
} # }
```
