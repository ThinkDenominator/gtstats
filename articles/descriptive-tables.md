# Summary Tables and Customisation

## Introduction

The descriptive table builder is the centrepiece of **gtstats**. It lets
you assemble a publication-ready “Table 1” — the standard baseline
characteristics table used in clinical and epidemiological papers —
through a simple, pipe-based workflow.

Think of the table as layers. Start with the descriptive foundation,
then add only the layers required by the report:

| Step | Function | What it does |
|----|----|----|
| 1 | [`summary_table()`](https://gtstats.thinkdenominator.com/reference/summary_table.md) | Builds summaries, grouping and the Overall column |
| 2 | [`add_ci()`](https://gtstats.thinkdenominator.com/reference/add_ci.md) | Adds CIs globally or to selected variables |
| 3 | [`add_p()`](https://gtstats.thinkdenominator.com/reference/add_p.md) | Adds a p-value column when comparisons are appropriate |
| 4 | [`add_proportion()`](https://gtstats.thinkdenominator.com/reference/add_proportion.md) | Highlights one selected event as a new row |
| 5 | [`add_rate()`](https://gtstats.thinkdenominator.com/reference/add_rate.md) | Adds an event-rate row |
| 6 | [`add_total()`](https://gtstats.thinkdenominator.com/reference/add_total.md) | Adds a participant-count row |
| 7 | [`add_row()`](https://gtstats.thinkdenominator.com/reference/add_row.md) | Adds a free-text row |
| 8 | [`customise_table()`](https://gtstats.thinkdenominator.com/reference/customise_table.md) | Finishes appearance and labels |

``` r

library(gtstats)
```

------------------------------------------------------------------------

## A minimal table

For an ordinary Table 1, select all variable types together. There is no
need to add continuous and categorical variables separately.

``` r

summary_table(mtcars, by = am, include = c(mpg, wt, cyl))
```

[TABLE]

`by = am` groups the table by the `am` variable (transmission type).
Each level becomes a column.

------------------------------------------------------------------------

## Adding an overall column

Set `overall = TRUE` to include an additional column showing statistics
for the full sample.

``` r

summary_table(mtcars, by = am, include = c(mpg, wt, cyl), overall = TRUE)
```

[TABLE]

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
| Categorical columns | `categorical_layout` | `"combined"` (default) or `"separate"` for categorical-only tables without CIs |
| Overall categorical cells | `overall_categorical` | `"auto"` (default), `"n_percent"`, `"n_over_N_percent"`, `"n"`, or `"percent"` |
| Binary rows | `show_dichotomous` | `"all_levels"` (default) or `"single_row"` |
| Binary event | `value` | Named choices such as `c(smoke = "Yes")`; otherwise the second level is used |
| Percentage denominator | `percent` | `"column"`, `"row"`, `"overall"`, or `"none"` |
| Precision | `digits` | `c(continuous = 1, percent = 0, ci = 1)` |
| Missing-value handling | `missing` | `"ifany"`, `"always"`, `"no"`, or `"as_category"` |
| CI layout | `layout` | `"compact"` (default) or `"separate"` |

For a row-percentage table, `overall_categorical = "auto"` deliberately
shows Overall categorical counts. A percentage of the entire sample is
usually not the same estimand as the grouped row percentages. Override
this with `overall_categorical = "n_percent"` only when that is the
intended display.

### How global choices and variable exceptions work

The defaults are deliberately useful, but they never lock the user in. A
single value applies to every eligible variable. A named vector changes
only the named variables; all unlisted variables continue to use the
recommended summary.

``` r

# Mean (SD) for every continuous variable
summary_table(
  birthwt,
  include = c(age, lwt, bwt, smoke),
  statistic = "mean_sd"
)
```

[TABLE]

``` r


# Recommended summaries for all variables except maternal weight
summary_table(
  birthwt,
  include = c(age, lwt, bwt, smoke),
  statistic = c(lwt = "median_iqr")
)
```

[TABLE]

The same principle applies to `label`, `value`, and the named precision
settings. This makes the short call beginner-friendly while preserving
precise control for a manuscript.

### Which layout option controls which columns?

Two similarly named options solve different reporting problems:

| Need | Use | Result |
|----|----|----|
| Keep ordinary categorical values as `n (%)` | `categorical_layout = "combined"` | One summary column per cohort |
| Put `n` and `%` in different columns | `categorical_layout = "separate"` | Separate count and percentage child columns; intended for categorical-only tables without CIs |
| Keep an estimate and its CI together | `layout = "compact"` plus [`add_ci()`](https://gtstats.thinkdenominator.com/reference/add_ci.md) | One concise cell per cohort |
| Put estimates and CIs in different columns | `layout = "separate"` plus [`add_ci()`](https://gtstats.thinkdenominator.com/reference/add_ci.md) | A cohort spanner with an estimate column and an explicit confidence-interval column |

`layout = "separate"` does not create empty confidence-interval columns.
The CI columns appear only after
[`add_ci()`](https://gtstats.thinkdenominator.com/reference/add_ci.md),
`add_proportion(ci = TRUE)`, or an equivalent CI layer is present.

### Compact binary variables

`show_dichotomous = "single_row"` is a display choice for common Yes/No
and Present/Absent variables. It does not turn a two-level association
test into a one-level test. By default, gtstats displays the second
declared factor level. Use `value` whenever the event should be
explicit.

``` r

summary_table(
  birthwt,
  by = low,
  include = c(smoke, ht, race),
  show_dichotomous = "single_row",
  value = c(smoke = "Yes", ht = "Yes")
) |>
  add_p()
```

[TABLE]

Here `smoke` and `ht` occupy one row each, `race` retains all levels,
and [`add_p()`](https://gtstats.thinkdenominator.com/reference/add_p.md)
still tests each complete source variable.

### Precision and labels

Use one number when all displayed values need the same precision, or
name the parts that differ:

``` r

summary_table(
  birthwt,
  by = low,
  include = c(age, smoke),
  digits = c(continuous = 1, percent = 0, ci = 1),
  label = c(
    age = "Maternal age, years",
    smoke = "Smoking during pregnancy"
  )
)
```

[TABLE]

Variable labels affect presentation only. They do not rename the columns
in the source data or alter automatic test selection.

Confidence intervals are deliberately a visible second layer:

``` r

summary_table(
  mtcars,
  by = am,
  include = c(mpg, cyl, vs),
  layout = "separate"
) |>
  add_ci()
```

[TABLE]

``` r


summary_table(
  mtcars,
  by = am,
  include = c(mpg, cyl, vs),
  layout = "separate"
) |>
  add_ci(vars = c(mpg, vs), conf.level = 0.90)
```

[TABLE]

For a categorical-only table without confidence intervals, counts and
percentages can instead occupy distinct child columns:

``` r

summary_table(
  mtcars,
  by = am,
  include = c(cyl, vs),
  categorical_layout = "separate"
)
```

[TABLE]

For compact clinical Table 1 layouts, binary variables can occupy one
row while ordinary categorical variables continue to show every level:

``` r

summary_table(
  birthwt,
  by = low,
  include = c(smoke, ht, race),
  show_dichotomous = "single_row",
  value = c(smoke = "Yes", ht = "Yes")
)
```

[TABLE]

This changes presentation only.
[`add_p()`](https://gtstats.thinkdenominator.com/reference/add_p.md)
still tests the full binary variable.

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

[TABLE]

------------------------------------------------------------------------

## Choosing percentage denominators and missing rows

Categorical percentages should always identify their denominator:

``` r

summary_table(mtcars, by = am, overall = TRUE, include = c(cyl, vs), percent = "column")
```

[TABLE]

``` r


summary_table(mtcars, by = am, overall = TRUE, include = c(cyl, vs), percent = "row")
```

[TABLE]

``` r


summary_table(mtcars, by = am, overall = TRUE, include = c(cyl, vs), percent = "overall")
```

[TABLE]

``` r


summary_table(mtcars, by = am, overall = TRUE, include = c(cyl, vs), categorical = "n")
```

[TABLE]

`"column"` describes levels within each group, `"row"` distributes each
level across groups, `"overall"` uses the full non-missing variable
denominator, and `"none"` displays counts only. The selected rule is
retained in the object and shown in the table footnote.

Missing-value rows are equally explicit:

``` r

summary_table(
  mtcars, by = am, overall = TRUE,
  include = c(mpg, wt, vs), missing = "ifany"
)
```

[TABLE]

Use `"always"` to show zero-missing rows or `"no"` to suppress them.
With these settings, observed-category percentages use non-missing
values. Use `missing = "as_category"` to display Missing as a category
and include it when calculating categorical percentages.

``` r

missing_example <- data.frame(
  catheter = factor(
    c(rep("Yes", 32), rep(NA_character_, 68)),
    levels = c("No", "Yes")
  )
)

summary_table(
  missing_example,
  include = catheter,
  missing = "as_category"
)
```

[TABLE]

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

[TABLE]

### Mean with a confidence interval

Use
[`add_ci()`](https://gtstats.thinkdenominator.com/reference/add_ci.md)
when the goal is descriptive precision rather than a p-value. For a
mean-based continuous summary it adds a t confidence interval while
retaining the displayed mean (SD).

``` r

summary_table(
  mtcars,
  include = c(mpg, wt),
  statistic = "mean_sd",
  layout = "separate"
) |>
  add_ci()
```

[TABLE]

------------------------------------------------------------------------

## Adding proportion rows

[`add_proportion()`](https://gtstats.thinkdenominator.com/reference/add_proportion.md)
is a specialist layer that adds one highlighted event row for a binary
or categorical variable. Optionally add Wilson confidence intervals (the
default) or request exact binomial confidence intervals with
`ci = TRUE`.

When confidence intervals make a table too dense, use
`layout = "separate"`. Each displayed cohort then becomes a spanning
header with a dynamically labelled summary column and an explicit **95%
CI** column (or the selected confidence level). The confidence level and
method are stated once in the footnote. Separate child columns appear
only after a CI layer is added, so `layout = "separate"` alone does not
create empty columns. The compact layout remains the default for
ordinary Table 1 output.

``` r

summary_table(
  birthwt,
  by = smoke,
  include = c(age, low),
  overall = "first",
  layout = "separate"
) |>
  add_ci()
```

[TABLE]

``` r

summary_table(mtcars, by = am, include = c(mpg, wt, cyl), overall = TRUE) |>
  add_proportion(var = vs) |>
  to_gt()
```

[TABLE]

To display confidence intervals and pin the row to a specific level:

``` r

summary_table(mtcars, by = am, include = c(mpg, wt, cyl), overall = TRUE) |>
  add_proportion(var = vs, level = "1", ci = TRUE) |>
  to_gt()
```

[TABLE]

------------------------------------------------------------------------

## Adding a total row

[`add_total()`](https://gtstats.thinkdenominator.com/reference/add_total.md)
appends a row at the bottom showing the total N per group.

``` r

summary_table(mtcars, by = am, include = c(mpg, wt, cyl), overall = TRUE) |>
  add_proportion(var = vs) |>
  add_total() |>
  to_gt()
```

[TABLE]

------------------------------------------------------------------------

The rendered table footnote is data-driven: it mentions continuous
summaries only when continuous variables are present, and categorical
displays only when categorical variables are present.

## Adding p-values

[`add_p()`](https://gtstats.thinkdenominator.com/reference/add_p.md)
appends a p-value column. Its automatic route is identical to
`compare_groups(test = "auto")`:

- Continuous variables: Welch t-test (2 groups) or Welch ANOVA (3+
  groups) by default; use `var_equal = TRUE` only when an equal-variance
  assumption is justified, to select Student’s t-test or classical ANOVA
- Marked skewness (absolute sample skewness at least 1 in any group):
  Wilcoxon rank-sum or Kruskal-Wallis. Shapiro-Wilk and lesser asymmetry
  are supporting information and do not switch the test by themselves.
- Binary, nominal, and independent ordinal variables: chi-square when no
  expected count is below 1 and no more than 20% are below 5; Fisher’s
  exact test otherwise. Larger sparse tables use a Monte Carlo Fisher
  p-value.

[`add_p()`](https://gtstats.thinkdenominator.com/reference/add_p.md)
uses the same automatic-selection policy as
[`compare_groups()`](https://gtstats.thinkdenominator.com/reference/compare_groups.md).
The publication table stays concise: its p-value markers identify the
test, while the variable-specific checks remain available in the audit
components. `var_equal` is a user-specified analytical assumption; it is
not inferred by a variance hypothesis test.

Use `include` when a displayed variable should remain descriptive but
should not be tested. This is important when the grouping variable was
derived from a displayed variable or when a comparison was not
prespecified.

``` r

summary_table(birthwt, by = low, include = c(age, bwt, smoke)) |>
  add_p(include = -bwt)
```

[TABLE]

For independent ordered factors, Auto compares the complete distribution
of levels using chi-square/Fisher. Specify `test = "wilcox"` or
`"kruskal"` only when the planned estimand is an ordered rank shift.
Paired and repeated outcomes use their design-specific routes: paired
t/Wilcoxon signed-rank, repeated-measures ANOVA/Friedman, McNemar, or
Cochran’s Q.

``` r

summary_table(mtcars, by = am, include = c(mpg, wt, cyl)) |>
  add_proportion(var = vs) |>
  add_p() |>
  to_gt()
```

[TABLE]

Raw and multiplicity-adjusted values are retained separately:

``` r

adjusted <- summary_table(mtcars, by = am, include = c(mpg, wt, cyl, vs)) |>
  add_p(p_adjust = "BH")

adjusted$p_values
#> # A tibble: 4 × 8
#>   variable label row_index test        symbol p_value p_adjusted p_adjust_method
#>   <chr>    <chr>     <int> <chr>       <chr>    <dbl>      <dbl> <chr>          
#> 1 mpg      mpg           1 Welch t-te… ᵃ      1.37e-3  0.00275   BH             
#> 2 wt       wt            2 Welch t-te… ᵃ      6.27e-6  0.0000251 BH             
#> 3 cyl      cyl           3 Fisher's e… ᵇ      7.10e-3  0.00947   BH             
#> 4 vs       vs            6 Chi-square… ᶜ      5.56e-1  0.556     BH
adjusted$assumptions
#> # A tibble: 10 × 6
#>    assumption                   status result detail variable analysis_component
#>    <chr>                        <chr>  <chr>  <chr>  <chr>    <chr>             
#>  1 Independent observations     user_… not_c… Confi… mpg      add_p             
#>  2 Distribution and influentia… partl… no_sk… Inspe… mpg      add_p             
#>  3 Independent observations     user_… not_c… Confi… wt       add_p             
#>  4 Distribution and influentia… partl… no_sk… Inspe… wt       add_p             
#>  5 Independent observations     user_… not_c… Confi… cyl      add_p             
#>  6 Mutually exclusive categori… user_… not_c… Confi… cyl      add_p             
#>  7 Adequate expected cell coun… check… sparse Autom… cyl      add_p             
#>  8 Independent observations     user_… not_c… Confi… vs       add_p             
#>  9 Mutually exclusive categori… user_… not_c… Confi… vs       add_p             
#> 10 Adequate expected cell coun… check… guida… Autom… vs       add_p
adjusted$diagnostics
#> # A tibble: 18 × 7
#>    check               result value threshold detail variable analysis_component
#>    <chr>               <chr>  <chr> <chr>     <chr>  <chr>    <chr>             
#>  1 Comparison design   indep… Inde… Defined … Indep… mpg      add_p             
#>  2 Variance assumption welch… var_… User-spe… Welch… mpg      add_p             
#>  3 Automatic test sel… Welch… Appr… No marke… Two-g… mpg      add_p             
#>  4 Distribution guida… param… Appr… Marked a… Asses… mpg      add_p             
#>  5 Observed group spr… descr… 0 (n… Descript… Obser… mpg      add_p             
#>  6 Comparison design   indep… Inde… Defined … Indep… wt       add_p             
#>  7 Variance assumption welch… var_… User-spe… Welch… wt       add_p             
#>  8 Automatic test sel… Welch… Poss… No marke… Two-g… wt       add_p             
#>  9 Distribution guida… param… Poss… Marked a… Asses… wt       add_p             
#> 10 Observed group spr… descr… 0 (n… Descript… Obser… wt       add_p             
#> 11 Comparison design   indep… Inde… Defined … Indep… cyl      add_p             
#> 12 Variance assumption not_a… var_… Applies … `var_… cyl      add_p             
#> 13 Automatic test sel… Fishe… 2.84  No expec… Indep… cyl      add_p             
#> 14 Expected cell coun… sparse 2.84  No expec… Fishe… cyl      add_p             
#> 15 Comparison design   indep… Inde… Defined … Indep… vs       add_p             
#> 16 Variance assumption not_a… var_… Applies … `var_… vs       add_p             
#> 17 Automatic test sel… Chi-s… 5.69  No expec… Indep… vs       add_p             
#> 18 Expected cell coun… guida… 5.69  No expec… Fishe… vs       add_p
adjusted$denominators
#> # A tibble: 14 × 9
#>    variable level group  n_total n_nonmissing n_missing numerator denominator
#>    <chr>    <chr> <chr>    <int>        <int>     <int>     <dbl>       <dbl>
#>  1 mpg      NA    am = 1      13           13         0        NA          13
#>  2 mpg      NA    am = 0      19           19         0        NA          19
#>  3 wt       NA    am = 1      13           13         0        NA          13
#>  4 wt       NA    am = 0      19           19         0        NA          19
#>  5 cyl      4     am = 1      13           13         0         8          13
#>  6 cyl      4     am = 0      19           19         0         3          19
#>  7 cyl      6     am = 1      13           13         0         3          13
#>  8 cyl      6     am = 0      19           19         0         4          19
#>  9 cyl      8     am = 1      13           13         0         2          13
#> 10 cyl      8     am = 0      19           19         0        12          19
#> 11 vs       0     am = 1      13           13         0         6          13
#> 12 vs       0     am = 0      19           19         0        12          19
#> 13 vs       1     am = 1      13           13         0         7          13
#> 14 vs       1     am = 0      19           19         0         7          19
#> # ℹ 1 more variable: rule <chr>
```

For a readable audit table, use `diagnostics_stats(adjusted)`. For
continuous variables it includes observed group SDs and variances as
descriptive context; these values do not act as a variance-test
gatekeeper because Welch methods do not require equal variances.

`denominators_stats(adjusted)` provides a compact audit table showing
the observations contributing to every variable and group.

### Specifying tests manually

Pass a named character vector to `test` to override the automatic
selection for specific variables:

``` r

summary_table(mtcars, by = am, include = c(mpg, wt, cyl)) |>
  add_p(test = c(mpg = "welch_t", wt = "wilcox", cyl = "chisq")) |>
  to_gt()
```

[TABLE]

Supported methods: `"auto"`, `"welch_t"`, `"t_test"`, `"wilcox"`,
`"anova"`, `"welch_anova"`, `"rm_anova"`, `"kruskal"`, `"friedman"`,
`"chisq"`, `"fisher"`, `"mcnemar"`, and `"cochran_q"`.

### Paired tests

For before/after or matched data, use `paired = TRUE`:

``` r

dat <- data.frame(
  id     = rep(1:4, 2),
  period = c("before", "before", "before", "before",
             "after",  "after",  "after",  "after"),
  score  = c(10, 12, 9, 11, 13, 16, 11, 15)
)

summary_table(dat, by = period, include = score) |>
  add_p(paired = TRUE, id = id, test = "wilcox") |>
  to_gt()
```

[TABLE]

------------------------------------------------------------------------

## Adding rate rows

[`add_rate()`](https://gtstats.thinkdenominator.com/reference/add_rate.md)
appends an event rate row calculated per a chosen multiplier, with exact
Poisson confidence intervals. This is useful when your dataset contains
event counts and person-time denominators.

``` r

summary_table(mtcars, by = am, overall = TRUE) |>
  add_rate(
    event      = carb,
    time       = cyl,
    label      = "Carburettor rate",
    multiplier = 1000
  ) |>
  to_gt()
```

[TABLE]

------------------------------------------------------------------------

## Adding custom rows

[`add_row()`](https://gtstats.thinkdenominator.com/reference/add_row.md)
inserts a free-text row — useful for study period notes, data source
annotations, or any label that does not come from a variable.

``` r

summary_table(mtcars, by = am, include = c(mpg, wt, cyl), overall = TRUE) |>
  add_row(
    label   = "Study period",
    overall = "2020–2024",
    values  = c("am = 1" = "2020–2024", "am = 0" = "2020–2024")
  ) |>
  to_gt()
```

[TABLE]

------------------------------------------------------------------------

## The full workflow

Putting it all together — a complete, publication-ready descriptive
table:

``` r

summary_table(mtcars, by = am, include = c(mpg, wt, cyl), overall = TRUE) |>
  add_proportion(var = vs, level = "1", ci = TRUE) |>
  add_total() |>
  add_p() |>
  to_gt()
```

[TABLE]

------------------------------------------------------------------------

## Styling the output

[`customise_table()`](https://gtstats.thinkdenominator.com/reference/customise_table.md)
applies a visual theme and relabels columns, rows, and factor levels.
Pass the result directly; it returns a flextable by default.

``` r

summary_table(mtcars, by = am, include = c(mpg, wt, cyl), overall = TRUE) |>
  add_proportion(var = vs) |>
  add_total() |>
  add_p() |>
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

[TABLE]

Available themes: `"default"`, `"journal"`, `"classic"`, `"minimal"`,
`"compact"`.

### Complete customisation guide

Customisation is deliberately separated from analysis. It changes how
the completed table looks, never its estimates, denominators, confidence
intervals, or tests.

| Task | Argument | Default and useful choices |
|----|----|----|
| Choose the renderer | `engine` | `"flextable"` (default, Word/PowerPoint friendly) or `"gt"` (HTML focused) |
| Apply a visual preset | `theme` | `"default"`, `"journal"`, `"classic"`, `"minimal"`, `"compact"` |
| Add headings | `title`, `subtitle` | One character value or `NULL` |
| Add explanatory text | `source_note`, `footnotes` | One source note and/or a character vector of extra footnotes |
| Rename columns | `col_labels` | Named vector: current column name = new label |
| Rename variable rows | `row_labels` | Named vector: current row label = new label |
| Rename category levels | `level_labels` | Named vector: current level = new level |
| Group columns visually | `spanning_header` | One heading for result columns, or a named list mapping headings to columns |
| Align columns | `align` | Named list containing `left`, `center`, and/or `right` column names |
| Remove columns visually | `hide_cols` | Character vector of completed column names |
| Emphasise columns | `bold_cols`, `italic_cols` | Character vectors of completed column names |
| Control typography | `font_size`, `font` | Numeric size and an installed font name |
| Control table width | `width` | Percentage from 0 to 100 for `gt` output |
| Control individual widths | `column_widths` | Named numeric widths in inches for flextable output |
| Add alternating rows | `row_striping`, `stripe_color` | `TRUE`/`FALSE` and a colour such as `"#F4F4F2"` |
| Set the accent | `accent_color` | Hex colour used for rules and emphasis |
| Choose borders | `borders` | `"horizontal"`, `"all"`, or `"minimal"` |
| Change row spacing | `density` | `"standard"`, `"compact"`, or `"spacious"` |
| Retain/remove package notes | `show_footnotes` | `TRUE` or `FALSE` |
| Emphasise variable labels | `bold_labels` | `TRUE` or `FALSE` |
| Format p-values | `pvalue_style` | `"threshold"`, `"fixed"`, or `"scientific"` |
| Tune p-values | `pvalue_digits`, `pvalue_threshold`, `pvalue_prefix` | Digits, threshold, and optional `p =` prefix |

#### A journal-style recipe

``` r

finished_table <- summary_table(
  birthwt,
  by = low,
  include = c(age, lwt, race, smoke),
  overall = "last",
  show_dichotomous = "single_row",
  value = c(smoke = "Yes")
) |>
  add_p() |>
  customise_table(
    theme = "journal",
    title = "Table 1. Maternal characteristics",
    spanning_header = "Birth-weight outcome",
    density = "compact",
    borders = "horizontal",
    font_size = 9,
    pvalue_style = "threshold",
    pvalue_digits = 3,
    accent_color = "#4A4A4A",
    show_footnotes = TRUE
  )
```

#### Relabelling without changing the analysis

Mappings always use `current = new`. Inspect the completed table first
when you are unsure of a displayed column name.

``` r

summary_table(birthwt, by = low, include = c(race, smoke)) |>
  customise_table(
    col_labels = c(
      "low = Normal birth weight" = "Normal birth weight",
      "low = Low birth weight" = "Low birth weight"
    ),
    row_labels = c("Maternal race" = "Race"),
    level_labels = c("Yes" = "Smoker", "No" = "Non-smoker")
  )
```

| Characteristic              | Normal birth weight | Low birth weight |
|-----------------------------|---------------------|------------------|
| Maternal race               |                     |                  |
| Black                       | 15 (11.5%)          | 11 (18.6%)       |
| Other                       | 42 (32.3%)          | 25 (42.4%)       |
| White                       | 73 (56.2%)          | 23 (39.0%)       |
| Smoking during pregnancy    |                     |                  |
| No                          | 86 (66.2%)          | 29 (49.2%)       |
| Yes                         | 44 (33.8%)          | 30 (50.8%)       |
| Categorical data are n (%). |                     |                  |

#### A clean table without explanatory notes

Use this only when the meaning of every statistic is defined in the
manuscript text, caption, or journal template.

``` r

summary_table(birthwt, include = c(age, race, smoke)) |>
  customise_table(
    theme = "minimal",
    show_footnotes = FALSE,
    bold_labels = TRUE,
    density = "compact"
  )
```

[TABLE]

You can also relabel factor levels within the table using
`level_labels`:

``` r

summary_table(mtcars, by = am, include = cyl, overall = TRUE) |>
  customise_table(
    level_labels = c(
      "4" = "4-cylinder",
      "6" = "6-cylinder",
      "8" = "8-cylinder"
    )
  )
```

[TABLE]

------------------------------------------------------------------------

## Exporting to Word

Results already print as flextables. Call
[`to_flextable()`](https://gtstats.thinkdenominator.com/reference/to_flextable.md)
explicitly when you want to set its font or autofit behaviour at
conversion time.

``` r

res <- summary_table(mtcars, by = am, include = c(mpg, wt, cyl), overall = TRUE) |>
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
      |> add_ci(vars = c(...))
      |> add_p()
      |> add_proportion(var = ...)
      |> add_total()
      |> customise_table(theme = "journal", ...)

Each `add_*()` function is independent — add only the rows your table
needs, in any order that makes sense for your report.
