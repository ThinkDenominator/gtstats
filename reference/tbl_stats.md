# Create formatted gt tables from gtstats objects

Render supported `gtstats` objects as formatted `gt` tables.

## Usage

``` r
tbl_stats(
  x,
  title = NULL,
  subtitle = NULL,
  digits = NULL,
  pvalue_style = c("default", "scientific"),
  bold_labels = TRUE,
  show_footnotes = TRUE
)
```

## Arguments

- x:

  A supported `gtstats` object.

- title:

  Optional table title.

- subtitle:

  Optional table subtitle.

- digits:

  Optional digits argument reserved for future use.

- pvalue_style:

  P-value display style. Currently stored but reserved for future
  formatting extensions.

- bold_labels:

  Logical; whether to bold variable labels where appropriate.

- show_footnotes:

  Logical; whether explanatory footnotes should be displayed.

## Value

A `gt_tbl` object.

## Details

This function is the main rendering bridge between analytical `gtstats`
objects and presentation-ready table output. It supports descriptive,
inferential, epidemiological, and table-builder objects created by the
package and applies a consistent visual style using `gt`.

Supported inputs include:

- `gt_describe`

- `gt_distribution`

- `gt_variance`

- `gt_compare`

- `gt_correlation`

- `gt_effect`

- `gt_prop`

- `gt_rate`

- `gt_twobytwo`

- `gt_desc_table`

## Examples

``` r
tbl_stats(describe_data(mtcars))


  

Variable
```
