# Epidemiology Helpers

``` r

library(gtstats)
```

## Overview

gtstats provides one table workflow plus three focused epidemiology
helpers:

| Function | Purpose |
|----|----|
| [`epi_table()`](https://gtstats.thinkdenominator.com/reference/epi_table.md) | Multi-outcome outbreak and surveillance tables from line-list or aggregate data |
| [`proportion_stats()`](https://gtstats.thinkdenominator.com/reference/proportion_stats.md) | Proportions with Wilson or exact confidence intervals |
| [`rate_stats()`](https://gtstats.thinkdenominator.com/reference/rate_stats.md) | Event rates with exact Poisson confidence intervals |
| [`crosstabs()`](https://gtstats.thinkdenominator.com/reference/crosstabs.md) | Publication-ready categorical cross-tabs; 2×2 tables also give RR, OR and RD |

All functions follow the same pattern: pass in your data frame, name the
relevant variables, and optionally supply a grouping variable with
`by =`. They print as flextables by default; call
[`to_gt()`](https://gtstats.thinkdenominator.com/reference/to_gt.md) for
an explicit gt table.

------------------------------------------------------------------------

## epi_table() — Outbreak and surveillance reporting

[`epi_table()`](https://gtstats.thinkdenominator.com/reference/epi_table.md)
is the table-level workflow. It is the appropriate choice when several
outcomes or strata must be reported together and the numerator,
denominator and uncertainty must remain visible. It does not replace
[`summary_table()`](https://gtstats.thinkdenominator.com/reference/summary_table.md):
the latter describes participant characteristics, whereas
[`epi_table()`](https://gtstats.thinkdenominator.com/reference/epi_table.md)
estimates occurrence.

### Individual line-list data

``` r

data("birthwt", package = "gtstats")
epi_line <- epi_table(
  birthwt,
  outcomes = low,
  by = smoke,
  event = "Low birth weight",
  measure = "prevalence",
  p_value = TRUE,
  effects = "all"
)
to_flextable(epi_line)
```

[TABLE]

For each outcome, the denominator is the number of non-missing records
in the relevant group. A case-only line list therefore cannot estimate
an attack rate; use aggregate data with an external population
denominator.

### Aggregate surveillance data

``` r

surveillance <- data.frame(
  ward = c("A", "B", "C"),
  cases = c(12, 7, 4),
  population = c(80, 65, 52)
)
epi_aggregate <- epi_table(
  surveillance,
  numerator = cases,
  denominator = population,
  by = ward,
  label = "Influenza",
  measure = "attack_rate",
  multiplier = 100
)
to_flextable(epi_aggregate)
```

|  | A |  |  |  | B |  |  |  | C |  |  |  |
|----|----|----|----|----|----|----|----|----|----|----|----|----|
| Outcome | Cases | Denominator | Attack rate (%) | 95% CI | Cases | Denominator | Attack rate (%) | 95% CI | Cases | Denominator | Attack rate (%) | 95% CI |
| Influenza | 12 | 80 | 15.0 | 8.8–24.4 | 7 | 65 | 10.8 | 5.3–20.6 | 4 | 52 | 7.7 | 3.0–18.2 |
| 95% CI is a wilson binomial interval. |  |  |  |  |  |  |  |  |  |  |  |  |

For incidence rates, the denominator is accumulated person-time and the
interval is exact Poisson. Optional p-values compare groups. Effect
estimates are available only for exactly two groups, because their
direction must be unambiguous. Inspect `$denominators`, `$p_values` and
`$effects` before reporting.

------------------------------------------------------------------------

## proportion_stats() — Proportions

[`proportion_stats()`](https://gtstats.thinkdenominator.com/reference/proportion_stats.md)
calculates the proportion of a selected level together with a Wilson
score confidence interval by default. Exact binomial intervals remain
available with `ci_method = "exact"`.

Its publication table keeps the event count and percentage together as
`n (%)` and places the confidence interval in a separate column. When
`by` is used, each group becomes a spanning header above these two
columns. The tidy long-form numerical results remain available from
`$summary`.

``` r

# Overall proportion
to_flextable(proportion_stats(mtcars, var = vs))
```

| Event | n (%) | 95% CI |
|----|----|----|
| 1 | 14 (43.8%) | 28.2–60.7% |
| Selected event: vs = 1. Estimates use Wilson score 95% confidence intervals. |  |  |
| This function estimates a proportion; it does not test differences between groups. |  |  |
| The denominator must define the population at risk, and observations should be independent. |  |  |

``` r

# Grouped by transmission type
to_flextable(proportion_stats(mtcars, var = vs, by = am))
```

|  | 1 |  | 0 |  |
|----|----|----|----|----|
| Event | n (%) | 95% CI | n (%) | 95% CI |
| 1 | 7 (53.8%) | 29.1–76.8% | 7 (36.8%) | 19.1–59.0% |
| Selected event: vs = 1. Estimates use Wilson score 95% confidence intervals. |  |  |  |  |
| This function estimates a proportion; it does not test differences between groups. |  |  |  |  |
| The denominator must define the population at risk, and observations should be independent. |  |  |  |  |

``` r

# Pin to a specific level
to_flextable(proportion_stats(mtcars, var = vs, by = am, level = "1"))
```

|  | 1 |  | 0 |  |
|----|----|----|----|----|
| Event | n (%) | 95% CI | n (%) | 95% CI |
| 1 | 7 (53.8%) | 29.1–76.8% | 7 (36.8%) | 19.1–59.0% |
| Selected event: vs = 1. Estimates use Wilson score 95% confidence intervals. |  |  |  |  |
| This function estimates a proportion; it does not test differences between groups. |  |  |  |  |
| The denominator must define the population at risk, and observations should be independent. |  |  |  |  |

``` r

to_gt(proportion_stats(mtcars, var = vs, by = am))
```

[TABLE]

### In a descriptive table

[`add_proportion()`](https://gtstats.thinkdenominator.com/reference/add_proportion.md)
embeds the same calculation inside the table builder:

``` r

summary_table(mtcars, by = am, overall = TRUE) |>
  add_proportion(var = vs, level = "1", ci = TRUE) |>
  add_total() |>
  to_gt()
```

[TABLE]

------------------------------------------------------------------------

## rate_stats() — Event rates

[`rate_stats()`](https://gtstats.thinkdenominator.com/reference/rate_stats.md)
divides the total number of events by the total person-time and
multiplies by a chosen denominator (e.g. 1 000 person-years). Confidence
intervals are calculated using the exact Poisson method.

The publication table places each group above four separate columns:
events, accumulated person-time, rate and confidence interval. This
keeps the numerator, denominator and uncertainty visible without
repeating interval labels inside every rate cell. Record counts and all
numerical values remain in `$summary`.

``` r

df <- data.frame(
  event = c(1, 0, 1, 0, 1, 1),
  ptime = c(10, 12, 8, 9, 11, 7),
  arm   = c("A", "A", "A", "B", "B", "B")
)
```

``` r

# Overall rate
to_flextable(rate_stats(df, event = event, time = ptime))
```

| Event | Events | Person-time | Rate per 1,000 | 95% CI |
|----|----|----|----|----|
| event | 4 | 57 | 70.2 | 19.1–179.7 |
| Rates are shown per 1000 person-time using complete event-time pairs and 95% exact Poisson confidence intervals. |  |  |  |  |
| Confirm that the denominator represents positive person-time or exposure time. |  |  |  |  |
| Exact Poisson intervals assume independent event counts arising from a Poisson process. |  |  |  |  |

``` r

# Grouped by study arm
to_flextable(rate_stats(df, event = event, time = ptime, by = arm))
```

|  | A |  |  |  | B |  |  |  |
|----|----|----|----|----|----|----|----|----|
| Event | Events | Person-time | Rate per 1,000 | 95% CI | Events | Person-time | Rate per 1,000 | 95% CI |
| event | 2 | 30 | 66.7 | 8.1–240.8 | 2 | 27 | 74.1 | 9.0–267.6 |
| Rates are shown per 1000 person-time using complete event-time pairs and 95% exact Poisson confidence intervals. |  |  |  |  |  |  |  |  |
| Confirm that the denominator represents positive person-time or exposure time. |  |  |  |  |  |  |  |  |
| Exact Poisson intervals assume independent event counts arising from a Poisson process. |  |  |  |  |  |  |  |  |

``` r

rate_stats(df, event = event, time = ptime, by = arm) |>
  to_gt()
```

[TABLE]

### In a descriptive table

[`add_rate()`](https://gtstats.thinkdenominator.com/reference/add_rate.md)
embeds rate rows in the table builder:

``` r

summary_table(mtcars, by = am, overall = TRUE) |>
  add_rate(
    event      = carb,
    time       = cyl,
    label      = "Carburettor rate (per 1 000)",
    multiplier = 1000
  ) |>
  to_gt()
```

[TABLE]

------------------------------------------------------------------------

## crosstabs() — categorical tables and 2×2 epidemiology

[`crosstabs()`](https://gtstats.thinkdenominator.com/reference/crosstabs.md)
takes any two categorical variables. When both are binary, `row` defines
the exposure/reference axis and `col` the outcome/event axis, so risks
and ratios retain an explicit direction. The 2×2 output additionally
calculates:

- Risk in the exposed and unexposed groups, with Wilson 95% CIs
- Risk ratio (RR) with 95% CI
- Risk difference with a Newcombe hybrid-score CI
- An automatically selected association test: Fisher’s exact test when
  expected counts are sparse, otherwise the chi-squared test

It also supports any categorical table size. By default cells show `n`
and column percentages, with row/column/grand totals. Use
`percent = "row"` for within-row outcome frequencies, or
`percent = c("row", "column")` when both denominators are useful in an
exploratory or supplementary table.

``` r

to_flextable(crosstabs(mtcars, row = cyl, col = am))
```

[TABLE]

``` r

to_flextable(crosstabs(mtcars, row = cyl, col = gear, percent = c("row", "column")))
```

[TABLE]

For tables larger than 2×2, the footer reports the association test and
Cramér’s V. Risk ratio, odds ratio, and risk difference are
intentionally only available for a binary 2×2 contrast.

The odds ratio is available when it is the effect measure the study
needs, but is deliberately not part of the routine default.

``` r

to_flextable(crosstabs(mtcars, row = am, col = vs))
```

[TABLE]

``` r

to_gt(crosstabs(mtcars, row = am, col = vs))
```

[TABLE]

Choose the direction explicitly when the coding or factor order does not
express the scientific question:

``` r

to_flextable(crosstabs(
  mtcars,
  row = am,
  col = vs,
  row_level = 1,
  col_level = 1
))
```

[TABLE]

Whether levels are supplied or selected automatically, inspect
`result$inputs$row_level` and `result$inputs$col_level` before reporting
a 2×2 measure. The audit retains the selected exposure/event direction,
expected-count rule, zero-cell strategy, and complete-pair denominators
while the publication table stays concise.

For a case-control analysis, request the odds ratio. The association
test can also be omitted when the table is intended to report effects
and confidence intervals only:

``` r

to_flextable(crosstabs(
  mtcars,
  row = am,
  col = vs,
  measures = "or",
  test = "none"
))
```

[TABLE]

When a cell is zero, log-scale ratio intervals use the Haldane–Anscombe
correction by default. The strategy is explicit and configurable:

``` r

to_flextable(crosstabs(
  mtcars,
  row = am,
  col = vs,
  zero_correction = "none"
))
```

[TABLE]

Without correction, an infinite or zero ratio may be reported and its
log-scale confidence interval may be unavailable.

------------------------------------------------------------------------

## Tips

- Use `risk_ci = "exact"` when an exact binomial interval is required by
  the reporting convention; Wilson is the routine default.
- `test = "auto"` checks expected counts and chooses Fisher’s exact test
  for a sparse table.
- [`proportion_stats()`](https://gtstats.thinkdenominator.com/reference/proportion_stats.md),
  [`rate_stats()`](https://gtstats.thinkdenominator.com/reference/rate_stats.md),
  and
  [`crosstabs()`](https://gtstats.thinkdenominator.com/reference/crosstabs.md)
  all return structured objects that print as flextables, can be
  rendered with
  [`to_gt()`](https://gtstats.thinkdenominator.com/reference/to_gt.md),
  or can be inspected as plain lists.
- Inside a descriptive table, use
  [`add_proportion()`](https://gtstats.thinkdenominator.com/reference/add_proportion.md)
  and
  [`add_rate()`](https://gtstats.thinkdenominator.com/reference/add_rate.md)
  rather than standalone helpers to keep everything in one table.
