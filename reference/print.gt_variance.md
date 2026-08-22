# Print a gtstats variance object

Print publication-ready variance diagnostics. Group-level sample sizes,
standard deviations, variances, and observed spread ratios are
displayed; the underlying values and explanatory metadata remain
available in `$summary` and `$diagnostics`.

## Usage

``` r
# S3 method for class 'gt_variance'
print(x, ...)
```

## Arguments

- x:

  A `gt_variance` object.

- ...:

  Further arguments passed to methods.

## Value

The input object, invisibly.

## Examples

``` r
x <- assess_variance(mtcars, vars = c(mpg, wt), by = am)
print(x)
```
