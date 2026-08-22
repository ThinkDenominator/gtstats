# Add a custom row to a descriptive table

Add a user-defined row to a `gtstats` descriptive table. This is useful
for inserting contextual information such as study period, data source,
setting, or other custom annotations that should appear alongside the
main table content.

## Usage

``` r
add_row(x, label, overall = NULL, values = NULL, level = "")
```

## Arguments

- x:

  A `gt_desc_table` object created with
  [`summary_table()`](https://gtstats.thinkdenominator.com/reference/summary_table.md).

- label:

  A single character string giving the row label to display in the
  `Variable` column.

- overall:

  Optional value to display in the `Overall` column when the descriptive
  table includes `overall = TRUE`.

- values:

  Optional named character vector or named list giving values for
  displayed group columns. Names must match the displayed group column
  names, for example
  `c("am = 1" = "2020-2024", "am = 0" = "2020-2024")`.

- level:

  Optional text to display in the `Level` column. Defaults to an empty
  string.

## Value

An updated `gt_desc_table` object with the custom row appended.

## Details

The row is matched to the current table structure automatically:

- if `overall = TRUE`, an `Overall` column is supported

- if `by` is used, values must be named using displayed group column
  names

- if neither `overall` nor `by` is used, a single `Value` column is used

## Examples

``` r
res <- summary_table(mtcars, by = am, include = c(mpg, wt), overall = TRUE) |>
  add_row(
    label = "Study period",
    overall = "2020-2024",
    values = c("am = 1" = "2020-2024", "am = 0" = "2020-2024")
  )
```
