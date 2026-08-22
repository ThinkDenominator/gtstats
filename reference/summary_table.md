# Create a summary table builder

Create the descriptive foundation of a publication-ready table. Add
further layers only when needed:
[`add_ci()`](https://gtstats.thinkdenominator.com/reference/add_ci.md)
for confidence intervals,
[`add_p()`](https://gtstats.thinkdenominator.com/reference/add_p.md) for
statistical comparisons, and specialist helpers such as
[`add_proportion()`](https://gtstats.thinkdenominator.com/reference/add_proportion.md),
[`add_rate()`](https://gtstats.thinkdenominator.com/reference/add_rate.md),
[`add_total()`](https://gtstats.thinkdenominator.com/reference/add_total.md),
and
[`add_row()`](https://gtstats.thinkdenominator.com/reference/add_row.md).

## Usage

``` r
summary_table(
  data,
  by = NULL,
  include = NULL,
  mode = c("summary", "rate"),
  overall = FALSE,
  statistic = "recommended",
  categorical = c("n_percent", "n_over_N_percent", "n", "percent"),
  categorical_layout = c("combined", "separate"),
  show_dichotomous = c("all_levels", "single_row"),
  value = NULL,
  percent = c("column", "row", "overall"),
  digits = 1,
  missing = c("ifany", "always", "no"),
  layout = c("compact", "separate"),
  label = NULL,
  format = c("table", "tibble"),
  ...
)
```

## Arguments

- data:

  A data.frame.

- by:

  Optional grouping variable. Can be supplied as a bare name or as a
  character string. The grouping variable must be categorical, binary,
  or ordinal.

- include:

  Optional variables to summarise immediately. Supply bare names, such
  as `c(age, sex, bmi)`, or a character vector. Mixed variable types can
  be selected together. When omitted, an empty advanced builder is
  returned.

- mode:

  Table mode. `"summary"` is the normal route. `"rate"` is retained for
  compatibility with earlier rate-only builders.

- overall:

  Overall-column setting. Use `FALSE` to omit it, `"first"` to place it
  before the grouped columns, or `"last"` to place it after them. `TRUE`
  is accepted as a shorthand for `"first"`.

- statistic:

  Continuous summary format: `"recommended"`, `"mean_sd"`, `"mean_ci"`,
  `"median_iqr"`, or `"both"`. A single value applies to all continuous
  variables. In a named vector, `continuous` supplies a fallback for
  every continuous variable and variable names supply exceptions, for
  example `c(continuous = "mean_sd", lwt = "median_iqr")`. Without a
  `continuous` fallback, unnamed variables use the recommended summary.

- categorical:

  Categorical display: `"n_percent"`, `"n_over_N_percent"`, `"n"`, or
  `"percent"`.

- categorical_layout:

  Categorical column layout. `"combined"` (default) displays n (%).
  `"separate"` places n and % in distinct child columns for
  categorical-only tables without confidence intervals.

- show_dichotomous:

  Binary-variable display. `"all_levels"` (default) shows both levels;
  `"single_row"` shows one selected event level as a compact row.

- value:

  Optional named character vector or list selecting the event level for
  compact binary rows, for example `c(smoke = "Yes")`. Unspecified
  binary variables use their second declared or sorted level.

- percent:

  Percentage denominator: `"column"`, `"row"`, or `"overall"`.

- digits:

  One number applied throughout, or a named numeric vector using
  `continuous`, `percent`, and `ci`.

- missing:

  Missing-row display: `"ifany"`, `"always"`, or `"no"`.

- layout:

  Table layout. `"compact"` keeps each summary in one cell. `"separate"`
  requests summary and CI child columns beneath each cohort header.
  Those child columns appear only after confidence intervals are added;
  choosing the layout alone does not create empty CI columns.

- label:

  Optional named character vector overriding variable labels.

- format:

  Display format: `"table"` (default) or `"tibble"`. The builder remains
  composable; this option changes how the completed object prints
  without discarding its audit components.

- ...:

  Compatibility arguments `ci`, `conf.level`, and `ci_method` from
  earlier development versions. New code should use
  [`add_ci()`](https://gtstats.thinkdenominator.com/reference/add_ci.md).
  Unknown arguments are rejected.

## Value

A `gt_desc_table` object containing the source data, structural
settings, and placeholders for table components.

## Details

For the usual Table 1 workflow, select all variables together with
`include`. Continuous, binary, categorical, and ordinal variables are
detected automatically and added using beginner-friendly defaults. There
is no need to add continuous and categorical variables separately.

When `include = NULL`, an empty builder is returned for specialist
row-only workflows. Printing a completed object automatically displays a
publication-ready `gt` table; call
[`tbl_stats()`](https://gtstats.thinkdenominator.com/reference/tbl_stats.md)
only when explicit rendering control is required.

`mode = "rate"` remains available for compatibility, but is not needed
in new code: create the foundation normally and add
[`add_rate()`](https://gtstats.thinkdenominator.com/reference/add_rate.md)
as a layer.

A grouping variable may be supplied to create one column per group. An
optional `overall` column can also be requested for later use.

## Examples

``` r
summary_table(
  mtcars,
  by = am,
  include = c(mpg, wt, cyl, vs),
  overall = TRUE
)

summary_table(
  mtcars,
  by = am,
  include = c(mpg, wt, cyl, vs),
  overall = TRUE
) |>
  add_p()

# Percentages without decimals and Overall displayed last
summary_table(
  mtcars,
  by = am,
  include = c(mpg, wt, cyl, vs),
  overall = "last",
  digits = c(continuous = 1, percent = 0)
)

# Add confidence intervals as a visible layer
summary_table(
  mtcars,
  include = c(cyl, vs),
  categorical = "percent",
  layout = "separate"
) |>
  add_ci()

# Compact binary rows, with an explicit event where required
summary_table(
  mtcars,
  include = c(mpg, vs, am),
  show_dichotomous = "single_row",
  value = c(vs = "1", am = "1")
)
```
