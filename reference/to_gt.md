# Convert a gtstats result to a gt table

Render supported `gtstats` objects as formatted `gt` tables.

## Usage

``` r
to_gt(
  x,
  title = NULL,
  subtitle = NULL,
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

- bold_labels:

  Logical; whether to bold variable labels where appropriate.

- show_footnotes:

  Logical; whether explanatory footnotes should be displayed.

## Value

A `gt_tbl` object.

## Details

This function is the explicit rendering bridge between analytical
`gtstats` objects and presentation-ready table output. It supports
descriptive, inferential, epidemiological, and table-builder objects
created by the package and applies a consistent visual style using `gt`.

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

- `gtstats_summary`

- `gt_data_table`

## Examples

``` r
to_gt(describe_data(mtcars))


  

Variable
```
