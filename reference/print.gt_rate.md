# Print a gtstats rate object

Print a compact console preview of a `gt_rate` object.

## Usage

``` r
# S3 method for class 'gt_rate'
print(x, ...)
```

## Arguments

- x:

  A `gt_rate` object.

- ...:

  Further arguments passed to methods.

## Value

The input object, invisibly.

## Details

The print method shows the dataset name, event variable, person-time
variable, optional grouping variable, and the display-ready rate table.

## Examples

``` r
df <- data.frame(
  event = c(1, 0, 1, 0, 1, 1),
  ptime = c(10, 12, 8, 9, 11, 7),
  arm = c("A", "A", "A", "B", "B", "B")
)
x <- rate_stats(df, event = event, time = ptime, by = arm)
print(x)
```
