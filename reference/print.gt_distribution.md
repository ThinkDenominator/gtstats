# Print a gtstats distribution object

Print publication-ready distribution diagnostics and recommendations.

## Usage

``` r
# S3 method for class 'gt_distribution'
print(x, ...)
```

## Arguments

- x:

  A `gt_distribution` object.

- ...:

  Further arguments passed to methods.

## Value

The input object, invisibly.

## Details

The detailed diagnostic table includes the suggested presentation beside
the numerical diagnostics. With groups, the common variable-level
suggestion is shown once beside the first group row. Machine-readable
results remain available in `$summary` and `$recommendations`.

## Examples

``` r
x <- assess_distribution(mtcars, vars = c("mpg", "wt"))
print(x)
```
