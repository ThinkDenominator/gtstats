# Add confidence intervals to a summary table

Add confidence intervals to all eligible summaries, or only to selected
variables, without rebuilding the descriptive table. Categorical
variables receive binomial confidence intervals for their displayed
proportions. Continuous variables displayed with a mean receive a
t-based confidence interval for the mean. Median-only summaries are left
unchanged because a distribution-free median interval is not implied by
the displayed IQR. Compact tables show the interval after the estimate
without repeating the confidence level in every cell. Separate tables
use concise `CI` child columns. The confidence level and interval method
are stated once in the publication footnote.

## Usage

``` r
add_ci(
  x,
  vars = NULL,
  conf.level = 0.95,
  method = c("wilson", "exact"),
  digits = NULL,
  type = NULL,
  estimate = NULL,
  numerator = NULL,
  denominator = NULL,
  sd = NULL,
  n = NULL,
  se = NULL,
  multiplier = 1,
  ci_name = NULL
)
```

## Arguments

- x:

  A table created by
  [`summary_table()`](https://gtstats.thinkdenominator.com/reference/summary_table.md)
  or
  [`as_stats_table()`](https://gtstats.thinkdenominator.com/reference/as_stats_table.md).

- vars:

  Variables that should receive confidence intervals. `NULL` (default)
  selects every eligible variable already in the table. Variables may be
  supplied as bare names, for example `c(age, sex)`, or as a character
  vector.

- conf.level:

  Confidence level. Default is `0.95`.

- method:

  Binomial interval method for categorical proportions: `"wilson"`
  (default) or `"exact"`. Continuous mean intervals use the usual t
  interval.

- digits:

  Decimal places for confidence limits. `NULL` inherits the
  confidence-interval precision from the table.

- type:

  For
  [`as_stats_table()`](https://gtstats.thinkdenominator.com/reference/as_stats_table.md)
  input, the explicit aggregate-data calculation: `"proportion"`,
  `"rate"`, `"mean"`, or `"normal"`.

- estimate, numerator, denominator, sd, n, se:

  Columns containing the required aggregate inputs. Supply bare column
  names or single character names. Proportions and rates require
  `numerator` and `denominator`; means require `estimate`, `sd`, and
  `n`; normal intervals require `estimate` and `se`.

- multiplier:

  Positive rate multiplier, such as `1000` person-years.

- ci_name:

  Optional name for the added interval column. The default is the
  confidence-level label, for example `"95% CI"`.

## Value

The updated `gtstats_summary` object.

## Examples

``` r
summary_table(mtcars, by = am, include = c(mpg, cyl), layout = "separate") |>
  add_ci()

summary_table(mtcars, by = am, include = c(mpg, cyl, vs)) |>
  add_ci(vars = c(mpg, vs), conf.level = 0.90)

aggregate_rates <- data.frame(
  Group = c("A", "B"), Events = c(8, 14), PersonYears = c(420, 510)
)
as_stats_table(aggregate_rates) |>
  add_ci(type = "rate", numerator = Events, denominator = PersonYears,
         multiplier = 1000)
```
