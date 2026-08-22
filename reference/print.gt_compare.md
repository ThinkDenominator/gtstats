# Print a gtstats compare object

Print a publication-ready comparison table.

## Usage

``` r
# S3 method for class 'gt_compare'
print(x, ...)
```

## Arguments

- x:

  A `gt_compare` object.

- ...:

  Further arguments passed to methods.

## Value

The input object, invisibly.

## Details

The print method renders the concise publication table. Detailed
numerical results and audit information remain available in the object
components.

## Examples

``` r
x <- compare_groups(mtcars, variable = mpg, group = am)
print(x)
```
