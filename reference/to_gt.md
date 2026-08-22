# Convert a gtstats result to a gt table

Explicitly render a supported `gtstats` result as a publication-ready
[`gt::gt()`](https://gt.rstudio.com/reference/gt.html) table. Package
print methods use
[`to_flextable()`](https://gtstats.thinkdenominator.com/reference/to_flextable.md)
by default; `to_gt()` is the opt-in route for HTML-oriented `gt`
workflows.

## Usage

``` r
to_gt(
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

## Examples

``` r
to_gt(summary_table(mtcars, include = c(mpg, wt)))


  

Characteristic1
```
