# Inspect statistical assumptions

Return a plain-language checklist of items to confirm before reporting a
result. Use `view = "audit"` to retrieve the underlying technical status
and result codes retained by the analysis object.

## Usage

``` r
assumptions_stats(
  x,
  format = c("table", "tibble"),
  output = NULL,
  title = "Checks before reporting",
  subtitle = NULL,
  view = c("checklist", "audit")
)
```

## Arguments

- x:

  A `gtstats` result.

- format:

  Output format: `"table"` (default) or `"tibble"`.

- output:

  Compatibility alias accepting `"gt"`, `"table"`, or `"tibble"`.

- title, subtitle:

  Optional table heading used for `format = "table"`.

- view:

  Either `"checklist"` (the default, plain-language view) or `"audit"`
  (technical status and result codes).

## Value

A tibble or `gt_tbl`.

## Examples

``` r
result <- compare_groups(mtcars, variable = mpg, group = am)
assumptions_stats(result)


  


Checks before reporting
```
