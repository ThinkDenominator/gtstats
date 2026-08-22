# Proportion statistics

Calculate a proportion and confidence interval, optionally within
groups. This is the descriptive-statistics counterpart to
[`rate_stats()`](https://gtstats.thinkdenominator.com/reference/rate_stats.md).

## Usage

``` r
proportion_stats(
  data,
  var,
  by = NULL,
  level = NULL,
  conf.level = 0.95,
  ci_method = c("wilson", "exact"),
  display = c("n_percent", "percent", "n_over_N_percent"),
  digits = 1,
  format = c("table", "tibble")
)
```

## Arguments

- data:

  A data frame.

- var:

  Binary or categorical variable whose selected level is counted.

- by:

  Optional categorical grouping variable.

- level:

  Outcome level to count. A sensible event level is selected when
  omitted.

- conf.level:

  Confidence level for the interval.

- ci_method:

  Confidence-interval method: `"wilson"` (default) or `"exact"`.

- display:

  Estimate display: `"n_percent"`, `"percent"`, or `"n_over_N_percent"`.
  The publication table places the confidence interval in a separate
  column; with `by`, each group spans its estimate and interval columns.

- digits:

  Number of decimal places.

- format:

  Output format: `"table"` (default) or a plain console `"tibble"`.

## Value

A `gt_prop` object containing numeric results and a display table.

## Examples

``` r
proportion_stats(mtcars, var = vs)
proportion_stats(mtcars, var = vs, by = am)
```
