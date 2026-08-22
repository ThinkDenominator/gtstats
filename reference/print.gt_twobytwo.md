# Print a gtstats 2x2 table object

Print a compact console preview of a `gt_twobytwo` object.

## Usage

``` r
# S3 method for class 'gt_twobytwo'
print(x, ...)
```

## Arguments

- x:

  A `gt_twobytwo` object.

- ...:

  Further arguments passed to methods.

## Value

The input object, invisibly.

## Details

The print method shows the dataset name, row/reference definition,
column/event definition, and the display-ready 2x2 epidemiology table.

## Examples

``` r
x <- crosstabs(mtcars, row = am, col = vs)
print(x)
```
