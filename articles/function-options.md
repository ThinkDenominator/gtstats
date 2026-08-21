# Function options

## Function options at a glance

This guide is the practical companion to the reference pages. Every
exported `gtstats` function appears below. The tables distinguish
required inputs from optional controls, state the default, list
available choices, and explain what each option changes. Use the linked
reference page for validation details and worked examples.

All examples below use the built-in labelled birth-weight teaching data:

``` r

data("birthwt", package = "gtstats")
birthwt_data <- birthwt
```

### Guided interface

#### `gtstats_app()`

| Option | Default / available choices | What it changes |
|----|----|----|
| `launch.browser` | RStudio Viewer when available; otherwise [`interactive()`](https://rdrr.io/r/base/interactive.html) | Where to open the local app |
| `...` | optional | Additional arguments passed to [`shiny::runApp()`](https://rdrr.io/pkg/shiny/man/runApp.html) |

[`gtstats_app()`](https://gtstats.thinkdenominator.com/reference/gtstats_app.md)
is an optional point-and-click companion; it requires the suggested
`shiny` package. It supports the same core workflow as this guide, adds
a data dictionary, Summary-table presentation controls, a dedicated
**Customise table** workspace that automatically carries forward the
latest Summary table, an in-session history, and copyable or
downloadable R code. Result tables download as Word, HTML, PDF, or RTF.
Distribution diagnostics offer histogram, density, Q-Q and boxplots;
comparisons use
[`plot_compare()`](https://gtstats.thinkdenominator.com/reference/plot_compare.md);
pair correlations and matrices use
[`plot_correlation()`](https://gtstats.thinkdenominator.com/reference/plot_correlation.md).
Plot labels, display, typography and relevant colours can be controlled
in the GUI, downloaded as PNG/PDF, and reproduced from its Code panel.
CSV input works directly; Excel input additionally needs `rio`. Display
customisation never changes estimates or test selection, and the app
does not replace a reproducible R script.

``` r

install.packages("shiny") # once, if needed
install.packages("rio")   # once, only for Excel files
gtstats_app()
```

### 1. Understand the data

#### `describe_data()`

| Option | Default / available choices | What it changes |
|----|----|----|
| `data` | required | Data frame to inspect |
| `vars` | `NULL`: all variables | Restrict the overview to selected variables |
| `digits` | `2` | Precision for displayed numeric values |
| `format` | `"table"`; also `"tibble"` | Choose the publication table or a plain console tibble (`output` remains a compatibility alias) |

``` r

describe_data(birthwt_data, vars = c("age", "smoke"))
```

#### `assess_distribution()`

| Option | Default / available choices | What it changes |
|----|----|----|
| `data`, `vars` | `vars = NULL`: all eligible continuous variables | Select the continuous variables to assess |
| `by` | `NULL` | Assess each continuous variable within groups |
| `normality_test` | `TRUE` | Include Shapiro-Wilk p-values as supporting information |
| `skew_cutoff` | `1` | Absolute skewness at which marked skew is flagged |
| `min_n` | `3` | Minimum usable observations for a distribution assessment |
| `plots` | `FALSE` | Return histogram, density, Q-Q, and boxplot diagnostics |
| `digits` | `2` | Display precision |
| `format` | `"table"`; also `"tibble"` | Choose the publication table or a plain console tibble (`output` remains a compatibility alias) |

``` r

assess_distribution(birthwt_data, vars = c(age, lwt), by = low)
```

#### `assess_variance()`

| Option | Default / available choices | What it changes |
|----|----|----|
| `data`, `by` | required | Supply data and the categorical grouping variable |
| `vars` | `NULL`: all eligible continuous variables | Restrict variables to inspect |
| `digits` | `2` | SD, variance, and ratio precision |
| `test` | `"levene"`; also `"none"`, `"bartlett"` | Display median-centred Levene (Brown-Forsythe) by default; Bartlett remains optional supporting information; neither selects the comparison test |
| `format` | `"table"`; also `"tibble"` | Choose the publication table or a plain console tibble (`output` remains a compatibility alias) |

[`assess_variance()`](https://gtstats.thinkdenominator.com/reference/assess_variance.md)
prints one row per variable. Read it from left to right: each group
column gives its usable `n`, SD, and variance. **Observed SD ratio** and
**Observed variance ratio** describe the largest value divided by the
smallest, **Levene p** is supporting information, and **Interpretation**
states the practical takeaway. Detailed test metadata remain available
in `$summary` and `$diagnostics`. They are descriptive diagnostics, not
pass/fail tests: Welch t-tests and Welch ANOVA do not require equal
variances, and this function never selects a test. The median-centred
Levene test is less sensitive to non-normality than Bartlett’s test.
Bartlett’s test assumes normal group distributions. Neither p-value
proves equal variances or replaces the prespecified `var_equal` choice.

``` r

assess_variance(birthwt_data, vars = c(age, lwt), by = low)
assess_variance(birthwt_data, vars = c(age, lwt), by = low, test = "levene")
```

### 2. Describe and compare

#### `summary_table()`

| Option | Default / available choices | What it changes |
|----|----|----|
| `data` | required | Data frame to summarise |
| `by` | `NULL` | Create one column per observed group |
| `include` | `NULL` | Build the table immediately from selected variables; omit for an empty builder |
| `mode` | `"summary"`; also `"rate"` | Choose a descriptive Table 1 or a rate-only builder |
| `overall` | `FALSE`; `TRUE`/`"first"`/`"last"` | Add an Overall column and choose its position |
| `statistic` | `"recommended"`; `"mean_sd"`, `"mean_ci"`, `"median_iqr"`, `"both"` | Continuous-variable presentation; may be named by variable |
| `categorical` | `"n_percent"`; `"n_over_N_percent"`, `"n"`, `"percent"` | Categorical cell display |
| `percent` | `"column"`; `"row"`, `"overall"` | Denominator used for categorical percentages |
| `digits` | `1`, or named `continuous`, `percent`, `ci` values | Global display precision |
| `missing` | `"ifany"`; `"always"`, `"no"` | Show missing rows only when needed, always, or never |
| `ci`, `conf.level`, `ci_method` | `FALSE`, `0.95`, `"wilson"`; method also `"exact"` | Add binomial CIs to every categorical level and choose the interval method |
| `layout` | `"compact"`; also `"separate"` | Keep summaries inline or place summary and CI in child columns beneath each cohort |
| `label` | `NULL` | Named replacement labels for source variables |
| `format` | `"table"`; also `"tibble"` | Publication table by default; console mode prints the completed builder’s plain tibble and remains compatible with `add_*()` layers |

``` r

summary_table(
  birthwt_data, by = low, include = c(age, smoke), overall = "last",
  statistic = "mean_ci", categorical = "n_over_N_percent"
)
```

#### Table-building helpers

##### `add_summary()`

| Option | Default / available choices | What it changes |
|----|----|----|
| `vars` | required | Variables added to an empty or existing summary builder |
| `continuous_format` / `statistic` | `"recommended"`; `"mean_sd"`, `"mean_ci"`, `"median_iqr"`, `"both"` | Continuous-variable display; `statistic` can be named by variable |
| `categorical` | `"n_percent"`; `"n_over_N_percent"`, `"n"`, `"percent"` | Categorical cell display |
| `percent` | `"column"`; `"row"`, `"overall"`, `"none"` | Percentage denominator, or counts only |
| `ci`, `conf.level`, `ci_method` | `FALSE`, `0.95`, `"wilson"`; method also `"exact"` | Add binomial CIs to all categorical levels and choose the interval method |
| `missing` | `"ifany"`; `"always"`, `"no"` | Missing-row display |
| `digits` | `1`, or named precision | Continuous, percentage, and CI precision |

##### Specialist and structural helpers

| Function | Option | Default / available choices | What it changes |
|----|----|----|----|
| [`add_proportion()`](https://gtstats.thinkdenominator.com/reference/add_proportion.md) | `var`, `level` | `var` required; automatic target level if omitted | Adds one selected event prevalence row |
|  | `ci`, `conf.level`, `ci_method` | `TRUE`, `0.95`, `"wilson"`; also `"exact"` | Event CI method and confidence level |
|  | `layout` | inherits the table; `"compact"` or `"separate"` | Inline or separate estimate/CI columns |
|  | `display` | `"n_percent"`; `"percent"`, `"n_over_N_percent"` | Specialist row cell display |
|  | `label`, `digits` | variable label, `1` | Row label and precision |
| [`add_rate()`](https://gtstats.thinkdenominator.com/reference/add_rate.md) | `event`, `time` | required | Event-count and person-time variables in `mode = "rate"` |
|  | `multiplier`, `time_label` | `1000`, `"person-time"` | Rate scale and readable time unit |
|  | `ci`, `conf.level`, `digits`, `label` | `TRUE`, `0.95`, `1`, automatic | Exact Poisson CI, precision, and label |
|  | `layout` | inherits the table; `"compact"` or `"separate"` | Inline or separate rate/CI columns |
| [`add_total()`](https://gtstats.thinkdenominator.com/reference/add_total.md) | `label`, `position` | `"Total (N)"`; `"last"` or `"first"` | One cohort-size row; headers already show N |
| [`add_row()`](https://gtstats.thinkdenominator.com/reference/add_row.md) | `label` | required | Free-text row label |
|  | `overall`, `values`, `level` | `NULL`, named group values, `""` | Values for Overall/group columns and an optional Level entry |
| [`add_p()`](https://gtstats.thinkdenominator.com/reference/add_p.md) | `method`, `include` | `method = "auto"`; `include = everything()` | Automatic or explicit test choice; omit inappropriate comparisons while retaining their descriptive rows |
|  | `paired`, `id` | `FALSE`, `NULL` | Paired analysis and participant identifier |
|  | `distribution_check`, `var_equal`, `correction` | `TRUE`, `FALSE`, `TRUE` | Auto marked-skew guidance, the prespecified equal-variance parametric route, and continuity correction |
|  | `fisher_seed` | `1049`; `NULL` uses current RNG state | Makes simulated Fisher p-values for larger tables reproducible |
|  | `p_adjust` | `"none"`; all [`stats::p.adjust.methods`](https://rdrr.io/r/stats/p.adjust.html) | Multiplicity-adjust displayed p-values |
|  | `digits` | `3` | P-value precision |

Independent ordered factors use the same chi-square/Fisher distribution
comparison as other categorical variables. Request `method = "wilcox"`
or `method = "kruskal"` when the ordered scale itself is the intended
rank-based comparison. If an ordered factor and another variable share
the same publication label, source-variable identity—not the displayed
label—determines the test and superscript.

[`add_proportion()`](https://gtstats.thinkdenominator.com/reference/add_proportion.md)
deliberately highlights one selected event, such as `"Yes"`. Use
`summary_table(ci = TRUE)` when every categorical level needs an
interval. The p-value produced by
[`add_p()`](https://gtstats.thinkdenominator.com/reference/add_p.md)
belongs to the full variable association; it is not duplicated on the
selected-event row.

``` r

summary_table(birthwt_data, by = low, overall = TRUE) |>
  add_summary(vars = c(age, smoke)) |>
  add_proportion(var = smoke, level = "Yes", ci = TRUE) |>
  add_p()
```

#### `compare_groups()`

| Option | Default / available choices | What it changes |
|----|----|----|
| `data`, `variable`, `group` | required | State one outcome variable and the categorical comparison group |
| `test` | `"auto"`; parametric `"t_test"`, `"welch_t"`, `"anova"`, `"welch_anova"`, `"rm_anova"`; non-parametric `"wilcox"`, `"kruskal"`, `"friedman"`; categorical `"chisq"`, `"fisher"`, `"mcnemar"`, `"cochran_q"` | Automatic selection or an explicit valid test |
| `var_equal` | `FALSE` | When no marked skew is flagged in an independent continuous auto comparison, `TRUE` selects Student’s t-test or classical ANOVA; it is user-specified, never inferred from a variance test |
| `paired`, `id` | `FALSE`, `NULL` | Analyse repeated measurements; `id` is required when paired |
| `effect_size` | `FALSE` | Add a compatible effect-size estimate to the result |
| `conf.level`, `digits` | `0.95`, `2` | Interval confidence and display precision |
| `format` | `"table"`; also `"tibble"` | Publication-ready default or plain console output |
| `...` | optional | Advanced controls used by the selected method |

``` r

compare_groups(birthwt_data, variable = lwt, group = low, test = "welch_t")
```

##### Exact `test = "auto"` algorithm

`add_p(method = "auto")` delegates to this same algorithm for every
variable.

| Outcome and design | Automatic decision | Automatic test |
|----|----|----|
| Continuous, 2 independent groups | Marked skewness in either group | Wilcoxon rank-sum |
| Continuous, 2 independent groups | No marked skew; `var_equal = FALSE` | Welch t-test |
| Continuous, 2 independent groups | No marked skew; `var_equal = TRUE` | Student’s t-test |
| Continuous, 3+ independent groups | Marked skewness in any group | Kruskal-Wallis |
| Continuous, 3+ independent groups | No marked skew; `var_equal = FALSE` | Welch ANOVA |
| Continuous, 3+ independent groups | No marked skew; `var_equal = TRUE` | Classical one-way ANOVA |
| Continuous, 2 paired occasions | Marked skewness in within-pair differences / no marked skew | Wilcoxon signed-rank / paired t-test |
| Continuous, 3+ paired occasions | Marked skewness at any occasion / no marked skew | Friedman / repeated-measures ANOVA |
| Binary, nominal, or ordinal; independent | Any expected count below 1, or more than 20% below 5 / otherwise | Fisher exact (Monte Carlo for larger sparse tables) / Pearson chi-square |
| Ordinal; paired | 2 / 3+ occasions | Wilcoxon signed-rank / Friedman |
| Binary; paired | 2 / 3+ occasions | McNemar / Cochran’s Q |

“Marked skewness” means the package’s absolute sample-skewness flag
(default cut-off 1). Shapiro-Wilk is supporting information only.
`var_equal` is never inferred from Levene, Bartlett, or an F-test and
applies only to the independent continuous parametric route.
Repeated-measures ANOVA still needs a design-level sphericity review.

[`compare_groups()`](https://gtstats.thinkdenominator.com/reference/compare_groups.md)
is a focused one-outcome analysis. For several variables and one p-value
per row block, use `summary_table(..., include = ...) |> add_p()`. This
distinction prevents a focused result object from silently becoming a
multi-outcome screening table.

#### `effect_size()`

| Option | Default / available choices | What it changes |
|----|----|----|
| `data`, `outcome`, `by` | required | Variable and categorical group to compare |
| `method` | `"auto"`; `"hedges_g"`, `"rank_biserial"`, `"omega_squared"`, `"epsilon_squared"`, `"cramers_v"` | Effect measure; auto chooses from design/type |
| `paired`, `id` | `FALSE`, `NULL` | Paired effect-size calculation; `id` required when paired |
| `conf.level`, `digits` | `0.95`, `2` | Interval confidence and display precision |
| `interpretation` | `FALSE` | Add conventional magnitude labels; do not treat as clinical importance |
| `format` | `"table"`; also `"tibble"` | Publication-ready default or plain console output |

#### `correlation()`

| Option | Default / available choices | What it changes |
|----|----|----|
| `data`, `x`, `y` | pair route | Two continuous variables; complete finite pairs are analysed |
| `vars` | `NULL`; for example `c(age, weight, outcome)` | Build a multi-variable correlation matrix instead of one pair |
| `method` | `"auto"`; `"pearson"`, `"spearman"` | Correlation method |
| `triangle` | `"lower"`; `"upper"`, `"full"` | Matrix layout |
| `order` | `"input"`; `"alphabetical"`, `"cluster"` | Preserve the requested order, sort display labels, or place strongly related variables together |
| `show_diagonal` | `TRUE` | Show or hide self-correlations |
| `display` | `"estimate"`; `"estimate_p"`, `"estimate_n"`, `"estimate_p_n"`, `"estimate_ci"` | Matrix cell content |
| `shade` | `TRUE` | Shade matrix cells by coefficient direction and magnitude |
| `missing` | `"pairwise"` | Use complete finite observations separately for each pair |
| `adjust` | `"none"`; `"holm"`, `"bonferroni"`, `"BH"` | Adjust matrix p-values for multiplicity |
| `conf.level`, `digits` | `0.95`, `2` | Interval confidence and display precision |
| `format` | `"table"`; also `"tibble"` | Publication-ready default or plain console output |

``` r

correlation(birthwt_data, x = age, y = bwt, method = "spearman")

birthwt_matrix <- correlation(
  birthwt_data,
  vars = c(age, lwt, bwt),
  display = "estimate_p",
  adjust = "holm"
)

plot_correlation(birthwt_matrix)
```

Matrix mode uses one method throughout: automatic mode uses Pearson only
when all selected variables have absolute sample skewness below 1, and
Spearman otherwise. Pair-specific sample sizes and inferential results
remain available in the tidy `$summary` component. A matrix is
exploratory; multiplicity-adjusted p-values do not replace prespecified
analyses or establish causation.

### 3. Epidemiology

#### `proportion_stats()`

The publication renderer uses one row for the selected event. Grouped
results place `n (%)` and the confidence interval in separate columns
beneath each group header; this does not change the tidy `$summary`
component.

| Option | Default / available choices | What it changes |
|----|----|----|
| `data`, `var` | required | Categorical/binary/ordinal variable and selected event prevalence |
| `by` | `NULL` | Produce one prevalence estimate per group |
| `level` | automatic target event | Explicitly choose the event level; recommended for clinical outcomes |
| `ci_method` | `"wilson"`; also `"exact"` | Binomial CI method |
| `display` | `"n_percent"`; `"percent"`, `"n_over_N_percent"` | Estimate display |
| `conf.level`, `digits` | `0.95`, `1` | CI confidence and percentage precision |
| `format` | `"table"`; also `"tibble"` | Publication-ready default or plain console output |

#### `rate_stats()`

Grouped publication output uses each group as a spanning header above
Events, accumulated time, Rate and CI columns. The tidy `$summary`
component remains in long form and retains the number of contributing
records.

| Option | Default / available choices | What it changes |
|----|----|----|
| `data`, `event`, `time` | required | Non-negative integer events and finite person-time |
| `by` | `NULL` | Calculate a separate rate for each group |
| `multiplier`, `time_label` | `1000`, `"person-time"` | Scale and name the reported rate |
| `conf.level`, `digits` | `0.95`, `1` | Exact Poisson CI confidence and precision |
| `format` | `"table"`; also `"tibble"` | Publication-ready default or plain console output |

``` r

proportion_stats(birthwt_data, var = smoke, by = low, level = "Yes")
```

#### `crosstabs()`

| Option | Default / available choices | What it changes |
|----|----|----|
| `data`, `row`, `col` | required | Set exposure (rows) and outcome (columns) axes |
| `percent` | `"column"`; `"row"`, `"total"`, `"none"`, or a vector | Cell percentages; a vector can show multiple percentages |
| `totals` | `TRUE` | Include row/column margins |
| `row_level`, `col_level` | automatic for 2x2 | Explicitly define exposed and event levels for RR/OR/RD direction |
| `measures` | `c("rr", "or", "rd")`; also `"risk"` | Choose 2x2 measures; ignored for larger tables |
| `conf.level`, `risk_ci` | `0.95`, `"wilson"`; also `"exact"` | Measure/risk interval confidence and method |
| `test` | `"auto"`; `"none"`, `"chisq"`, `"fisher"` | Association-test selection |
| `zero_correction` | `"haldane_anscombe"`; also `"none"` | Zero-cell treatment for ratio estimates |
| `simulate_B`, `digits` | `10000`, `2` | Fisher simulation repetitions when needed and display precision |
| `format` | `"table"`; also `"tibble"` | Publication-ready default or plain console output |

``` r

crosstabs(birthwt_data, row = smoke, col = low, percent = c("row", "column"))
```

### 4. Plots, inspection, and output

#### `plot_compare()`

| Option | Default / available choices | What it changes |
|----|----|----|
| `data`, `outcome`, `by` | required | Outcome distribution or categorical composition by group |
| `type` | `"auto"`; `"box"`, `"bar"` | Auto selects boxplots for continuous and bars for categorical outcomes |
| `display` | `"proportion"`; also `"count"` | Bar-chart scale for categorical outcomes |
| `paired`, `id` | `FALSE`, `NULL` | Connected paired continuous plot; `id` required when paired |
| `show_points`, `show_p` | `TRUE`, `FALSE` | Overlay observations and add a test/p-value caption |
| `test` | `"auto"` or any [`compare_groups()`](https://gtstats.thinkdenominator.com/reference/compare_groups.md) test | Test used only when `show_p = TRUE` |
| `palette`, `base_size` | package palette, `14` | Colours and base text size |
| `title`, `caption`, `xlab`, `ylab`, `legend_title` | `NULL` | Publication labels and annotation |

#### `plot_correlation()`

| Option | Default / available choices | What it changes |
|----|----|----|
| `data`, `x`, `y` | required | Continuous variables to plot |
| `method` | `"auto"`; `"pearson"`, `"spearman"` | Correlation shown/used for annotation |
| `trend` | `"auto"`; `"linear"`, `"smooth"`, `"none"` | Fitted trend line type |
| `show_ci`, `show_correlation` | `TRUE`, `FALSE` | Trend confidence band and correlation annotation |
| `conf.level`, `digits` | `0.95`, `2` | Trend/correlation precision where relevant |
| `point_color`, `line_color`, `base_size` | `"#4472C4"`, `"#ED7D31"`, `14` | Visual styling |
| `title`, `caption`, `xlab`, `ylab` | `NULL` | Publication labels and annotation |

[`plot_compare()`](https://gtstats.thinkdenominator.com/reference/plot_compare.md)
uses complete observations for its displayed variables. For a continuous
outcome, `NA`, `NaN`, and infinite values are excluded. When
`show_p = TRUE`, the p-value is calculated from that same plotted
analysis population, so the group Ns and annotation describe the same
data.

#### Audit functions

| Function | Option | Default / available choices | What it changes |
|----|----|----|----|
| [`assumptions_stats()`](https://gtstats.thinkdenominator.com/reference/assumptions_stats.md) | `format` | `"table"`; also `"tibble"` | Return a formatted audit table or a plain console tibble |
|  | `view` | `"checklist"`; also `"audit"` | Plain-language action list or technical status/result codes |
|  | `title`, `subtitle` | `"Checks before reporting"`, `NULL` | Heading when `format = "table"` |
| [`diagnostics_stats()`](https://gtstats.thinkdenominator.com/reference/diagnostics_stats.md) | `format` | `"table"`; also `"tibble"` | Return a formatted audit table or plain console tibble |
|  | `view` | `"readable"`; also `"audit"` | Plain-language headings or raw diagnostic fields |
|  | `title`, `subtitle` | `"Diagnostics"`, `NULL` | Heading when `format = "table"` |
| [`denominators_stats()`](https://gtstats.thinkdenominator.com/reference/denominators_stats.md) | `format` | `"table"`; also `"tibble"` | Return a formatted denominator table or plain console tibble |
|  | `view` | `"readable"`; also `"audit"` | Reader-facing labels or raw denominator fields |
|  | `title`, `subtitle` | `"Denominator audit"`, `NULL` | Heading when `format = "table"` |

#### `tbl_stats()`

| Option | Default / available choices | What it changes |
|----|----|----|
| `x` | required | A supported analytical/builder result to render as `gt` |
| `title`, `subtitle` | `NULL` | Optional table heading |
| `bold_labels`, `show_footnotes` | `TRUE`, `TRUE` | Variable-label emphasis and explanatory footnotes |
| `digits`, `pvalue_style` | `NULL`; `"default"`/`"scientific"` | Reserved compatibility controls; set precision in the analysis function |

#### `customise_table()`

| Option | Default / available choices | What it changes |
|----|----|----|
| `x` | required | A `gtstats` result or rendered `gt_tbl` |
| `theme` | `"default"`; `"journal"`, `"classic"`, `"minimal"`, `"compact"` | Overall visual theme |
| `title`, `subtitle`, `source_note` | `NULL` | Presentation heading and source note |
| `col_labels`, `row_labels`, `level_labels` | `NULL` | Named vectors that relabel completed output without changing analysis |
| `align`, `hide_cols`, `bold_cols`, `italic_cols` | `NULL` | Per-column layout/emphasis controls |
| `font_size`, `font`, `width` | `NULL` | Typography and table width |
| `row_striping`, `stripe_color`, `accent_color` | `NULL` | Alternating rows and colour accents |
| `bold_labels`, `show_footnotes` | `TRUE`, `TRUE` | Controls used if a raw result must first be rendered |

#### `to_flextable()`

| Option | Default / available choices | What it changes |
|----|----|----|
| `x` | required; original `gtstats` object | Converts for Word/PowerPoint; do not pass [`tbl_stats()`](https://gtstats.thinkdenominator.com/reference/tbl_stats.md) output |
| `font_size`, `font` | `10`, `NULL` | Office-table typography; font uses the Office default when omitted |
| `autofit`, `show_footnotes` | `TRUE`, `TRUE` | Automatic widths and concise table notes |

#### `save_output()`

| Option | Default / available choices | What it changes |
|----|----|----|
| `x`, `filename` | required | A `gtstats` table/`gt_tbl` or `ggplot`, plus filename with extension |
| `path` | `NULL`: current working directory | Destination directory; relative/full filenames also work |
| `title`, `subtitle`, `bold_labels`, `show_footnotes` | `NULL`, `NULL`, `TRUE`, `TRUE` | Rendering controls for raw table results |
| `zoom`, `expand`, `vwidth`, `vheight` | `2`, `5`, `992`, `744` | PNG table-export browser sizing |
| `width`, `height`, `units`, `dpi`, `bg` | `8`, `6`, `"in"`, `300`, `"white"` | Plot export size/resolution/background |
| `quiet` | `FALSE` | Suppress the saved-path message |

``` r

summary_table(birthwt_data, by = low, include = c(age, smoke)) |>
  add_p() |>
  customise_table(title = "Baseline characteristics") |>
  save_output("table-1.html")
```

### The shortest useful workflow

Most users need only this sequence:

``` r

describe_data(birthwt_data)
assess_distribution(birthwt_data, vars = c(age, lwt, bwt), by = low)
summary_table(birthwt_data, by = low, include = c(age, lwt, smoke), overall = TRUE) |>
  add_p()
```

Use the function-specific
[reference](https://gtstats.thinkdenominator.com/reference/index.html)
for validation rules and all arguments. The [descriptive-table
guide](https://gtstats.thinkdenominator.com/articles/descriptive-tables.md)
explains reporting choices in more depth.
