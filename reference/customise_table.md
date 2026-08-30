# Customize a gtstats table

Apply titles, labels, alignment, emphasis, colours, and a predefined
visual theme to a table produced by `gtstats`.

## Usage

``` r
customise_table(
  x,
  engine = c("flextable", "gt"),
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
  show_footnotes = TRUE,
  spanning_header = NULL,
  footnotes = NULL,
  borders = c("horizontal", "all", "minimal"),
  density = c("standard", "compact", "spacious"),
  column_widths = NULL,
  pvalue_style = c("threshold", "fixed", "scientific"),
  pvalue_digits = 3,
  pvalue_threshold = 0.001,
  pvalue_prefix = FALSE
)
```

## Arguments

- x:

  A supported `gtstats` result, rendered `flextable`, or rendered
  `gt_tbl`.

- engine:

  Rendering engine used when `x` is an unrendered result. `"flextable"`
  is the default; use `"gt"` for HTML-oriented workflows.

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

- spanning_header:

  Optional spanning heading. Supply one character value to span all
  result columns, or a named list/vector mapping displayed headings to
  completed column names.

- footnotes:

  Optional additional footer notes.

- borders:

  Border style: `"horizontal"`, `"all"`, or `"minimal"`.

- density:

  Cell density: `"standard"`, `"compact"`, or `"spacious"`.

- column_widths:

  Optional named numeric vector of column widths in inches for flextable
  output.

- pvalue_style:

  P-value style for summary-table results: `"threshold"`, `"fixed"`, or
  `"scientific"`.

- pvalue_digits:

  Number of displayed p-value digits.

- pvalue_threshold:

  Threshold displayed using a less-than sign.

- pvalue_prefix:

  Logical; prepend `p =` to ordinary p-values.

## Value

A styled `flextable` by default, or a `gt_tbl` when `engine = "gt"` or
`x` is already a gt table.

## Examples

``` r
result <- summary_table(mtcars, include = c(mpg, wt))
customise_table(result, title = "Vehicle characteristics")


.cl-bc8aa09c{}.cl-bc81e970{font-family:'DejaVu Sans';font-size:10pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-bc81e984{font-family:'DejaVu Sans';font-size:10pt;font-weight:bold;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-bc81e985{font-family:'DejaVu Sans';font-size:8pt;font-weight:normal;font-style:normal;text-decoration:none;color:rgba(0, 0, 0, 1.00);background-color:transparent;}.cl-bc855362{margin:0;text-align:left;border-bottom: 0 solid rgba(0, 0, 0, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);padding-bottom:3pt;padding-top:3pt;padding-left:3pt;padding-right:3pt;line-height: 1;background-color:transparent;}.cl-bc857a86{width:1.306in;background-color:transparent;vertical-align: middle;border-bottom: 0.75pt solid rgba(166, 166, 166, 1.00);border-top: 0.75pt solid rgba(166, 166, 166, 1.00);border-left: 0.75pt solid rgba(166, 166, 166, 1.00);border-right: 0.75pt solid rgba(166, 166, 166, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-bc857a90{width:0.894in;background-color:transparent;vertical-align: middle;border-bottom: 0.75pt solid rgba(166, 166, 166, 1.00);border-top: 0.75pt solid rgba(166, 166, 166, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0.75pt solid rgba(166, 166, 166, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-bc857a9a{width:1.306in;background-color:transparent;vertical-align: middle;border-bottom: 0.75pt solid rgba(166, 166, 166, 1.00);border-top: 0.75pt solid rgba(166, 166, 166, 1.00);border-left: 0.75pt solid rgba(166, 166, 166, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-bc857a9b{width:1.306in;background-color:transparent;vertical-align: middle;border-bottom: 0.75pt solid rgba(166, 166, 166, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0.75pt solid rgba(166, 166, 166, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-bc857aae{width:0.894in;background-color:transparent;vertical-align: middle;border-bottom: 0.75pt solid rgba(166, 166, 166, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0.75pt solid rgba(166, 166, 166, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-bc857aaf{width:1.306in;background-color:transparent;vertical-align: middle;border-bottom: 0.75pt solid rgba(166, 166, 166, 1.00);border-top: 0.75pt solid rgba(166, 166, 166, 1.00);border-left: 0.75pt solid rgba(166, 166, 166, 1.00);border-right: 0 solid rgba(0, 0, 0, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-bc857ab0{width:0.894in;background-color:transparent;vertical-align: middle;border-bottom: 0.75pt solid rgba(166, 166, 166, 1.00);border-top: 0.75pt solid rgba(166, 166, 166, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0.75pt solid rgba(166, 166, 166, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-bc857ab8{width:1.306in;background-color:transparent;vertical-align: middle;border-bottom: 0.75pt solid rgba(166, 166, 166, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0.75pt solid rgba(166, 166, 166, 1.00);border-right: 0.75pt solid rgba(166, 166, 166, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}.cl-bc857ab9{width:0.894in;background-color:transparent;vertical-align: middle;border-bottom: 0.75pt solid rgba(166, 166, 166, 1.00);border-top: 0 solid rgba(0, 0, 0, 1.00);border-left: 0 solid rgba(0, 0, 0, 1.00);border-right: 0.75pt solid rgba(166, 166, 166, 1.00);margin-bottom:0;margin-top:0;margin-left:0;margin-right:0;}


Vehicle characteristics
```
