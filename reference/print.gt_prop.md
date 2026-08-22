# Print a gtstats proportion object

Print a compact console preview of a `gt_prop` object.

## Usage

``` r
# S3 method for class 'gt_prop'
print(x, ...)
```

## Arguments

- x:

  A `gt_prop` object.

- ...:

  Further arguments passed to methods.

## Value

The input object, invisibly.

## Details

The print method shows the dataset name, variable, selected level,
optional grouping variable, and the display-ready proportion table.

## Examples

``` r
x <- proportion_stats(mtcars, var = vs, by = am)
print(x)
```
