# Print a gtstats effect-size object

Print the publication-ready table stored by a `gt_effect` object.

## Usage

``` r
# S3 method for class 'gt_effect'
print(x, ...)
```

## Arguments

- x:

  A `gt_effect` object.

- ...:

  Further arguments passed to
  [`tbl_stats()`](https://gtstats.thinkdenominator.com/reference/tbl_stats.md).

## Value

The input object, invisibly.

## Examples

``` r
x <- effect_size(mtcars, variable = mpg, group = am)
print(x)
```
