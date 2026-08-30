# Inspect statistical diagnostics

Return diagnostic checks, observed values, thresholds, and
interpretations retained by a `gtstats` result.

## Usage

``` r
diagnostics_stats(
  x,
  format = c("table", "tibble"),
  title = "Diagnostics",
  subtitle = NULL,
  view = c("readable", "audit")
)
```

## Arguments

- x:

  A `gtstats` result.

- format:

  Output format: `"table"` (default) or `"tibble"`.

- title, subtitle:

  Optional table heading used for `format = "table"`.

- view:

  Either `"readable"` (the default, plain-language headings) or
  `"audit"` (raw diagnostic codes retained by the analysis object).

## Value

A tibble or `gt_tbl`.

## Examples

``` r
result <- compare_groups(mtcars, variable = vs, group = am)
diagnostics_stats(result)


  


Diagnostics
```
