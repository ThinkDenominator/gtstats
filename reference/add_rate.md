# Add an event-rate row

Add an event rate to a table created with
[`summary_table()`](https://gtstats.thinkdenominator.com/reference/summary_table.md).
Event counts and accumulated time are calculated from complete
event-time pairs only. Event counts and time values must be finite.
Exact Poisson confidence intervals are shown by default. A row with zero
accumulated time is retained as `\u2014` and recorded as not estimable
in the audit.

## Usage

``` r
add_rate(
  x,
  event,
  time,
  label = NULL,
  multiplier = 1000,
  time_label = NULL,
  ci = TRUE,
  conf.level = 0.95,
  digits = 1,
  layout = NULL
)
```

## Arguments

- x:

  A `gtstats_summary` created with
  [`summary_table()`](https://gtstats.thinkdenominator.com/reference/summary_table.md).

- event:

  Non-negative integer event count, supplied as a bare name or character
  string. Logical values are accepted as binary event indicators.

- time:

  Non-negative numeric person-time or exposure-time variable.

- label:

  Optional row label.

- multiplier:

  Positive rate multiplier. Default is `1000`.

- time_label:

  Optional readable time unit such as `"person-years"` or
  `"catheter-days"`. Defaults to `"person-time"`.

- ci:

  Logical; display an exact Poisson confidence interval.

- conf.level:

  Confidence level.

- digits:

  Number of decimal places.

- layout:

  Table layout. `NULL` inherits the parent table layout; `"compact"`
  keeps rate and CI together and `"separate"` places them in separate
  columns beneath each cohort header.

## Value

The updated `gtstats_summary`.

## Details

Rate denominators are tracked separately from ordinary descriptive rows
and are stated in the table audit and footnote.

## Examples

``` r
summary_table(mtcars, by = am, overall = TRUE) |>
  add_rate(
    event = carb,
    time = cyl,
    label = "Carburettor rate",
    multiplier = 1000
  )

# Rates may be added alongside ordinary summaries
summary_table(mtcars, by = am, include = mpg) |>
  add_rate(event = carb, time = cyl, multiplier = 1000)
```
