# Missing data and denominators

``` r

library(gtstats)
```

## The policy in one minute

gtstats does not silently treat missing values as observations with a
value. Each analysis retains or reports the observations contributing to
its result. The usual default is to use observations with the values
needed for that calculation and make the resulting denominator available
for review.

There is no universal denominator. A categorical percentage needs
observed values of that variable; a correlation needs complete pairs; a
rate needs valid event-time records. The right denominator depends on
the scientific question.

1.  Start with
    [`describe_data()`](https://gtstats.thinkdenominator.com/reference/describe_data.md)
    to see completeness for every variable.
2.  Choose the percentage denominator deliberately for descriptive
    tables.
3.  Use
    [`denominators_stats()`](https://gtstats.thinkdenominator.com/reference/denominators_stats.md)
    before reporting results when exclusions matter.
4.  Describe the analysis population when missing data are material.

## Key terms

| Term | Meaning in gtstats |
|----|----|
| `n_total` | Rows in the relevant dataset or group before the statistic-specific exclusion |
| `n_nonmissing` | Rows with the values required for the variable |
| `n_missing` | Rows excluded because a required value is missing |
| `level` | Categorical level represented by a displayed cell, when relevant |
| `numerator` | Count of events or selected levels, where relevant |
| `denominator` | Eligible observations or total person-time used for the estimate |
| `rule` | Plain-language record of how the denominator was formed |

[`denominators_stats()`](https://gtstats.thinkdenominator.com/reference/denominators_stats.md)
returns a formatted table by default, or a plain console tibble with
`format = "tibble"`. For categorical summaries, it records the level as
well as the group, so row and overall percentages can be checked against
the exact denominator used in the displayed cell.

## Start by describing missingness

[`describe_data()`](https://gtstats.thinkdenominator.com/reference/describe_data.md)
reports completeness from all rows in the supplied dataset; it never
drops rows to make the overview look complete.

``` r

dat <- data.frame(
  arm = factor(c("Control", "Control", "Treatment", "Treatment", "Treatment")),
  age = c(45, NA, 51, 62, 57),
  smoker = factor(c("No", "Yes", NA, "Yes", "No")),
  follow_up = c(12, 10, 8, NA, 11)
)

to_flextable(describe_data(dat))
```

| Variable | Type | Complete | Unique | Overview | Range / levels |
|----|----|----|----|----|----|
| arm | binary | 5/5 (100.0%) | 2 | Treatment 3 (60.0%); Control 2 (40.0%) | Control, Treatment |
| age | categorical | 4/5 (80.0%) | 4 | 45 1 (25.0%); 51 1 (25.0%); 57 1 (25.0%) | 45, 51, 62, 57 |
| smoker | binary | 4/5 (80.0%) | 2 | No 2 (50.0%); Yes 2 (50.0%) | No, Yes |
| follow_up | categorical | 4/5 (80.0%) | 4 | 10 1 (25.0%); 11 1 (25.0%); 12 1 (25.0%) | 12, 10, 8, 11 |
| One row is shown per selected variable. |  |  |  |  |  |
| Potential data-quality findings and interpretation prompts are stored in \`\$issues\`. |  |  |  |  |  |
| Ordered factors are identified as ordinal variables. |  |  |  |  |  |

This reports the amount of missing data, not its cause. Clinical
context, the data dictionary, and the study design are needed to decide
whether a complete-case analysis is scientifically appropriate.

## Descriptive tables: percentage denominators

For categorical variables,
[`summary_table()`](https://gtstats.thinkdenominator.com/reference/summary_table.md)
makes the denominator explicit. The default is `percent = "column"`.

| Setting | Percentage denominator | Typical use |
|----|----|----|
| `"column"` | Non-missing observations in each displayed group | Standard Table 1 |
| `"row"` | Non-missing observations for that level across groups | Distribution of a category across groups |
| `"overall"` | All non-missing observations of the variable | Share of the overall sample |
| `categorical = "n"` | No percentage | Counts only |

``` r

summary_table(
  dat,
  by = arm,
  include = smoker,
  percent = "column",
  missing = "ifany"
) |> to_flextable()
```

[TABLE]

``` r


to_flextable(summary_table(dat, by = arm, include = smoker, percent = "row"))
```

[TABLE]

``` r

to_flextable(summary_table(dat, by = arm, include = smoker, percent = "overall"))
```

[TABLE]

``` r

to_flextable(summary_table(dat, by = arm, include = smoker, categorical = "n"))
```

[TABLE]

`missing = "ifany"` displays a Missing row only when it is needed. Use
`"always"` to show zero-missing rows or `"no"` to suppress them. These
three settings calculate observed-category percentages from non-missing
values; suppressing the row does not change that denominator.

Use `missing = "as_category"` when missing values should form part of
the displayed categorical distribution. The Missing row is then included
in the percentage denominator, so the observed categories plus Missing
sum to 100%.

``` r

catheter_data <- data.frame(
  catheter = factor(
    c(rep("Yes", 32), rep(NA_character_, 68)),
    levels = c("No", "Yes")
  )
)

summary_table(
  catheter_data,
  include = catheter,
  missing = "as_category"
) |> to_flextable()
```

[TABLE]

This reports 32/100 (32%) as documented Yes and 68/100 (68%) as Missing.
It does not assume that missing records are No. For continuous
variables, missing values cannot become a numeric category and therefore
remain a separate missingness row.

Continuous summaries use observed finite values of that variable. A
displayed Missing row is calculated against all rows in the relevant
group.

Use `categorical = "n_over_N_percent"` when the table should show the
non-missing denominator inside every cell, for example `30/59 (50.8%)`.
For a continuous descriptive estimate with precision but no p-value, use
`statistic = "mean_ci"`; this reports a t confidence interval for the
observed mean using `conf.level`.

## Proportions and confidence intervals

[`proportion_stats()`](https://gtstats.thinkdenominator.com/reference/proportion_stats.md)
and
[`add_proportion()`](https://gtstats.thinkdenominator.com/reference/add_proportion.md)
use non-missing observations of the selected variable as the
denominator. The numerator is the chosen level, and the confidence
interval describes that observed-data proportion.

``` r

smoking <- proportion_stats(dat, smoker, by = arm, level = "Yes")
to_flextable(smoking)
```

|  | Control |  | Treatment |  |
|----|----|----|----|----|
| Event | n (%) | 95% CI | n (%) | 95% CI |
| Yes | 1 (50.0%) | 9.5–90.5% | 1 (50.0%) | 9.5–90.5% |
| Selected event: smoker = Yes. Estimates use Wilson score 95% confidence intervals. |  |  |  |  |
| This function estimates a proportion; it does not test differences between groups. |  |  |  |  |
| The denominator must define the population at risk, and observations should be independent. |  |  |  |  |

``` r

denominators_stats(smoking)
```

| Denominator audit |  |  |  |  |  |  |  |  |
|----|----|----|----|----|----|----|----|----|
| Variable | Level | Group | Eligible observations | Used in analysis | Missing / excluded | Numerator | Denominator | Rule |
| smoker | NA | arm = Control | 2 | 2 | 0 | NA | 2 | Non-missing observations; event level = Yes |
| smoker | NA | arm = Treatment | 3 | 2 | 1 | NA | 2 | Non-missing observations; event level = Yes |

If unknown status should be included in a categorical descriptive
distribution, use `missing = "as_category"`. Do not assume that an
unknown value is a non-event; recode it to No only when that meaning is
justified by the data definition.

An all-missing categorical variable remains visible in
[`summary_table()`](https://gtstats.thinkdenominator.com/reference/summary_table.md)
as an em dash, with a Missing row by default. It is not silently dropped
from the table.

## Rates use complete event-time records

[`rate_stats()`](https://gtstats.thinkdenominator.com/reference/rate_stats.md)
and
[`add_rate()`](https://gtstats.thinkdenominator.com/reference/add_rate.md)
require finite, non-negative event counts and person-time values. Rows
missing either value are excluded. The denominator is the sum of valid
person-time, not the number of patients. A group with zero accumulated
time is retained but its rate is reported as not estimable.

``` r

rate_dat <- data.frame(
  arm = c("Control", "Control", "Treatment", "Treatment"),
  events = c(1, 0, 2, 1),
  person_years = c(1.2, NA, 0.8, 1.0)
)

rate <- rate_stats(rate_dat, event = events, time = person_years, by = arm)
denominators_stats(rate)
```

| Denominator audit |  |  |  |  |  |  |  |  |
|----|----|----|----|----|----|----|----|----|
| Variable | Level | Group | Eligible observations | Used in analysis | Missing / excluded | Numerator | Denominator | Rule |
| events | NA | Control | 2 | 1 | 1 | 1 | 1.2 | Accumulated person-time; rate per 1000 |
| events | NA | Treatment | 2 | 2 | 0 | 3 | 1.8 | Accumulated person-time; rate per 1000 |

The audit records both valid event-time records and the person-time
denominator.

## Cross-tabs, comparisons, and correlations

[`crosstabs()`](https://gtstats.thinkdenominator.com/reference/crosstabs.md)
uses complete row-column pairs: a row is excluded when either
cross-tabulated variable is missing. Its margins, percentages, test, and
2×2 measures therefore refer to that same complete-pair population.

``` r

cross <- crosstabs(dat, row = arm, col = smoker)
denominators_stats(cross)
```

| Denominator audit |  |  |  |  |  |  |  |  |
|----|----|----|----|----|----|----|----|----|
| Variable | Level | Group | Eligible observations | Used in analysis | Missing / excluded | Numerator | Denominator | Rule |
| smoker | Yes | Treatment | 3 | 2 | 1 | 1 | 2 | Complete row/outcome observations; event level = Yes |
| smoker | Yes | Control | 2 | 2 | 0 | 1 | 2 | Complete row/outcome observations; event level = Yes |

For independent
[`compare_groups()`](https://gtstats.thinkdenominator.com/reference/compare_groups.md),
an observation requires both `variable` and `group`. For paired
analysis, an identifier must be observed once in each group with the
required outcome; the denominator becomes the number of complete,
aligned pairs.

``` r

comparison <- compare_groups(dat, variable = age, group = arm)
denominators_stats(comparison)
```

| Denominator audit |  |  |  |  |  |  |  |  |
|----|----|----|----|----|----|----|----|----|
| Variable | Level | Group | Eligible observations | Used in analysis | Missing / excluded | Numerator | Denominator | Rule |
| age | NA | arm = Control | 2 | 1 | 1 | NA | 1 | Non-missing outcome observations within group |
| age | NA | arm = Treatment | 3 | 3 | 0 | NA | 3 | Non-missing outcome observations within group |

[`correlation()`](https://gtstats.thinkdenominator.com/reference/correlation.md)
similarly uses complete pairs: both variables must be observed in the
same row.

``` r

cor_dat <- data.frame(
  age = c(34, 41, 45, 49, 53, 57, 62, 68),
  follow_up = c(12, 11, NA, 9, 8, 7, 6, 5)
)
to_flextable(correlation(cor_dat, x = age, y = follow_up))
```

| Variables | n | Correlation (95% CI) | p-value |
|----|----|----|----|
| age and follow_up | 7 | -1.00 (-1.00 to -0.98) | \<0.01 |
| Pearson when both absolute sample skewness values are below 1; otherwise Spearman in auto mode. |  |  |  |
| Inspect a scatterplot: Pearson requires an approximately linear relationship; Spearman requires a monotonic relationship. |  |  |  |
| Correlation inference assumes independent observation pairs and no dominating influential observations. |  |  |  |
| Analysis used 7 complete finite pairs; 1 pairs were excluded. |  |  |  |

## Distribution assessment

[`assess_distribution()`](https://gtstats.thinkdenominator.com/reference/assess_distribution.md)
keeps data-quality information visible. It reports `n`, `Missing`, and
`Non-finite`; skewness and Shapiro-Wilk use usable finite values only.
Missing or non-finite values are flagged in the guidance rather than
being interpreted as evidence of non-normality.

``` r

dist_dat <- data.frame(
  arm = factor(rep(c("Control", "Treatment"), each = 8)),
  age = c(34, 39, 44, 48, 52, 57, NA, 63,
          36, 41, 46, 51, 56, 61, 66, Inf)
)
to_flextable(assess_distribution(dist_dat, vars = age, by = arm))
```

| Variable | Group | n | Missing | Non-finite | Skewness | Shape | Suggested presentation | Shapiro p |
|----|----|----|----|----|----|----|----|----|
| age | Control | 7 | 1 | 0 | 0.05 | Little/no asymmetry | Mean (SD) reasonable | 0.990 |
|  | Treatment | 7 | 0 | 1 | 0.00 | Little/no asymmetry |  | 0.949 |
| Shape categories use absolute sample skewness: little/no asymmetry \< 0.50; some asymmetry 0.50 to \< 1.00; marked skew \>= 1.00. They are descriptive guidance, not formal classifications. |  |  |  |  |  |  |  |  |
| Shapiro-Wilk is sensitive to sample size. Interpretation should consider skewness, graphical assessment, sample size and subject-matter knowledge. |  |  |  |  |  |  |  |  |
| Suggested summaries are intended for descriptive reporting only and should not be used alone to determine inferential statistical methods. |  |  |  |  |  |  |  |  |
| For grouped data, the suggested presentation applies to all groups of each variable. |  |  |  |  |  |  |  |  |

For a grouped continuous variable,
[`assess_variance()`](https://gtstats.thinkdenominator.com/reference/assess_variance.md)
also excludes missing and non-finite values from its SD and variance
calculations, while retaining their counts in the output.

``` r

to_flextable(assess_variance(dist_dat, vars = age, by = arm))
```

| Variable | Control | Treatment | Observed SD ratio | Observed variance ratio | Levene p | Interpretation |
|----|----|----|----|----|----|----|
| age | n = 7; SD = 10.12; variance = 102.48 (1 excluded) | n = 7; SD = 10.80; variance = 116.67 (1 excluded) | 1.07 | 1.14 | 0.814 | Descriptive spread shown; interpret it in the context of the study design. Missing or non-finite values are excluded from SD and variance. Some values were excluded. |
| SD and variance ratios are the largest group value divided by the smallest group value. They describe observed spread; they are not pass/fail tests. |  |  |  |  |  |  |
| For independent groups, Welch t-tests and Welch ANOVA do not require equal variances. \`assess_variance()\` does not select an inferential test and does not assess pairing or repeated-measures sphericity. |  |  |  |  |  |  |
| The displayed Levene test is median-centred (Brown-Forsythe). It is supporting information only: its p-value neither proves equal variances nor selects an inferential test. |  |  |  |  |  |  |
| Interpret spread alongside sample size, distributional shape, outliers, missingness, and the study design. |  |  |  |  |  |  |

## Reporting checklist

- Does the displayed percentage use the denominator that answers the
  question?
- Are missing values shown, suppressed, or described elsewhere?
- Is the analysis population the same for every variable? If not, is
  this clear?
- For rates, is the denominator person-time rather than participants?
- For paired analysis, have you reported the number of complete pairs?
- For repeated-measures ANOVA, have you reviewed sphericity rather than
  using a cross-occasion variance test as a substitute?
- Have you reviewed
  [`denominators_stats()`](https://gtstats.thinkdenominator.com/reference/denominators_stats.md)
  where exclusions affect interpretation?

## What gtstats does not do automatically

gtstats reports the observed-data calculation. It does not impute
missing values, diagnose the missing-data mechanism, apply weighting, or
decide whether complete-case analysis is scientifically valid. Prepare
the appropriate analysis dataset first when those methods are required,
then use gtstats to report the result transparently.
