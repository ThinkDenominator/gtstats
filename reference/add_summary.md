# Add summary rows to a descriptive table

Add summary statistics to a `gtstats` descriptive table builder.

## Usage

``` r
add_summary(
  x,
  vars,
  continuous_format = c("recommended", "mean_sd", "mean_ci", "median_iqr", "both"),
  statistic = NULL,
  percent = c("column", "row", "overall", "none"),
  categorical = c("n_percent", "n_over_N_percent", "n", "percent"),
  categorical_layout = c("combined", "separate"),
  show_dichotomous = c("all_levels", "single_row"),
  value = NULL,
  ci = FALSE,
  conf.level = 0.95,
  ci_method = c("wilson", "exact"),
  layout = NULL,
  missing = c("ifany", "always", "no"),
  digits = 1
)
```

## Arguments

- x:

  A `gt_desc_table` object created with
  [`summary_table()`](https://gtstats.thinkdenominator.com/reference/summary_table.md).

- vars:

  Variables to summarise. Can be supplied as bare names or as a
  character vector.

- continuous_format:

  Format to use for continuous variables. One of `"recommended"`,
  `"mean_sd"`, `"mean_ci"`, `"median_iqr"`, or `"both"`.

- statistic:

  Optional continuous summary selection. A single value applies to all
  selected continuous variables. A named character vector can select a
  different summary for each variable, for example
  `c(age = "mean_sd", bmi = "median_iqr")`. `"auto"` is accepted as an
  alias for `"recommended"`.

- percent:

  Denominator for categorical percentages: `"column"` uses the
  non-missing denominator within each group, `"row"` distributes each
  level across groups, `"overall"` uses the overall non-missing
  denominator, and `"none"` displays counts only.

- categorical:

  Display for categorical values: `"n_percent"`, `"n_over_N_percent"`,
  `"n"`, or `"percent"`.

- categorical_layout:

  Categorical display layout. `"combined"` keeps n and % together.
  `"separate"` creates distinct n and % child columns and is available
  for categorical-only tables without confidence intervals.

- show_dichotomous:

  How binary variables are displayed. `"all_levels"` (default) shows
  both levels. `"single_row"` shows one event level as a compact row
  using the variable label.

- value:

  Optional named character vector or named list selecting the event
  level used when `show_dichotomous = "single_row"`, for example
  `c(smoke = "Yes", hypertension = "Yes")`. When omitted, the second
  declared factor level (or the second sorted observed value) is used.

- ci:

  Logical; append confidence intervals to categorical proportions.

- conf.level:

  Confidence level for categorical proportion intervals.

- ci_method:

  Binomial confidence-interval method: `"wilson"` (default) or
  `"exact"`.

- layout:

  Table layout. `"compact"` keeps each summary in one cell; `"separate"`
  places summaries and confidence intervals in separate columns once
  intervals are added. It does not create empty CI columns. When
  omitted, the layout chosen in
  [`summary_table()`](https://gtstats.thinkdenominator.com/reference/summary_table.md)
  is used.

- missing:

  Whether explicit missing-value rows are shown: `"ifany"`, `"always"`,
  or `"no"`.

- digits:

  One number applied throughout, or a named numeric vector using
  `continuous`, `percent`, and `ci`.

## Value

An updated `gt_desc_table` object with summary rows added.

## Details

This function is the main way to populate a descriptive table with
variable summaries. It supports both grouped and ungrouped tables and
can optionally add an `Overall` column when the descriptive table was
created with `overall = TRUE`.

Continuous variables can be displayed in one of four formats:

- `"recommended"`: mean (SD) or median (IQR) as appropriate

- `"mean_sd"`: mean (SD)

- `"mean_ci"`: mean with a t confidence interval

- `"median_iqr"`: median (IQR)

- `"both"`: mean (SD) and median (IQR)

Variable names may be supplied either as bare names, for example
`c(age, sex, bmi)`, or as a character vector, for example
`c("age", "sex", "bmi")`.

## Examples

``` r
summary_table(mtcars, by = am) |>
  add_summary(vars = c(mpg, wt, cyl))

summary_table(mtcars, by = am, overall = TRUE) |>
  add_summary(vars = c("mpg", "wt", "cyl"))

summary_table(mtcars) |>
  add_summary(vars = c(mpg, wt), continuous_format = "mean_sd")
```
