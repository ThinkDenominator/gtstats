# Inspect statistical denominators

Return a transparent audit of the observations, missing values,
numerators, denominators, and denominator rules used in a `gtstats`
result.

## Usage

``` r
denominators_stats(
  x,
  format = c("table", "tibble"),
  output = NULL,
  title = "Denominator audit",
  subtitle = NULL,
  view = c("readable", "audit")
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

  Either `"readable"` (the default, plain-language headings) or
  `"audit"` (raw field names retained by the analysis object).

## Value

A tibble or `gt_tbl`.

## Examples

``` r
result <- proportion_stats(mtcars, var = vs, by = am)
denominators_stats(result)


  


Denominator audit
```
