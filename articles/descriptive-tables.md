# Building Descriptive Tables with gtstats

## Introduction

The descriptive table builder is the centrepiece of **gtstats**. It lets
you assemble a publication-ready “Table 1” — the standard baseline
characteristics table used in clinical and epidemiological papers —
through a simple, pipe-based workflow.

The builder has five components:

| Step | Function | What it does |
|----|----|----|
| 1 | [`summary_table()`](https://gtstats.thinkdenominator.com/reference/summary_table.md) | Initialises the table, sets grouping |
| 2 | [`add_summary()`](https://gtstats.thinkdenominator.com/reference/add_summary.md) | Adds mean (SD) and median (IQR) rows for continuous variables |
| 3 | [`add_proportion()`](https://gtstats.thinkdenominator.com/reference/add_proportion.md) | Adds n (%) rows for binary/categorical variables |
| 4 | [`add_rate()`](https://gtstats.thinkdenominator.com/reference/add_rate.md) | Adds event rate rows |
| 5 | [`add_total()`](https://gtstats.thinkdenominator.com/reference/add_total.md) | Appends a Total (N) row |
| 6 | [`add_p()`](https://gtstats.thinkdenominator.com/reference/add_p.md) | Appends a p-value column |
| 7 | [`add_row()`](https://gtstats.thinkdenominator.com/reference/add_row.md) | Appends a free-text row |
| 8 | [`tbl_stats()`](https://gtstats.thinkdenominator.com/reference/tbl_stats.md) | Renders the assembled table as a `gt` object |

``` r

library(gtstats)
```

------------------------------------------------------------------------

## A minimal table

Start with
[`summary_table()`](https://gtstats.thinkdenominator.com/reference/summary_table.md),
then pipe in whichever row-builders you need.

``` r

summary_table(mtcars, by = am) |>
  add_summary(vars = c(mpg, wt, cyl)) |>
  tbl_stats()
```

`by = am` groups the table by the `am` variable (transmission type).
Each level becomes a column.

------------------------------------------------------------------------

## Adding an overall column

Set `overall = TRUE` to include an additional column showing statistics
for the full sample.

``` r

summary_table(mtcars, by = am, overall = TRUE) |>
  add_summary(vars = c(mpg, wt, cyl)) |>
  tbl_stats()
```

------------------------------------------------------------------------

## Summary-table options at a glance

The default call is deliberately simple. These global options cover the
most common reporting choices without requiring separate continuous and
categorical workflows.

| Reporting choice | Option | Example |
|----|----|----|
| Overall column | `overall` | `TRUE`, `"first"`, or `"last"` |
| Continuous summary | `statistic` | `"recommended"`, `"mean_sd"`, `"mean_ci"`, `"median_iqr"`, or `"both"` |
| Categorical display | `categorical` | `"n_percent"`, `"n_over_N_percent"`, `"n"`, or `"percent"` |
| Percentage denominator | `percent` | `"column"`, `"row"`, `"overall"`, or `"none"` |
| Precision | `digits` | `c(continuous = 1, percent = 0, ci = 1)` |
| Missing-value rows | `missing` | `"ifany"`, `"always"`, or `"no"` |
| Categorical confidence intervals | `ci`, `conf.level` | `ci = TRUE, conf.level = 0.95` |

For different continuous summaries by variable, provide a named vector:

``` r

summary_table(
  mtcars,
  by = am,
  include = c(mpg, wt, cyl),
  statistic = c(mpg = "mean_ci", wt = "median_iqr"),
  overall = "last"
)
```

------------------------------------------------------------------------

## Choosing percentage denominators and missing rows

Categorical percentages should always identify their denominator:

``` r

summary_table(mtcars, by = am, overall = TRUE) |>
  add_summary(vars = c(cyl, vs), percent = "column")

summary_table(mtcars, by = am, overall = TRUE) |>
  add_summary(vars = c(cyl, vs), percent = "row")

summary_table(mtcars, by = am, overall = TRUE) |>
  add_summary(vars = c(cyl, vs), percent = "overall")

summary_table(mtcars, by = am, overall = TRUE) |>
  add_summary(vars = c(cyl, vs), percent = "none")
```

`"column"` describes levels within each group, `"row"` distributes each
level across groups, `"overall"` uses the full non-missing variable
denominator, and `"none"` displays counts only. The selected rule is
retained in the object and shown in the table footnote.

Missing-value rows are equally explicit:

``` r

summary_table(mtcars, by = am, overall = TRUE) |>
  add_summary(
    vars = c(mpg, wt, vs),
    missing = "ifany"
  )
```

Use `"always"` to show zero-missing rows or `"no"` to suppress them.

### Showing the denominator in every categorical cell

Use `categorical = "n_over_N_percent"` when the table itself should show
the non-missing denominator for every category. This is particularly
helpful for small groups, supplementary tables, and teaching.

``` r

summary_table(
  mtcars,
  by = am,
  include = cyl,
  categorical = "n_over_N_percent",
  percent = "column",
  digits = c(percent = 0)
)
```

### Mean with a confidence interval

Use `statistic = "mean_ci"` when the goal is descriptive precision
rather than a p-value. The interval is a t confidence interval for the
observed mean and uses `conf.level` (95% by default).

``` r

summary_table(
  mtcars,
  include = c(mpg, wt),
  statistic = "mean_ci",
  conf.level = 0.95
)
```

------------------------------------------------------------------------

## Adding proportion rows

[`add_proportion()`](https://gtstats.thinkdenominator.com/reference/add_proportion.md)
adds a highlighted percentage row for a binary or categorical variable.
Optionally add exact binomial confidence intervals with `ci = TRUE`.

``` r

summary_table(mtcars, by = am, overall = TRUE) |>
  add_summary(vars = c(mpg, wt, cyl)) |>
  add_proportion(var = vs) |>
  tbl_stats()
```

To display confidence intervals and pin the row to a specific level:

``` r

summary_table(mtcars, by = am, overall = TRUE) |>
  add_summary(vars = c(mpg, wt, cyl)) |>
  add_proportion(var = vs, level = "1", ci = TRUE) |>
  tbl_stats()
```

------------------------------------------------------------------------

## Adding a total row

[`add_total()`](https://gtstats.thinkdenominator.com/reference/add_total.md)
appends a row at the bottom showing the total N per group.

``` r

summary_table(mtcars, by = am, overall = TRUE) |>
  add_summary(vars = c(mpg, wt, cyl)) |>
  add_proportion(var = vs) |>
  add_total() |>
  tbl_stats()
```

------------------------------------------------------------------------

The rendered table footnote is data-driven: it mentions continuous
summaries only when continuous variables are present, and categorical
displays only when categorical variables are present.

## Adding p-values

[`add_p()`](https://gtstats.thinkdenominator.com/reference/add_p.md)
appends a p-value column. By default, the test is selected
automatically:

- Continuous variables: Welch t-test (2 groups) or Welch ANOVA (3+
  groups) by default; use `var_equal = TRUE` only when an equal-variance
  assumption is justified, to select Student’s t-test or classical ANOVA
- Skewed distributions: Wilcoxon rank-sum or Kruskal-Wallis
- Categorical variables: chi-squared test when all expected cell counts
  are at least 5; Fisher’s exact test otherwise

[`add_p()`](https://gtstats.thinkdenominator.com/reference/add_p.md)
uses the same automatic-selection policy as
[`compare_groups()`](https://gtstats.thinkdenominator.com/reference/compare_groups.md).
The publication table stays concise: its p-value markers identify the
test, while the variable-specific checks remain available in the audit
components. `var_equal` is a user-specified analytical assumption; it is
not inferred by a variance hypothesis test.

``` r

summary_table(mtcars, by = am) |>
  add_summary(vars = c(mpg, wt, cyl)) |>
  add_proportion(var = vs) |>
  add_p() |>
  tbl_stats()
```

Raw and multiplicity-adjusted values are retained separately:

``` r

adjusted <- summary_table(mtcars, by = am) |>
  add_summary(vars = c(mpg, wt, cyl, vs)) |>
  add_p(p_adjust = "BH")

adjusted$p_values
adjusted$assumptions
adjusted$diagnostics
adjusted$denominators
```

For a readable audit table, use `diagnostics_stats(adjusted)`. For
continuous variables it includes observed group SDs and variances as
descriptive context; these values do not act as a variance-test
gatekeeper because Welch methods do not require equal variances.

`denominators_stats(adjusted)` provides a compact audit table showing
the observations contributing to every variable and group.

### Specifying tests manually

Pass a named character vector to `method` to override the automatic
selection for specific variables:

``` r

summary_table(mtcars, by = am) |>
  add_summary(vars = c(mpg, wt, cyl)) |>
  add_p(method = c(mpg = "welch_t", wt = "wilcox", cyl = "chisq")) |>
  tbl_stats()
```

Supported methods: `"auto"`, `"welch_t"`, `"t_test"`, `"wilcox"`,
`"anova"`, `"kruskal"`, `"chisq"`, `"fisher"`, `"mcnemar"`.

### Paired tests

For before/after or matched data, use `paired = TRUE`:

``` r

dat <- data.frame(
  period = c("before", "before", "before", "before",
             "after",  "after",  "after",  "after"),
  score  = c(10, 12, 9, 11, 13, 16, 11, 15)
)

summary_table(dat, by = period) |>
  add_summary(vars = score) |>
  add_p(paired = TRUE, method = "wilcox") |>
  tbl_stats()
```

------------------------------------------------------------------------

## Adding rate rows

[`add_rate()`](https://gtstats.thinkdenominator.com/reference/add_rate.md)
appends an event rate row calculated per a chosen multiplier, with exact
Poisson confidence intervals. This is useful when your dataset contains
event counts and person-time denominators.

``` r

summary_table(mtcars, by = am, overall = TRUE, mode = "rate") |>
  add_rate(
    event      = carb,
    time       = cyl,
    label      = "Carburettor rate",
    multiplier = 1000
  ) |>
  tbl_stats()
```

------------------------------------------------------------------------

## Adding custom rows

[`add_row()`](https://gtstats.thinkdenominator.com/reference/add_row.md)
inserts a free-text row — useful for study period notes, data source
annotations, or any label that does not come from a variable.

``` r

summary_table(mtcars, by = am, overall = TRUE) |>
  add_summary(vars = c(mpg, wt, cyl)) |>
  add_row(
    label   = "Study period",
    overall = "2020–2024",
    values  = c("am = 1" = "2020–2024", "am = 0" = "2020–2024")
  ) |>
  tbl_stats()
```

------------------------------------------------------------------------

## The full workflow

Putting it all together — a complete, publication-ready descriptive
table:

``` r

summary_table(mtcars, by = am, overall = TRUE) |>
  add_summary(vars = c(mpg, wt, cyl)) |>
  add_proportion(var = vs, level = "1", ci = TRUE) |>
  add_total() |>
  add_p() |>
  tbl_stats()
```

------------------------------------------------------------------------

## Styling the output

[`customise_table()`](https://gtstats.thinkdenominator.com/reference/customise_table.md)
applies a visual theme and relabels columns, rows, and factor levels. It
operates on the `gt` object returned by
[`tbl_stats()`](https://gtstats.thinkdenominator.com/reference/tbl_stats.md).

``` r

summary_table(mtcars, by = am, overall = TRUE) |>
  add_summary(vars = c(mpg, wt, cyl)) |>
  add_proportion(var = vs) |>
  add_total() |>
  add_p() |>
  tbl_stats() |>
  customise_table(
    theme      = "journal",
    title      = "Table 1. Baseline characteristics by transmission type",
    col_labels = c(
      "Level"  = "",
      "am = 1" = "Manual",
      "am = 0" = "Automatic"
    ),
    row_labels = c(
      "mpg"    = "Miles per gallon",
      "wt"     = "Weight (1000 lbs)",
      "cyl"    = "Cylinders",
      "vs (1)" = "V-shaped engine"
    ),
    accent_color = "#123B7A"
  )
```

Available themes: `"default"`, `"journal"`, `"classic"`, `"minimal"`,
`"compact"`.

You can also relabel factor levels within the table using
`level_labels`:

``` r

summary_table(mtcars, by = am, overall = TRUE) |>
  add_summary(vars = cyl) |>
  tbl_stats() |>
  customise_table(
    level_labels = c(
      "4" = "4-cylinder",
      "6" = "6-cylinder",
      "8" = "8-cylinder"
    )
  )
```

------------------------------------------------------------------------

## Exporting to Word

Call
[`to_flextable()`](https://gtstats.thinkdenominator.com/reference/to_flextable.md)
on the `gt_desc_table` object (before rendering with
[`tbl_stats()`](https://gtstats.thinkdenominator.com/reference/tbl_stats.md))
to produce a `flextable` suitable for Word output.

``` r

res <- summary_table(mtcars, by = am, overall = TRUE) |>
  add_summary(vars = c(mpg, wt, cyl)) |>
  add_proportion(var = vs) |>
  add_total() |>
  add_p()

ft <- to_flextable(res)
```

In an R Markdown or Quarto document targeting Word output, simply print
`ft` in a chunk and it will appear as a formatted table in the document.

------------------------------------------------------------------------

## Summary

The gtstats table builder lets you assemble a complete “Table 1” with
very little code:

    summary_table(data, by = group, overall = TRUE)
      |> add_summary(vars = c(...))
      |> add_proportion(var = ...)
      |> add_total()
      |> add_p()
      |> tbl_stats()
      |> customise_table(theme = "journal", ...)

Each `add_*()` function is independent — add only the rows your table
needs, in any order that makes sense for your report.
