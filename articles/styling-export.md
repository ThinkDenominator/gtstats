# Styling and Exporting Tables

``` r

library(gtstats)
```

## The output model

gtstats separates analysis from presentation:

1.  Build the statistical result with
    [`summary_table()`](https://gtstats.thinkdenominator.com/reference/summary_table.md)
    and optional layers.
2.  Finish its appearance with
    [`customise_table()`](https://gtstats.thinkdenominator.com/reference/customise_table.md).
3.  Export the same object with
    [`save_output()`](https://gtstats.thinkdenominator.com/reference/save_output.md).

Publication results print as `flextable` objects by default because they
travel cleanly to Word and PowerPoint.
[`to_gt()`](https://gtstats.thinkdenominator.com/reference/to_gt.md) is
the explicit HTML-focused route.
[`to_flextable()`](https://gtstats.thinkdenominator.com/reference/to_flextable.md)
remains available when an explicit conversion is useful.

``` r

res <- summary_table(
  mtcars,
  by = am,
  include = c(mpg, wt, cyl),
  overall = TRUE,
  statistic = c(continuous = "mean_sd", wt = "median_iqr")
) |>
  add_ci(vars = c(mpg, cyl)) |>
  add_p()

res                   # default flextable
```

[TABLE]

``` r

to_gt(res)            # explicit gt table
```

[TABLE]

``` r

to_flextable(res)     # explicit flextable
```

[TABLE]

The reserved name `continuous` supplies a default for all selected
continuous variables. A named variable then overrides it. Variables not
covered by a global or specific rule retain the package recommendation.

## Themes and journal styling

``` r

customise_table(res, theme = "journal")
```

[TABLE]

``` r

customise_table(res, theme = "minimal")
```

[TABLE]

``` r

customise_table(res, theme = "compact")
```

[TABLE]

| Theme       | Typical use                |
|-------------|----------------------------|
| `"default"` | General reports            |
| `"journal"` | Manuscripts and appendices |
| `"classic"` | Traditional ruled tables   |
| `"minimal"` | Slides and modern reports  |
| `"compact"` | Dense tables               |

`borders` independently controls the rule pattern, while `density`
changes cell padding:

``` r

customise_table(
  res,
  theme = "journal",
  borders = "horizontal",
  density = "compact",
  font = "Arial",
  font_size = 10
)
```

[TABLE]

## Titles, spanning headers and footnotes

``` r

customise_table(
  res,
  title = "Table 1. Vehicle characteristics",
  subtitle = "Grouped by transmission",
  spanning_header = list(
    "Transmission groups" = c("am = 0", "am = 1")
  ),
  footnotes = c(
    "CI = confidence interval.",
    "P-values are two-sided."
  ),
  show_footnotes = TRUE
)
```

[TABLE]

`show_footnotes = FALSE` removes the automatically generated analytical
footnotes. `footnotes` adds only the user-supplied notes. This changes
the presentation, not the underlying analysis.

## Relabelling and column control

Named vectors use the completed output value as the name and the desired
display text as the value.

``` r

customise_table(
  res,
  col_labels = c(
    "am = 0" = "Automatic",
    "am = 1" = "Manual",
    "Overall" = "All vehicles"
  ),
  row_labels = c(
    "mpg" = "Fuel economy",
    "wt" = "Weight",
    "cyl" = "Cylinders"
  ),
  level_labels = c(
    "4" = "Four",
    "6" = "Six",
    "8" = "Eight"
  ),
  hide_cols = "Level",
  column_widths = c(Variable = 2.2)
)
```

| Characteristic | All vehicles | Manual | Automatic | p-value |
|----|----|----|----|----|
| mpg | 20.1 (6.0); 17.9–22.3 | 24.4 (6.2); 20.7–28.1 | 17.1 (3.8); 15.3–19.0 | 0.001ᵃ |
| wt | 3.3 (2.6–3.6) | 2.3 (1.9–2.8) | 3.5 (3.4–3.8) | \<0.001ᵃ |
| cyl |  |  |  | 0.007ᵇ |
| 4 | 11 (34.4%); 20.4–51.7% | 8 (61.5%); 35.5–82.3% | 3 (15.8%); 5.5–37.6% |  |
| 6 | 7 (21.9%); 11.0–38.8% | 3 (23.1%); 8.2–50.3% | 4 (21.1%); 8.5–43.3% |  |
| 8 | 14 (43.8%); 28.2–60.7% | 2 (15.4%); 4.3–42.2% | 12 (63.2%); 41.0–80.9% |  |
| Continuous data: mpg: mean (SD); wt: median (IQR). Categorical data are n (%). Categorical proportions include 95% Wilson score CIs. Selected continuous means include 95% t-based CIs. |  |  |  |  |
| ᵃ Welch t-test; ᵇ Fisher's exact test (Monte Carlo p-value) |  |  |  |  |

Use `align`, `bold_cols`, and `italic_cols` for targeted emphasis. These
arguments accept completed column names.

## P-value display

P-value styling changes only how already calculated p-values are
printed.

``` r

customise_table(
  res,
  pvalue_style = "threshold",
  pvalue_digits = 3,
  pvalue_threshold = 0.001,
  pvalue_prefix = TRUE
)
```

[TABLE]

Available styles are `"threshold"`, `"fixed"`, and `"scientific"`.

## Choosing the renderer

[`customise_table()`](https://gtstats.thinkdenominator.com/reference/customise_table.md)
defaults to `engine = "flextable"`:

``` r

office_table <- customise_table(res, theme = "journal")
html_table <- customise_table(res, theme = "journal", engine = "gt")
```

Publication footnotes use smaller type than the body in both engines (8
pt in flextable and 10 px in gt), matching the gtregression house style.
They remain readable in Word while taking less vertical space in long
tables.

Use flextable for Word, PowerPoint, RTF, and Office-centred workflows.
Use gt for HTML pages or when downstream code specifically expects a
`gt_tbl`.

## Export

[`save_output()`](https://gtstats.thinkdenominator.com/reference/save_output.md)
accepts the original gtstats result, a customised flextable, a gt table,
or a ggplot.

``` r

finished <- customise_table(
  res,
  theme = "journal",
  title = "Table 1. Vehicle characteristics"
)

save_output(finished, "table-1.docx")
save_output(finished, "table-1.pptx")
save_output(finished, "table-1.rtf")

html_table <- customise_table(res, engine = "gt")
save_output(html_table, "table-1.html")
```

Table extensions include `.docx`, `.pptx`, `.rtf`, `.html`, `.png`,
`.pdf`, and `.tex`. A filename without a directory writes to the current
working directory; a relative or full path writes elsewhere.

Plots use the same helper:

``` r

p <- plot_compare(mtcars, variable = mpg, group = am, show_p = TRUE)
save_output(p, "mpg-by-transmission.png", width = 7, height = 5, dpi = 300)
```

Several tables and plots can be written to one Word report without
calling `officer` directly. Supply a named list; its names become
section headings:

``` r

overview <- describe_data(mtcars)
p <- plot_compare(mtcars, variable = mpg, group = am)

save_output(
  list(
    "Dataset overview" = overview,
    "Table 1" = res,
    "Fuel economy by transmission" = p
  ),
  "complete-report.docx",
  title = "Vehicle analysis",
  page_break = TRUE
)
```

## Practical rule

- Build statistics first.
- Customise once, near the end of the pipeline.
- Keep flextable for Office output.
- Use
  [`to_gt()`](https://gtstats.thinkdenominator.com/reference/to_gt.md)
  or `engine = "gt"` only when the destination calls for gt.
