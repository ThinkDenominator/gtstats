# Print a descriptive table

Print a completed `gt_desc_table` as a publication-ready `gt` table. An
empty builder instead prints a short instruction explaining how to add
rows.

## Usage

``` r
# S3 method for class 'gt_desc_table'
print(x, ...)
```

## Arguments

- x:

  A `gt_desc_table` object.

- ...:

  Further arguments passed to methods.

## Value

The input object, invisibly.

## Details

The print method shows the table mode, source data, grouping status,
whether an overall column is requested, and the first few rows of the
current table builder.

## Examples

``` r
x <- summary_table(mtcars, by = am, overall = TRUE)
print(x)
#> No variables have been selected.
#> Add variables using `include = c(age, sex, bmi)`, or use `include = everything()` to summarise all suitable variables.
```
