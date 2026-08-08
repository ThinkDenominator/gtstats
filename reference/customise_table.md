# Customize a gtstats table

Apply titles, labels, alignment, emphasis, colours, and a predefined
visual theme to a table produced by `gtstats`.

## Usage

``` r
customise_table(
  x,
  theme = c("default", "journal", "classic", "minimal", "compact"),
  title = NULL,
  subtitle = NULL,
  source_note = NULL,
  col_labels = NULL,
  row_labels = NULL,
  level_labels = NULL,
  align = NULL,
  hide_cols = NULL,
  bold_cols = NULL,
  italic_cols = NULL,
  font_size = NULL,
  font = NULL,
  width = NULL,
  row_striping = NULL,
  accent_color = NULL,
  stripe_color = NULL,
  bold_labels = TRUE,
  show_footnotes = TRUE
)
```

## Arguments

- x:

  A supported `gtstats` result or rendered `gt_tbl`.

- theme:

  Visual theme: `"default"`, `"journal"`, `"classic"`, `"minimal"`, or
  `"compact"`.

- title, subtitle:

  Optional title and subtitle.

- source_note:

  Optional note below the table.

- col_labels, row_labels, level_labels:

  Named character vectors for relabelling.

- align:

  Named list of left-, right-, or centre-aligned columns.

- hide_cols:

  Columns to hide.

- bold_cols, italic_cols:

  Columns to emphasise.

- font_size:

  Font size in pixels.

- font:

  Optional font family.

- width:

  Table width as a percentage from 0 to 100.

- row_striping:

  Logical; apply alternating row shading.

- accent_color, stripe_color:

  Optional table colours.

- bold_labels:

  Logical; bold variable labels when rendering a raw result.

- show_footnotes:

  Logical; retain explanatory footnotes when rendering a raw result.

## Value

A styled `gt_tbl`.

## Examples

``` r
result <- summary_table(mtcars, include = c(mpg, wt))
customise_table(result, title = "Vehicle characteristics")


  


Vehicle characteristics
```
