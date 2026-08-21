# Start here: a simple gtstats workflow

## The workflow

gtstats is designed around one practical sequence:

1.  **Understand** the data with
    [`describe_data()`](https://gtstats.thinkdenominator.com/reference/describe_data.md).
2.  **Assess** selected continuous variables with
    [`assess_distribution()`](https://gtstats.thinkdenominator.com/reference/assess_distribution.md)
    and, for grouped data,
    [`assess_variance()`](https://gtstats.thinkdenominator.com/reference/assess_variance.md).
3.  **Describe** participants with
    [`summary_table()`](https://gtstats.thinkdenominator.com/reference/summary_table.md).
4.  **Compare** one variable across groups with
    [`compare_groups()`](https://gtstats.thinkdenominator.com/reference/compare_groups.md).
5.  **Inspect** assumptions, diagnostics, and denominators when needed.
6.  **Render or export** only when you want to customise the finished
    output.

The main functions print publication-ready tables by default.
[`tbl_stats()`](https://gtstats.thinkdenominator.com/reference/tbl_stats.md)
is not an analysis step: it provides the `gt` table for titles, styling,
and export.

### Install and load

``` r

# Development version until the package is on CRAN
remotes::install_github("ThinkDenominator/gtstats")
library(gtstats)
data("birthwt", package = "gtstats")
```

### 1. Understand a dataset

``` r

overview <- describe_data(birthwt)
overview
overview$issues
```

The printed table is a compact first look. `$issues` is deliberately
separate so an ordinary data overview is not cluttered with cautions
that do not apply.

### Built-in teaching datasets

Use the labelled datasets included with gtstats when learning the
workflow or sharing reproducible examples:

``` r

data("birthwt", "trial_data", "paired_data", package = "gtstats")
```

`birthwt` is a real low-birth-weight study dataset. `trial_data` is a
three-arm synthetic clinical trial designed to demonstrate Welch ANOVA,
Kruskal-Wallis, chi-square, Fisher exact, correlation, and rates.
`paired_data` is long-format paired follow-up data for paired t-tests,
Wilcoxon signed-rank, and McNemar tests. Each help page contains its
data dictionary and examples.

### Prefer a guided interface?

[`gtstats_app()`](https://gtstats.thinkdenominator.com/reference/gtstats_app.md)
is an optional Shiny companion for learners and collaborators who prefer
a menu-driven starting point. It can load a built-in teaching dataset or
a CSV/Excel file, show a working data dictionary, then guide the user
through data description, distribution and spread checks, Table 1, group
comparisons, and crosstabs. Every analysis page displays the
corresponding R code with copy and `.R` download buttons, while result
tables can be downloaded as Word, HTML, PDF, or RTF. The optional `rio`
package enables Excel import.

``` r

# Run once if Shiny is not installed
install.packages("shiny")
install.packages("rio") # only needed for Excel files

gtstats_app()
```

The GUI is not a substitute for a reproducible script: copy the
displayed code into an R script or Quarto document before final
reporting. While the app is open, the R console displays
`Listening on ...`; this is normal. Click **Close app** in the
bottom-right corner of the interface to end the local session cleanly
and return to the R prompt.

### 2. Assess distribution for descriptive reporting

``` r

distribution <- assess_distribution(birthwt, vars = c(age, lwt), by = low)
distribution
distribution$recommendations
```

This function is restricted to continuous numeric variables. It uses
skewness, data quality, and Shapiro-Wilk as supporting information to
guide descriptive presentation. It does not choose an inferential test.

When groups are being compared, inspect their observed spread
separately:

``` r

variance <- assess_variance(birthwt, vars = c(age, lwt), by = low)
variance
```

[`assess_variance()`](https://gtstats.thinkdenominator.com/reference/assess_variance.md)
presents one row per variable: each group’s usable `n`, SD, and
variance, the observed SD and variance ratios, Levene p, and a short
interpretation. These are descriptive diagnostics, not a test-selection
rule: Welch methods do not require equal variances.

### How Auto chooses an inferential test

The automatic algorithm is deliberately visible and can always be
overridden:

| Data structure | Auto route |
|----|----|
| Continuous, 2 independent groups | Welch t-test when no marked skew is flagged; Student’s t-test only with `var_equal = TRUE`; Wilcoxon rank-sum when marked skew is flagged |
| Continuous, 3+ independent groups | Welch ANOVA when no marked skew is flagged; classical ANOVA only with `var_equal = TRUE`; Kruskal-Wallis when marked skew is flagged |
| Continuous, paired | Paired t-test or repeated-measures ANOVA when no marked skew is flagged; Wilcoxon signed-rank or Friedman when flagged |
| Independent categorical or ordinal | Chi-square when expected-count guidance is met; Fisher exact when an expected count is below 1 or more than 20% are below 5 |
| Paired binary | McNemar for 2 occasions; Cochran’s Q for 3+ occasions |

The skewness threshold—not the Shapiro-Wilk p-value alone—controls the
continuous rank-based switch. Levene and Bartlett results are
descriptive support and never change Auto. Inspect the recorded reason
with
[`diagnostics_stats()`](https://gtstats.thinkdenominator.com/reference/diagnostics_stats.md)
or `result$method$selection_rule`. The full explanation is in
[Inferential tests and
assumptions](https://gtstats.thinkdenominator.com/articles/inferential-tests.md).

### 3. Create a Table 1

``` r

table_one <- summary_table(
  birthwt,
  by = low,
  include = c(age, lwt, race, smoke),
  overall = "last"
) |>
  add_p()

table_one
```

Add optional rows only when they answer a specific reporting need:

``` r

table_one |>
  add_proportion(var = smoke, level = "Yes", label = "Smoking prevalence", ci = TRUE) |>
  add_total()
```

### 4. Compare one variable

``` r

comparison <- compare_groups(birthwt, variable = lwt, group = low)
comparison
```

For a transparent audit trail:

``` r

assumptions_stats(comparison)
diagnostics_stats(comparison)
denominators_stats(comparison)
```

### 5. Customise and export

``` r

table_one |>
  tbl_stats(title = "Table 1. Vehicle characteristics") |>
  customise_table(theme = "journal") |>
  save_output("table-1.docx")
```

Before reporting any percentage or inference, read [Missing data and
denominators](https://gtstats.thinkdenominator.com/articles/missing-data-denominators.md).
For a full clinical example, continue to the [birth-weight case
study](https://gtstats.thinkdenominator.com/articles/birthweight-case-study.md).
