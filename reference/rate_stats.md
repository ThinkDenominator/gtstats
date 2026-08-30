# Incidence rate with exact Poisson confidence interval

Compute an incidence or event rate with exact Poisson confidence
intervals, either overall or within groups defined by a categorical
variable.

## Usage

``` r
rate_stats(
  data,
  event,
  time,
  by = NULL,
  multiplier = 1000,
  time_label = NULL,
  conf.level = 0.95,
  digits = 1,
  format = c("table", "tibble")
)
```

## Arguments

- data:

  A data.frame.

- event:

  Event variable. Can be supplied as a bare name or as a character
  string. May be binary (`0/1`, `TRUE/FALSE`) or a count variable.

- time:

  Person-time variable. Can be supplied as a bare name or as a character
  string. Must be numeric and non-negative.

- by:

  Optional grouping variable. Can be supplied as a bare name or as a
  character string.

- multiplier:

  Numeric multiplier used to scale the rate, for example `1000` or
  `100000`. Default is `1000`.

- time_label:

  Optional readable unit for accumulated time, such as `"person-years"`
  or `"catheter-days"`. Defaults to `"person-time"`.

- conf.level:

  Confidence level for the interval. Default is `0.95`.

- digits:

  Number of decimal places used when formatting rates. Default is `1`.

- format:

  Output format: `"table"` (default) or a plain console `"tibble"`.

## Value

A `gt_rate` object containing:

- `inputs` — function inputs and settings

- `summary` — detailed summary table

- `table` — display-ready table

- `notes` — explanatory note

- `call` — matched function call

## Details

This function is designed for simple epidemiological summaries where
events are counted over a denominator of person-time. The `event`
variable may be a binary indicator, a logical variable, or a count
variable. The `time` variable must be numeric, finite, and non-negative.
A zero accumulated person-time denominator is retained and clearly
marked as not estimable rather than silently converted to a rate.

When a grouping variable is supplied, rates are calculated separately
within each group. Confidence intervals are calculated using
[`stats::poisson.test()`](https://rdrr.io/r/stats/poisson.test.html).
The publication table uses each group as a spanning header, with
separate columns for events, accumulated time, rate, and confidence
interval. The tidy long-form numerical results remain available in
`$summary`.

## Examples

``` r
df <- data.frame(
  event = c(1, 0, 1, 0, 1, 1),
  ptime = c(10, 12, 8, 9, 11, 7),
  arm = c("A", "A", "A", "B", "B", "B")
)

rate_stats(df, event = event, time = ptime)

rate_stats(df, event = event, time = ptime, by = arm)

to_gt(rate_stats(df, event = event, time = ptime, by = arm))


  


Event
```
