# Print a gtstats correlation object

Print a publication-ready correlation table.

## Usage

``` r
# S3 method for class 'gt_correlation'
print(x, ...)
```

## Arguments

- x:

  A `gt_correlation` object.

- ...:

  Further arguments passed to methods.

## Value

The input object, invisibly.

## Details

Detailed numerical results and audit information remain available in the
object components.

## Examples

``` r
x <- correlation(mtcars, x = mpg, y = wt)
print(x)
```
