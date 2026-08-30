# Save a gtstats table or plot

Save a `gtstats` result, rendered `flextable`, rendered `gt_tbl`, or
`ggplot2` plot. A named list of gtstats results, flextables, and plots
can be combined into one Word document. The object determines the export
route automatically. The file type is inferred from `filename`.

## Usage

``` r
save_output(
  x,
  filename,
  path = NULL,
  title = NULL,
  subtitle = NULL,
  bold_labels = TRUE,
  show_footnotes = TRUE,
  zoom = 2,
  expand = 5,
  vwidth = 992,
  vheight = 744,
  width = 8,
  height = 6,
  units = "in",
  dpi = 300,
  bg = "white",
  page_break = TRUE,
  quiet = FALSE,
  ...
)
```

## Arguments

- x:

  A `gtstats` result, rendered `flextable`, rendered `gt_tbl`, `ggplot2`
  plot, or a named list of tables and plots for a combined Word report.

- filename:

  Output filename including a supported extension.

- path:

  Optional output directory. When omitted, `filename` is used as
  supplied, so a simple filename saves in the current working directory.

- title, subtitle:

  Optional table title and subtitle.

- bold_labels:

  Logical; bold variable labels in tables.

- show_footnotes:

  Logical; include explanatory table footnotes.

- zoom, expand:

  Image-export controls for tables.

- vwidth, vheight:

  Browser viewport dimensions for table image export.

- width, height:

  Plot dimensions.

- units:

  Dimension units passed to
  [`ggplot2::ggsave()`](https://ggplot2.tidyverse.org/reference/ggsave.html)
  for plots.

- dpi:

  Output resolution for plots.

- bg:

  Plot background colour.

- page_break:

  Logical; when saving a list to Word, start each output after the first
  on a new page.

- quiet:

  Logical; suppress the saved-path message.

- ...:

  Additional arguments passed to the relevant underlying save method.

## Value

The normalized saved path, invisibly.

## Examples

``` r
if (FALSE) { # \dontrun{
table <- summary_table(mtcars) |> add_summary(vars = c(mpg, wt))
save_output(table, "summary.html")

plot <- plot_compare(mtcars, variable = mpg, group = am)
save_output(plot, "comparison.png")

save_output(
  list("Table 1" = table, "Comparison plot" = plot),
  "statistical-report.docx"
)
} # }
```
