# Add total counts to a descriptive table

Add a total row to a `gtstats` descriptive table showing the number of
observations overall or within each displayed group.

## Usage

``` r
add_total(x, label = "Total (N)", position = c("last", "first"))
```

## Arguments

- x:

  A `gtstats_summary` object created with
  [`summary_table()`](https://gtstats.thinkdenominator.com/reference/summary_table.md).

- label:

  Row label to display in the `Variable` column. Defaults to
  `"Total (N)"`.

- position:

  Position of the total row. Use `"first"` to place sample sizes at the
  top of the table or `"last"` to append them.

## Value

An updated `gtstats_summary` object with a total row appended.

## Details

This helper is useful in Table 1 workflows where a final row is needed
to show the number of observations contributing to each column. When the
table includes an `Overall` column, the total number of rows in the
source data is shown there. When the table is grouped, totals are
calculated within each displayed group. Publication-table headers
already display these cohort denominators automatically, so this row is
optional.

This helper can be used only with descriptive tables created in
`mode = "summary"`.

## Examples

``` r
summary_table(mtcars, by = am, include = c(mpg, wt, cyl)) |>
  add_total()

summary_table(mtcars, by = am, include = c(mpg, wt), overall = TRUE) |>
  add_total()

summary_table(mtcars) |>
  add_total()
```
