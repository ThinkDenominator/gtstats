# Print a descriptive table

Print a completed `gtstats_summary` as a publication-ready `flextable`.
An empty builder instead prints a short instruction explaining how to
add rows.

## Usage

``` r
# S3 method for class 'gtstats_summary'
print(x, ...)
```

## Arguments

- x:

  A `gtstats_summary` object.

- ...:

  Further arguments passed to methods.

## Value

The input object, invisibly.

## Details

Use `format = "tibble"` in
[`summary_table()`](https://gtstats.thinkdenominator.com/reference/summary_table.md)
for a plain console table, or call
[`to_gt()`](https://gtstats.thinkdenominator.com/reference/to_gt.md)
when an HTML-oriented `gt` table is required.

## Examples

``` r
x <- summary_table(mtcars, by = am, overall = TRUE)
print(x)
#> No variables have been selected.
#> Add variables using `include = c(age, sex, bmi)`, or use `include = everything()` to summarise all suitable variables.
```
