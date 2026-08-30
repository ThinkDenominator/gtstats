# Add a proportion row to a descriptive table

Add a row showing the proportion of a selected level of a binary,
categorical, or ordinal variable within a `gtstats` descriptive table.

## Usage

``` r
add_proportion(
  x,
  var,
  level = NULL,
  ci = TRUE,
  conf.level = NULL,
  ci_method = NULL,
  display = NULL,
  layout = NULL,
  digits = NULL,
  label = NULL
)
```

## Arguments

- x:

  A `gtstats_summary` object created with
  [`summary_table()`](https://gtstats.thinkdenominator.com/reference/summary_table.md).

- var:

  Variable to summarise as a proportion. Can be supplied as a bare name
  or as a character string.

- level:

  Optional level to count. If `NULL`, a default level is selected
  automatically.

- ci:

  Logical; whether to display a confidence interval.

- conf.level:

  Confidence level for the interval. `NULL` inherits the parent table
  setting, usually `0.95`.

- ci_method:

  Confidence-interval method: `"wilson"` or `"exact"`. `NULL` inherits
  the parent table setting.

- display:

  Cell display: `"n_percent"`, `"percent"`, or `"n_over_N_percent"`.
  `NULL` inherits the categorical display used by the parent table.

- layout:

  Table layout. `NULL` inherits the parent table layout; `"compact"`
  keeps the estimate and CI together and `"separate"` places them in
  separate columns beneath each cohort header.

- digits:

  Number of decimal places used when formatting percentages. `NULL`
  inherits the parent table precision.

- label:

  Optional row label. Defaults to the variable label if available,
  otherwise the variable name.

## Value

An updated `gtstats_summary` object with a proportion row appended.

## Details

This is useful when you want to highlight a specific category such as
`"Yes"`, `"1"`, or `"TRUE"` within a Table 1 workflow. The row can be
added overall, by groups, or both, depending on how the descriptive
table was created.

If `level = NULL`, the function chooses a default level using the
following order:

- `"1"`

- `"Yes"` / `"yes"`

- `"TRUE"` / `"True"` / `"true"`

- the second available level for binary variables

- otherwise the first available non-missing level

Wilson confidence intervals are used by default. Exact binomial
intervals are available with `ci_method = "exact"`.

## Examples

``` r
summary_table(mtcars, by = am, overall = TRUE) |>
  add_proportion(var = vs)

summary_table(mtcars, by = am, overall = TRUE) |>
  add_proportion(var = vs, level = "1", ci = TRUE)

summary_table(mtcars) |>
  add_proportion(var = vs, ci = FALSE)
```
