# Inspect statistical assumptions

Return a plain-language checklist of items to confirm before reporting a
result. Use `view = "audit"` to retrieve the underlying technical status
and result codes retained by the analysis object.

## Usage

``` r
assumptions_stats(
  x,
  output = c("tibble", "gt"),
  title = "Checks before reporting",
  subtitle = NULL,
  view = c("checklist", "audit")
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

  Either `"checklist"` (the default, plain-language view) or `"audit"`
  (technical status and result codes).

## Value

A tibble or `gt_tbl`.

## Examples

``` r
result <- compare_groups(mtcars, variable = mpg, group = am)
assumptions_stats(result)
#> # A tibble: 2 × 4
#>   Variable `Check before reporting`              Action                  Details
#>   <chr>    <chr>                                 <chr>                   <chr>  
#> 1 NA       Independent observations              Confirm from study des… Confir…
#> 2 NA       Distribution and influential outliers Review alongside autom… Inspec…
assumptions_stats(result, output = "gt")


  


Checks before reporting
```
