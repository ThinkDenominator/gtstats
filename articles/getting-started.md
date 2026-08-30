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

The main functions print publication-ready flextables by default.
Rendering is not an analysis step: use
[`customise_table()`](https://gtstats.thinkdenominator.com/reference/customise_table.md)
for finishing touches and
[`to_gt()`](https://gtstats.thinkdenominator.com/reference/to_gt.md)
only when an HTML-focused gt table is required.

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
to_flextable(overview)
```

| Variable | Type | Complete | Unique | Overview | Range / levels |
|----|----|----|----|----|----|
| Birth-weight outcome \[low\] | binary | 189/189 (100.0%) | 2 | Normal birth weight 130 (68.8%); Low birth weight 59 (31.2%) | Normal birth weight, Low birth weight |
| Maternal age (years) \[age\] | continuous | 189/189 (100.0%) | 24 | Mean 23.24 (SD 5.30); median 23.00 | 14.00 to 45.00 |
| Maternal weight (lb) \[lwt\] | continuous | 189/189 (100.0%) | 75 | Mean 129.81 (SD 30.58); median 121.00 | 80.00 to 250.00 |
| Maternal race \[race\] | categorical | 189/189 (100.0%) | 3 | White 96 (50.8%); Other 67 (35.4%); Black 26 (13.8%) | White, Black, Other |
| Smoking during pregnancy \[smoke\] | binary | 189/189 (100.0%) | 2 | No 115 (60.8%); Yes 74 (39.2%) | No, Yes |
| Previous premature labours \[ptl\] | categorical\* | 189/189 (100.0%) | 4 | 0 159 (84.1%); 1 24 (12.7%); 2 5 ( 2.6%) | 0, 1, 2, 3 |
| Hypertension \[ht\] | binary | 189/189 (100.0%) | 2 | No 177 (93.7%); Yes 12 ( 6.3%) | No, Yes |
| Uterine irritability \[ui\] | binary | 189/189 (100.0%) | 2 | No 161 (85.2%); Yes 28 (14.8%) | No, Yes |
| First-trimester visits \[ftv\] | continuous | 189/189 (100.0%) | 6 | Mean 0.79 (SD 1.06); median 0.00 | 0.00 to 6.00 |
| Birth weight (g) \[bwt\] | continuous | 189/189 (100.0%) | 131 | Mean 2944.59 (SD 729.21); median 2977.00 | 709.00 to 4990.00 |
| Previous premature labour \[previous_preterm\] | binary | 189/189 (100.0%) | 2 | No 159 (84.1%); Yes 30 (15.9%) | No, Yes |
| First-trimester visits \[antenatal_visits\] | ordinal | 189/189 (100.0%) | 3 | None 100 (52.9%); One 47 (24.9%); Two or more 42 (22.2%) | None, One, Two or more |
| One row is shown per selected variable. |  |  |  |  |  |
| Potential data-quality findings and interpretation prompts are stored in \`\$issues\`. |  |  |  |  |  |
| \* Possible ordinal or count-coded variable; confirm the intended meaning and order from the data dictionary or clinical context. |  |  |  |  |  |

``` r

overview$issues
#> # A tibble: 2 × 5
#>   variable label                      issue          why_flagged suggested_check
#>   <chr>    <chr>                      <chr>          <chr>       <chr>          
#> 1 ptl      Previous premature labours Sparse catego… At least o… Confirm coding…
#> 2 ftv      First-trimester visits     Low-cardinali… Only 6 dis… Confirm whethe…
```

The printed table is a compact first look. `$issues` is deliberately
separate so an ordinary data overview is not cluttered with cautions
that do not apply.

### Built-in teaching datasets

Use the labelled datasets included with gtstats when learning the
workflow or sharing reproducible examples:

``` r

data(
  "birthwt", "trial_data", "paired_data", "outbreak_data",
  "surveillance_data", package = "gtstats"
)
```

`birthwt` is a real low-birth-weight study dataset. `trial_data` is a
three-arm synthetic clinical trial designed to demonstrate Welch ANOVA,
Kruskal-Wallis, chi-square, Fisher exact, correlation, and rates.
`paired_data` is long-format paired follow-up data for paired t-tests,
Wilcoxon signed-rank, and McNemar tests. Each help page contains its
data dictionary and examples. `outbreak_data` is CDC’s classic Oswego
foodborne-outbreak line list, while `surveillance_data` is an archived
CDC weekly hospital-admission extract. They demonstrate the line-list
and aggregate-data routes of
[`epi_table()`](https://gtstats.thinkdenominator.com/reference/epi_table.md).

### Prefer a guided interface?

[`gtstats_app()`](https://gtstats.thinkdenominator.com/reference/gtstats_app.md)
is an optional Shiny companion for learners and collaborators who prefer
a menu-driven starting point. It can load a built-in teaching dataset or
a CSV/Excel file, show a working data dictionary, then guide the user
through data description, distribution and spread checks, summary
tables, outbreak and surveillance tables, group comparisons,
correlations, and crosstabs. It can also preserve an already calculated
results data frame as a publication table. Every analysis page displays
the corresponding R code with copy and `.R` download buttons, while
result tables can be downloaded as Word, HTML, PDF, or RTF. The optional
`rio` package enables Excel import.

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

Choose the route from what each row represents:

| Your data | Use | Why |
|----|----|----|
| One row per participant or observation | [`summary_table()`](https://gtstats.thinkdenominator.com/reference/summary_table.md) | Descriptive statistics still need calculating |
| Outbreak line list or surveillance numerator/denominator data | [`epi_table()`](https://gtstats.thinkdenominator.com/reference/epi_table.md) | Events, denominators, rates, or risks still need calculating |
| One row per final result, calculated elsewhere | [`as_stats_table()`](https://gtstats.thinkdenominator.com/reference/as_stats_table.md) | Preserve every supplied value and only format the table |

### 2. Assess distribution for descriptive reporting

``` r

distribution <- assess_distribution(birthwt, vars = c(age, lwt), by = low)
to_flextable(distribution)
```

| Variable | Group | n | Skewness | Shape | Suggested presentation | Shapiro p |
|----|----|----|----|----|----|----|
| Maternal age (years) | Normal birth weight | 130 | 0.74 | Some right asymmetry | Review mean (SD) and median (IQR) | \<0.001 |
|  | Low birth weight | 59 | 0.29 | Little/no asymmetry |  | 0.521 |
| Maternal weight (lb) | Normal birth weight | 130 | 1.42 | Marked right skew | Median (IQR) preferred | \<0.001 |
|  | Low birth weight | 59 | 1.06 | Marked right skew |  | \<0.001 |
| Shape categories use absolute sample skewness: little/no asymmetry \< 0.50; some asymmetry 0.50 to \< 1.00; marked skew \>= 1.00. They are descriptive guidance, not formal classifications. |  |  |  |  |  |  |
| Shapiro-Wilk is sensitive to sample size. Interpretation should consider skewness, graphical assessment, sample size and subject-matter knowledge. |  |  |  |  |  |  |
| Suggested summaries are intended for descriptive reporting only and should not be used alone to determine inferential statistical methods. |  |  |  |  |  |  |
| For grouped data, the suggested presentation applies to all groups of each variable. |  |  |  |  |  |  |

``` r

distribution$recommendations
#> # A tibble: 2 × 5
#>   variable label                overall_recommendation            reason  review
#>   <chr>    <chr>                <chr>                             <chr>   <chr> 
#> 1 age      Maternal age (years) Review mean (SD) and median (IQR) Some a… Inspe…
#> 2 lwt      Maternal weight (lb) Median (IQR) preferred            Marked… Inspe…
```

This function is restricted to continuous numeric variables. It uses
skewness, data quality, and Shapiro-Wilk as supporting information to
guide descriptive presentation. It does not choose an inferential test.

When groups are being compared, inspect their observed spread
separately:

``` r

variance <- assess_variance(birthwt, vars = c(age, lwt), by = low)
to_flextable(variance)
```

| Variable | Normal birth weight | Low birth weight | Observed SD ratio | Observed variance ratio | Levene p | Interpretation |
|----|----|----|----|----|----|----|
| Maternal age (years) | n = 130; SD = 5.58; variance = 31.19 | n = 59; SD = 4.51; variance = 20.35 | 1.24 | 1.53 | 0.102 | Levene found no clear evidence of different spreads; this does not prove equal variances. |
| Maternal weight (lb) | n = 130; SD = 31.72; variance = 1006.41 | n = 59; SD = 26.56; variance = 705.40 | 1.19 | 1.43 | 0.476 | Levene found no clear evidence of different spreads; this does not prove equal variances. |
| SD and variance ratios are the largest group value divided by the smallest group value. They describe observed spread; they are not pass/fail tests. |  |  |  |  |  |  |
| For independent groups, Welch t-tests and Welch ANOVA do not require equal variances. \`assess_variance()\` does not select an inferential test and does not assess pairing or repeated-measures sphericity. |  |  |  |  |  |  |
| The displayed Levene test is median-centred (Brown-Forsythe). It is supporting information only: its p-value neither proves equal variances nor selects an inferential test. |  |  |  |  |  |  |
| Interpret spread alongside sample size, distributional shape, outliers, missingness, and the study design. |  |  |  |  |  |  |

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

to_flextable(table_one)
```

[TABLE]

By default, categorical percentages use non-missing observations. If
Missing is a meaningful reported category that should contribute to the
denominator, choose `missing = "as_category"`. This is different from
merely showing a missingness row with `"ifany"` or `"always"`; see
[Missing data and
denominators](https://gtstats.thinkdenominator.com/articles/missing-data-denominators.md)
before using it.

Add optional rows only when they answer a specific reporting need:

``` r

table_one |>
  add_proportion(var = smoke, level = "Yes", label = "Smoking prevalence", ci = TRUE) |>
  add_total() |>
  to_flextable()
```

[TABLE]

### 4. Compare one variable

``` r

comparison <- compare_groups(birthwt, variable = lwt, group = low)
to_flextable(comparison)
```

[TABLE]

For a transparent audit trail:

``` r

assumptions_stats(comparison)
```

| Checks before reporting |  |  |  |
|----|----|----|----|
| Variable | Check before reporting | Action | Details |
| Maternal weight (lb) | Independent observations | Confirm from study design | Confirm from the study design that each observation contributes independently. |
| Maternal weight (lb) | Comparable distribution shapes | Confirm from study design | Required when interpreting the rank-based result specifically as a location or median shift. |

``` r

diagnostics_stats(comparison)
```

| Diagnostics |  |  |  |  |  |
|----|----|----|----|----|----|
| Variable | Check | Result | Observed value | Reference | Interpretation |
| Maternal weight (lb) | Comparison design | independent | Independent observations | Defined by the study design | Independent comparison; confirm independence from the study design. |
| Maternal weight (lb) | Variance assumption | welch default | var_equal = FALSE | User-specified analytical assumption | Welch is the conservative default and does not require equal variances. No variance hypothesis test was used. |
| Maternal weight (lb) | Automatic test selection | Wilcoxon rank-sum test | Skewed; Skewed | No marked group-level skewness flag for parametric default | Two-group continuous outcome: marked skewness flagged in at least one group; selected Wilcoxon rank-sum test. |
| Maternal weight (lb) | Distribution guidance | rank based recommended | Skewed; Skewed | Marked absolute skewness guidance; Shapiro-Wilk is supporting information only | Assessment applied within each group. |
| Maternal weight (lb) | Observed group spread | descriptive context | Normal birth weight (n = 130): SD 31.72; variance 1006.41; Low birth weight (n = 59): SD 26.56; variance 705.40; SD ratio = 1.19; variance ratio = 1.43 | Descriptive diagnostic; no pass/fail threshold | Observed spread is descriptive only; no Levene, Bartlett, or F test was performed. \`var_equal = FALSE\` retains Welch methods as the conservative parametric auto default. |

``` r

denominators_stats(comparison)
```

| Denominator audit |  |  |  |  |  |  |  |  |
|----|----|----|----|----|----|----|----|----|
| Variable | Level | Group | Eligible observations | Used in analysis | Missing / excluded | Numerator | Denominator | Rule |
| lwt | NA | low = Normal birth weight | 130 | 130 | 0 | NA | 130 | Non-missing outcome observations within group |
| lwt | NA | low = Low birth weight | 59 | 59 | 0 | NA | 59 | Non-missing outcome observations within group |

### 5. Customise and export

``` r

table_one |>
  customise_table(
    title = "Table 1. Vehicle characteristics",
    theme = "journal"
  ) |>
  save_output("table-1.docx")
```

Before reporting any percentage or inference, read [Missing data and
denominators](https://gtstats.thinkdenominator.com/articles/missing-data-denominators.md).
For a full clinical example, continue to the [birth-weight case
study](https://gtstats.thinkdenominator.com/articles/birthweight-case-study.md).
