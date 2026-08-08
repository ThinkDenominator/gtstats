# Inspect statistical denominators

Return a transparent audit of the observations, missing values,
numerators, denominators, and denominator rules used in a `gtstats`
result.

## Usage

``` r
denominators_stats(
  x,
  output = c("tibble", "gt"),
  title = "Denominator audit",
  subtitle = NULL,
  view = c("readable", "audit")
)
```

## Arguments

- x:

  A `gtstats` result.

- output:

  Return a `"tibble"` or formatted `"gt"` table.

- title, subtitle:

  Optional table heading used for `output = "gt"`.

- view:

  Either `"readable"` (the default, plain-language headings) or
  `"audit"` (raw field names retained by the analysis object).

## Value

A tibble or `gt_tbl`.

## Examples

``` r
result <- proportion_stats(mtcars, var = vs, by = am)
denominators_stats(result)
#> # A tibble: 2 × 9
#>   Variable Level Group  `Eligible observations` `Used in analysis`
#>   <chr>    <chr> <chr>                    <int>              <int>
#> 1 vs       NA    am = 1                      13                 13
#> 2 vs       NA    am = 0                      19                 19
#> # ℹ 4 more variables: `Missing / excluded` <int>, Numerator <int>,
#> #   Denominator <dbl>, Rule <chr>
```
