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

describe_data(dat)
```

This reports the amount of missing data, not its cause. Clinical
context, the data dictionary, and the study design are needed to decide
whether a complete-case analysis is scientifically appropriate.

## Descriptive tables: percentage denominators

For categorical variables,
[`summary_table()`](https://gtstats.thinkdenominator.com/reference/summary_table.md)
and
[`add_summary()`](https://gtstats.thinkdenominator.com/reference/add_summary.md)
make the denominator explicit. The default is `percent = "column"`.

| Setting | Percentage denominator | Typical use |
|----|----|----|
| `"column"` | Non-missing observations in each displayed group | Standard Table 1 |
| `"row"` | Non-missing observations for that level across groups | Distribution of a category across groups |
| `"overall"` | All non-missing observations of the variable | Share of the overall sample |
| `"none"` | No percentage | Counts only |

``` r

summary_table(
  dat,
  by = arm,
  include = smoker,
  percent = "column",
  missing = "ifany"
)

summary_table(dat, by = arm, include = smoker, percent = "row")
summary_table(dat, by = arm, include = smoker, percent = "overall")
summary_table(dat, by = arm, include = smoker, percent = "none")
```

`missing = "ifany"` displays a Missing row only when it is needed. Use
`"always"` to show zero-missing rows or `"no"` to suppress them.
Suppressing a row does not put missing values back into a categorical
denominator.

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
smoking
denominators_stats(smoking)
```

If unknown status should be included in the clinical denominator, do not
assume the observed-data proportion answers that question. Report
unknown values or define the required analysis approach in advance.

An all-missing categorical variable remains visible in
[`add_summary()`](https://gtstats.thinkdenominator.com/reference/add_summary.md)
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

[`correlation()`](https://gtstats.thinkdenominator.com/reference/correlation.md)
similarly uses complete pairs: both variables must be observed in the
same row.

``` r

correlation(dat, x = age, y = follow_up)
```

## Distribution assessment

[`assess_distribution()`](https://gtstats.thinkdenominator.com/reference/assess_distribution.md)
keeps data-quality information visible. It reports `n`, `Missing`, and
`Non-finite`; skewness and Shapiro-Wilk use usable finite values only.
Missing or non-finite values are flagged in the guidance rather than
being interpreted as evidence of non-normality.

``` r

assess_distribution(dat, vars = age, by = arm)
```

For a grouped continuous variable,
[`assess_variance()`](https://gtstats.thinkdenominator.com/reference/assess_variance.md)
also excludes missing and non-finite values from its SD and variance
calculations, while retaining their counts in the output.

``` r

assess_variance(dat, vars = age, by = arm)
```

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
