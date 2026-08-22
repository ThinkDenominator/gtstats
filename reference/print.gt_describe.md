# Print a gtstats describe object

Print the publication-ready table stored by a `gt_describe` object.

## Usage

``` r
# S3 method for class 'gt_describe'
print(x, ...)
```

## Arguments

- x:

  A `gt_describe` object.

- ...:

  Further arguments passed to methods.

## Value

The input object, invisibly.

## Details

The underlying concise tibble remains available in `$summary`, and
focused data-quality findings are available in `$issues`.

## Examples

``` r
x <- describe_data(mtcars)
print(x)
```
