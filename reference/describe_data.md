# Understand a dataset before analysis

Create a concise, clinically oriented first look at a dataset. One row
is returned per variable, combining its label, detected type,
completeness, cardinality, a type-specific overview, and range or
levels. Potential data-quality findings are kept separately in
`$issues`.

## Usage

``` r
describe_data(data, vars = NULL, digits = 2, format = c("table", "tibble"))
```

## Arguments

- data:

  A data.frame.

- vars:

  Optional character vector of variables. Default is all variables.

- digits:

  Number of decimal places in concise numeric summaries.

- format:

  Output format: `"table"` (default) or `"tibble"`.

## Value

With `format = "table"`, a `gt_describe` object that prints as a
publication-ready table. `$summary` is the concise variable overview and
`$issues` contains only findings requiring review. With
`format = "tibble"`, the concise summary tibble is returned directly.

## Details

`describe_data()` deliberately does not assess distributional
assumptions or recommend inferential tests. Use
[`assess_distribution()`](https://gtstats.thinkdenominator.com/reference/assess_distribution.md)
for the shape of selected continuous variables,
[`summary_table()`](https://gtstats.thinkdenominator.com/reference/summary_table.md)
for detailed descriptive statistics, and
[`compare_groups()`](https://gtstats.thinkdenominator.com/reference/compare_groups.md)
for inferential comparisons.

## Examples

``` r
describe_data(mtcars)
describe_data(mtcars, vars = c("mpg", "cyl", "am"))
to_gt(describe_data(mtcars))


  

Variable
```
