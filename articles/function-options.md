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
latest Summary table, a recipe-style Summary workspace exposing total,
proportion, rate, custom-row and p-value ingredients, an in-session
history, and copyable or downloadable R code. Result tables download as
Word, HTML, PDF, or RTF. Distribution diagnostics offer histogram,
density, Q-Q and boxplots; comparisons use
[`plot_compare()`](https://gtstats.thinkdenominator.com/reference/plot_compare.md);
pair correlations and matrices use
[`plot_correlation()`](https://gtstats.thinkdenominator.com/reference/plot_correlation.md).
Plot labels, display, typography and relevant colours can be controlled
in the GUI, downloaded as PNG/PDF, and reproduced from its Code panel.
CSV input works directly; Excel input additionally needs `rio`. Display
customisation never changes estimates or test selection, and the app
does not replace a reproducible R script.

Within **Customise table**, choose **Current data are final calculated
results** only for an already summarised results sheet. The generated
code uses `as_stats_table(data)` and preserves its rows and values.
Participant-level raw data belong in **Summary table**; outbreak or
surveillance calculations belong in **Epi table**.

``` r

install.packages("shiny") # once, if needed
install.packages("rio")   # once, only for Excel files
gtstats_app()
```

### Choose the right table function

| Question | Use | Boundary |
|----|----|----|
| Describe several participant characteristics | [`summary_table()`](https://gtstats.thinkdenominator.com/reference/summary_table.md) | Manuscript descriptive tables and optional CI/p-value layers |
| Compare one outcome across groups | [`compare_groups()`](https://gtstats.thinkdenominator.com/reference/compare_groups.md) | One outcome only; use `summary_table() |> add_p()` for many variables |
| Report several outbreak or surveillance outcomes | [`epi_table()`](https://gtstats.thinkdenominator.com/reference/epi_table.md) | Line-list or aggregate epidemiological data |
| Estimate one selected proportion | [`proportion_stats()`](https://gtstats.thinkdenominator.com/reference/proportion_stats.md) | One event level, with its denominator and CI |
| Estimate one event/person-time rate | [`rate_stats()`](https://gtstats.thinkdenominator.com/reference/rate_stats.md) | One event count and one exposure-time denominator |
| Explore two categorical variables | [`crosstabs()`](https://gtstats.thinkdenominator.com/reference/crosstabs.md) | n x m percentages; OR, RR and RD when the table is 2 x 2 |
| Highlight one event or rate inside Table 1 | [`add_proportion()`](https://gtstats.thinkdenominator.com/reference/add_proportion.md) or [`add_rate()`](https://gtstats.thinkdenominator.com/reference/add_rate.md) | Specialist rows, not the global CI route |
| Present already calculated numeric results | [`as_stats_table()`](https://gtstats.thinkdenominator.com/reference/as_stats_table.md) | Does not parse or recalculate formatted text |

Use
[`add_ci()`](https://gtstats.thinkdenominator.com/reference/add_ci.md)
to add intervals to eligible variables already present in a summary
table.
[`add_proportion()`](https://gtstats.thinkdenominator.com/reference/add_proportion.md)
is intentionally narrower: it adds one selected-event row.

### 1. Understand the data

#### `describe_data()`

| Option | Default / available choices | What it changes |
|----|----|----|
| `data` | required | Data frame to inspect |
| `vars` | `NULL`: all variables | Restrict the overview to selected variables |
| `digits` | `2` | Precision for displayed numeric values |
| `format` | `"table"`; also `"tibble"` | Choose the publication table or a plain console tibble |

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
| `format` | `"table"`; also `"tibble"` | Choose the publication table or a plain console tibble |

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
| `format` | `"table"`; also `"tibble"` | Choose the publication table or a plain console tibble |

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
| `overall` | `FALSE`; `TRUE`/`"first"`/`"last"` | Add an Overall column and choose its position |
| `statistic` | `"recommended"`; `"mean_sd"`, `"mean_se"`, `"mean_ci"`, `"median_iqr"`, `"both"` | Continuous-variable presentation; may be named by variable. `"mean_se"` is specialist and is never selected automatically. |
| `categorical` | `"n_percent"`; `"n_over_N_percent"`, `"n"`, `"percent"` | Categorical cell display |
| `categorical_layout` | `"combined"`; also `"separate"` | Keep n (%) together, or use distinct n and % child columns in categorical-only tables without CIs |
| `overall_categorical` | `"auto"`; also `"n_percent"`, `"n_over_N_percent"`, `"n"`, `"percent"` | Control only the Overall categorical cells. Automatic mode uses counts when grouped cells use row percentages |
| `show_dichotomous` | `"all_levels"`; also `"single_row"` | Show both binary levels or one compact event row |
| `value` | `NULL`; named vector/list | Select event levels for compact binary rows, e.g. `c(smoke = "Yes")` |
| `percent` | `"column"`; `"row"`, `"overall"` | Denominator used for categorical percentages |
| `digits` | `1`, or named `continuous`, `percent`, `ci` values | Global display precision |
| `missing` | `"ifany"`; `"always"`, `"no"`, `"as_category"` | Show missing rows when needed, always, or never; `"as_category"` also includes missing in categorical percentages |
| `layout` | `"compact"`; also `"separate"` | Request summary and CI child columns; they appear only when a CI layer is added, so empty CI columns are never shown |
| `label` | `NULL` | Named replacement labels for source variables |
| `format` | `"table"`; also `"tibble"` | Publication table by default; console mode prints the completed builder’s plain tibble and remains compatible with `add_*()` layers |

``` r

summary_table(
  birthwt_data, by = low, include = c(age, smoke), overall = "last",
  categorical = "n_over_N_percent", layout = "separate"
)

summary_table(
  birthwt_data,
  by = low,
  include = c(smoke, ht, race),
  show_dichotomous = "single_row",
  value = c(smoke = "Yes", ht = "Yes")
)
```

#### Table-building helpers

##### `add_ci()`

| Option | Default / available choices | What it changes |
|----|----|----|
| `vars` | `NULL` (all eligible); bare names or a character vector | Apply CIs globally or only to selected table variables |
| `conf.level` | `0.95` | Confidence level for the new intervals |
| `method` | `"wilson"`; also `"exact"` | Binomial interval method for categorical proportions |
| `digits` | inherits the table | Optional confidence-limit precision |

[`add_ci()`](https://gtstats.thinkdenominator.com/reference/add_ci.md)
adds binomial CIs to displayed categorical proportions and t-based CIs
to continuous means. It does not silently replace median (IQR)
summaries: median-only variables are left unchanged and reported in the
table note. Compact cells contain the estimate followed by the interval.
Separate layouts use a dynamic estimate header—such as **n (%)** or
**Mean (SD)**—and an explicit **95% CI** header. The confidence level
and method are reported once in the publication footnote rather than
repeated in every cell.

``` r

summary_table(
  birthwt_data,
  by = low,
  include = c(age, lwt, race, smoke),
  layout = "separate"
) |>
  add_ci(vars = c(age, race)) |>
  add_p()
```

##### `add_summary()` (incremental builder)

The beginner route is `summary_table(..., include = ...)`.
[`add_summary()`](https://gtstats.thinkdenominator.com/reference/add_summary.md)
supports deliberate incremental construction when an empty builder was
created with `include = NULL`. It uses the same vocabulary as
[`summary_table()`](https://gtstats.thinkdenominator.com/reference/summary_table.md);
confidence intervals remain a separate
[`add_ci()`](https://gtstats.thinkdenominator.com/reference/add_ci.md)
layer.

| Option | Default / available choices | What it changes |
|----|----|----|
| `vars` | required | Variables appended to the current builder |
| `statistic` | `"recommended"`; `"mean_sd"`, `"mean_se"`, `"mean_ci"`, `"median_iqr"`, `"both"`; named overrides | Continuous summaries for the appended variables |
| `categorical` | `"n_percent"`; `"n_over_N_percent"`, `"n"`, `"percent"` | Categorical cell display |
| `categorical_layout` | `"combined"`; `"separate"` | Combined n (%) or separate n and % child columns for categorical-only tables |
| `show_dichotomous`, `value` | `"all_levels"`, `NULL`; `"single_row"`, named event levels | Full or compact binary display |
| `percent` | `"column"`; `"row"`, `"overall"`, `"none"` | Percentage denominator |
| `overall_categorical` | `"auto"`; explicit categorical formats | Overall-column categorical display |
| `layout` | inherited; `"compact"`, `"separate"` | Table layout to retain for later layers |
| `missing` | `"ifany"`; `"always"`, `"no"`, `"as_category"` | Missing-row display; `"as_category"` includes missing in categorical percentages |
| `digits` | `1`; named precision map | Display precision |

##### Specialist and structural helpers

| Function | Option | Default / available choices | What it changes |
|----|----|----|----|
| [`add_proportion()`](https://gtstats.thinkdenominator.com/reference/add_proportion.md) | `var`, `level` | `var` required; automatic target level if omitted | Adds one selected event prevalence row |
|  | `ci`, `conf.level`, `ci_method` | `TRUE`, inherited, inherited | Event CI method and confidence level |
|  | `layout` | inherits the table; `"compact"` or `"separate"` | Inline or separate estimate/CI columns |
|  | `display` | inherits table; `"n_percent"`, `"percent"`, `"n_over_N_percent"` | Specialist row cell display |
|  | `label`, `digits` | variable label, inherited | Row label and precision |
| [`add_rate()`](https://gtstats.thinkdenominator.com/reference/add_rate.md) | `event`, `time` | required | Add an event-count/person-time rate to an empty or populated summary table |
|  | `multiplier`, `time_label` | `1000`, `"person-time"` | Rate scale and readable time unit |
|  | `ci`, `conf.level`, `digits`, `label` | `TRUE`, `0.95`, `1`, automatic | Exact Poisson CI, precision, and label |
|  | `layout` | inherits the table; `"compact"` or `"separate"` | Inline or separate rate/CI columns |
| [`add_total()`](https://gtstats.thinkdenominator.com/reference/add_total.md) | `label`, `position` | `"Total (N)"`; `"last"` or `"first"` | One cohort-size row; headers already show N |
| [`add_row()`](https://gtstats.thinkdenominator.com/reference/add_row.md) | `label` | required | Free-text row label |
|  | `overall`, `values`, `level` | `NULL`, named group values, `""` | Values for Overall/group columns and an optional Level entry |
| [`add_p()`](https://gtstats.thinkdenominator.com/reference/add_p.md) | `test`, `include` | `test = "auto"`; `include = everything()` | Automatic or explicit test choice; omit inappropriate comparisons while retaining their descriptive rows |
|  | `paired`, `id` | `FALSE`, `NULL` | Paired analysis and participant identifier |
|  | `distribution_check`, `var_equal`, `correction` | `TRUE`, `FALSE`, `TRUE` | Auto marked-skew guidance, the prespecified equal-variance parametric route, and continuity correction |
|  | `fisher_seed` | `1049`; `NULL` uses current RNG state | Makes simulated Fisher p-values for larger tables reproducible |
|  | `p_adjust` | `"none"`; all [`stats::p.adjust.methods`](https://rdrr.io/r/stats/p.adjust.html) | Multiplicity-adjust displayed p-values |
|  | `digits` | `3` | P-value precision |

Independent ordered factors use the same chi-square/Fisher distribution
comparison as other categorical variables. Request `test = "wilcox"` or
`test = "kruskal"` when the ordered scale itself is the intended
rank-based comparison. If an ordered factor and another variable share
the same publication label, source-variable identity—not the displayed
label—determines the test and superscript.

[`add_proportion()`](https://gtstats.thinkdenominator.com/reference/add_proportion.md)
deliberately highlights one selected event, such as `"Yes"`. Use
[`add_ci()`](https://gtstats.thinkdenominator.com/reference/add_ci.md)
when existing table variables need intervals. The p-value produced by
[`add_p()`](https://gtstats.thinkdenominator.com/reference/add_p.md)
belongs to the full variable association; it is not duplicated on the
selected-event row.

``` r

summary_table(birthwt_data, by = low, include = c(age, smoke), overall = TRUE) |>
  add_ci() |>
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

`add_p(test = "auto")` delegates to this same algorithm for every
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

#### `epi_table()`

Use
[`epi_table()`](https://gtstats.thinkdenominator.com/reference/epi_table.md)
when a table must report several outbreak or surveillance estimates with
their cases, denominators and confidence intervals. It accepts either
individual line-list outcomes or already aggregated numerator and
denominator columns. These routes are deliberately mutually exclusive.

| Option | Default / available choices | What it changes |
|----|----|----|
| `outcomes` | line-list route | Select one or more individual-record outcomes |
| `event` | sensible default; scalar or named vector | Define the counted event for every selected outcome; explicit values are recommended |
| `numerator`, `denominator` | aggregate route | Supply event counts and eligible population/person-time |
| `label` | `NULL` | Use an aggregate label column or a single reporting label |
| `person_time` | `NULL` | Required for a line-list incidence rate |
| `by` | `NULL` | Produce estimates by group and enable optional comparisons |
| `measure` | `"proportion"`; also `"prevalence"`, `"attack_rate"`, `"incidence_rate"` | Define the interpretation and interval family |
| `multiplier` | `100`, or `1000` for incidence | Report per 100, 1,000, 10,000, 100,000 or another positive scale |
| `ci_method` | `"wilson"`; also `"exact"` | Binomial interval; incidence always uses exact Poisson |
| `p_value`, `p_adjust` | `FALSE`, `"none"` | Optionally compare groups and adjust across outcomes |
| `effects` | `"none"`; `"all"`, `"rr"`, `"rd"`, `"or"`, or `"irr"` | Add appropriate effect estimates when exactly two groups are present |
| `layout` | `"auto"`; `"wide"`, `"long"` | Auto uses wide output for up to four groups |
| `conf.level`, `digits`, `format` | `0.95`, `1`, `"table"` | Confidence, precision and publication/tibble output |

``` r

epi_table(
  birthwt_data,
  outcomes = low,
  by = smoke,
  event = "Low birth weight",
  measure = "prevalence"
)
```

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

#### `customise_table()`

Before styling a table of values calculated elsewhere, wrap it with
[`as_stats_table()`](https://gtstats.thinkdenominator.com/reference/as_stats_table.md).
This preserves every supplied row and value; it does not recalculate
statistics.

| [`as_stats_table()`](https://gtstats.thinkdenominator.com/reference/as_stats_table.md) option | Default / available choices | What it changes |
|----|----|----|
| `data` | required data frame/tibble | Uses the already calculated rows and columns as the table body |
| `notes` | `NULL`; character vector | Adds concise explanatory notes below the table |

``` r

calculated <- mtcars |>
  dplyr::summarise(N = dplyr::n(), `Mean mpg` = mean(mpg))

as_stats_table(calculated) |>
  customise_table(title = "Calculated vehicle summary")
```

For aggregate data,
[`add_ci()`](https://gtstats.thinkdenominator.com/reference/add_ci.md)
requires explicit ingredients. It never infers whether a denominator
means participants, person-time, or something else.

| [`add_ci()`](https://gtstats.thinkdenominator.com/reference/add_ci.md) aggregate option | Required columns | Method |
|----|----|----|
| `type = "proportion"` | `numerator`, `denominator` | Wilson score by default; `method = "exact"` is available |
| `type = "rate"` | `numerator`, `denominator` | Exact Poisson; use `multiplier` for rates per 100, 1,000, etc. |
| `type = "mean"` | `estimate`, `sd`, `n` | t-based interval for a mean |
| `type = "normal"` | `estimate`, `se` | Normal-approximation interval |

``` r

rates <- data.frame(
  Group = c("Treatment", "Control"),
  Events = c(12, 18),
  PersonYears = c(840, 910)
)

as_stats_table(rates) |>
  add_ci(
    type = "rate",
    numerator = Events,
    denominator = PersonYears,
    multiplier = 1000
  )
```

| Option | Default / available choices | What it changes |
|----|----|----|
| `x` | required | A `gtstats` result, `flextable`, or rendered `gt_tbl` |
| `engine` | `"flextable"`; also `"gt"` | Default Office-first renderer or explicit HTML renderer |
| `theme` | `"default"`; `"journal"`, `"classic"`, `"minimal"`, `"compact"` | Overall visual theme |
| `title`, `subtitle`, `source_note`, `footnotes` | `NULL` | Presentation heading and additional notes |
| `spanning_header` | `NULL` | Named vector mapping a displayed spanner label to one or more completed columns |
| `col_labels`, `row_labels`, `level_labels` | `NULL` | Named vectors that relabel completed output without changing analysis |
| `align`, `hide_cols`, `bold_cols`, `italic_cols` | `NULL` | Per-column layout/emphasis controls |
| `font_size`, `font`, `width` | `NULL` | Typography and table width |
| `row_striping`, `stripe_color`, `accent_color` | `NULL` | Alternating rows and colour accents |
| `borders` | `"horizontal"`; `"all"`, `"minimal"` | Publication border treatment |
| `density` | `"standard"`; `"compact"`, `"spacious"` | Cell padding and visual density |
| `column_widths` | `NULL` | Named numeric widths for selected columns |
| `pvalue_style` | `"threshold"`; `"fixed"`, `"scientific"` | Completed p-value display without changing the tests |
| `pvalue_digits`, `pvalue_threshold`, `pvalue_prefix` | `3`, `0.001`, `FALSE` | P-value precision, lower display threshold, and optional `p =` prefix |
| `bold_labels`, `show_footnotes` | `TRUE`, `TRUE` | Controls used if a raw result must first be rendered |

#### `to_gt()`

| Option | Default / available choices | What it changes |
|----|----|----|
| `x` | required; original `gtstats` object | Explicitly renders an HTML-focused `gt` table |
| `title`, `subtitle` | `NULL` | Optional heading |
| `bold_labels`, `show_footnotes` | `TRUE`, `TRUE` | Label emphasis and explanatory notes |

#### `to_flextable()`

| Option | Default / available choices | What it changes |
|----|----|----|
| `x` | required; original `gtstats` object | Explicitly renders a Word/PowerPoint-ready `flextable` |
| `font_size`, `font` | `10`, `NULL` | Office-table typography; font uses the Office default when omitted |
| `autofit`, `show_footnotes` | `TRUE`, `TRUE` | Automatic widths and concise table notes |
| `title`, `subtitle` | `NULL` | Optional heading |

#### `save_output()`

| Option | Default / available choices | What it changes |
|----|----|----|
| `x`, `filename` | required | One result, or a named list of tables and plots for one Word report, plus filename with extension |
| `path` | `NULL`: current working directory | Destination directory; relative/full filenames also work |
| `title`, `subtitle`, `bold_labels`, `show_footnotes` | `NULL`, `NULL`, `TRUE`, `TRUE` | Rendering controls for raw table results |
| `zoom`, `expand`, `vwidth`, `vheight` | `2`, `5`, `992`, `744` | PNG table-export browser sizing |
| `width`, `height`, `units`, `dpi`, `bg` | `8`, `6`, `"in"`, `300`, `"white"` | Plot export size/resolution/background |
| `page_break` | `TRUE` | With a list saved to Word, start each output on a new page |
| `quiet` | `FALSE` | Suppress the saved-path message |

Table extensions include `.docx`, `.pptx`, `.rtf`, `.html`, `.png`,
`.pdf`, and `.tex`. Office formats use the flextable-first route. A
mixed list of tables and plots is supported for `.docx` reports.

``` r

save_output(
  list(
    "Dataset overview" = describe_data(birthwt),
    "Table 1" = summary_table(
      birthwt, by = low, include = c(age, lwt, race, smoke), overall = TRUE
    ) |>
      add_p(),
    "Maternal age by outcome" = plot_compare(
      birthwt, variable = age, group = low
    )
  ),
  "gtstats-report.docx",
  title = "Birth-weight study",
  page_break = TRUE
)
```

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
