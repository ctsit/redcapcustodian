# Assign a value to the redcapcustodian.env environment, retrievable with [`get_package_scope_var`](get_package_scope_var.md)

Assign a value to the redcapcustodian.env environment, retrievable with
[`get_package_scope_var`](get_package_scope_var.md)

Assign a value to the redcapcustodian.env environment, retrievable with
[`get_package_scope_var`](get_package_scope_var.md)

## Usage

``` r
set_package_scope_var(key, value)

set_package_scope_var(key, value)
```

## Arguments

- key:

  The identifying string to store as the lookup key

- value:

  The value to store

## Examples

``` r
if (FALSE) { # \dontrun{
  set_package_scope_var("hello", "world")
  hello <- get_package_scope_var("hello")
} # }
if (FALSE) { # \dontrun{
  set_package_scope_var("hello", "world")
  hello <- get_package_scope_var("hello")
} # }
```
