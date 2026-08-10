# Inspect statistical diagnostics

Return diagnostic checks, observed values, thresholds, and
interpretations retained by a `gtstats` result.

## Usage

``` r
diagnostics_stats(
  x,
  output = c("tibble", "gt"),
  title = "Diagnostics",
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
  `"audit"` (raw diagnostic codes retained by the analysis object).

## Value

A tibble or `gt_tbl`.

## Examples

``` r
result <- compare_groups(mtcars, variable = vs, group = am)
diagnostics_stats(result)
#> # A tibble: 4 × 6
#>   Variable Check                Result `Observed value` Reference Interpretation
#>   <chr>    <chr>                <chr>  <chr>            <chr>     <chr>         
#> 1 NA       Comparison design    indep… Independent obs… Defined … Independent c…
#> 2 NA       Variance assumption  not a… var_equal = FAL… Applies … `var_equal` d…
#> 3 NA       Automatic test sele… Chi-s… 5.69             All expe… Independent c…
#> 4 NA       Expected cell counts adequ… 5.69             Minimum … Fisher's exac…
```
