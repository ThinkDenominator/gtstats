# Inferential Tests and Assumptions

`gtstats` uses conservative, beginner-friendly defaults. Automatic
selection can inspect the data, but it cannot determine whether
observations are independent or whether the design and denominator
answer the intended clinical question. Those decisions remain the
analyst’s responsibility.

## Quantify the magnitude separately

Use
[`effect_size()`](https://gtstats.thinkdenominator.com/reference/effect_size.md)
when the question is how large a difference or association is. Its
default output is deliberately smaller than
[`compare_groups()`](https://gtstats.thinkdenominator.com/reference/compare_groups.md):

``` r

effect_size(mtcars, outcome = mpg, by = am)
```

The automatic measure follows the comparison structure:

- two continuous groups: Hedges’ g, with a confidence interval;
- two-group rank comparison: rank-biserial correlation;
- more than two continuous groups: omega-squared;
- multi-group rank comparison: epsilon-squared;
- categorical association: Cramer’s V.

For a two-group effect, the Contrast column explicitly names the
grouping variable and uses its displayed order: first group minus second
group. Positive and negative standardized or rank effects therefore have
an unambiguous direction. Cramer’s V and omnibus measures describe
association or overall variation and have no direction. Interval method
information is retained in the notes; Hedges’ g intervals are labelled
as approximate large-sample intervals.

An explicit method remains available when the scientific question
requires it:

``` r

effect_size(
  mtcars,
  outcome = mpg,
  by = am,
  method = "rank_biserial"
)
```

Generic magnitude labels are excluded by default. Set
`interpretation = TRUE` only when a conventional teaching label is
useful; the table then states that this is not a threshold for clinical
importance. For risk ratios, odds ratios, and risk differences, use
[`crosstabs()`](https://gtstats.thinkdenominator.com/reference/crosstabs.md)
so that the exposure and event direction remain explicit.

## Default selection policy

`compare_groups(test = "auto")` follows these fixed rules. The selected
test is never hidden: it is printed in the result and recorded with its
rule and inputs in `$method`, `$diagnostics`, and `$notes`.

| Comparison | What auto checks | Test selected |
|----|----|----|
| Continuous, two independent groups | Skewness guidance within each group; `var_equal` | Welch t-test by default; Student’s t-test when `var_equal = TRUE`; Wilcoxon rank-sum if one or more groups are flagged |
| Continuous, three or more independent groups | Skewness guidance within each group; `var_equal` | Welch ANOVA by default; classical ANOVA when `var_equal = TRUE`; Kruskal-Wallis if one or more groups are flagged |
| Continuous, paired | Skewness guidance for within-pair differences | Paired t-test if not flagged; Wilcoxon signed-rank if flagged |
| Ordinal, two groups | Outcome is ordered | Wilcoxon rank-sum |
| Ordinal, three or more groups | Outcome is ordered | Kruskal-Wallis |
| Binary or nominal categorical, independent | Expected cell counts | Pearson chi-square when all expected counts are at least 5; Fisher’s exact otherwise |
| Binary, paired | Paired design and binary outcome | McNemar test |

The continuous-variable rule uses the package skewness guidance, not a
normality-test p-value. Shapiro-Wilk is supporting information only and
does not alone switch the test.
[`add_p()`](https://gtstats.thinkdenominator.com/reference/add_p.md)
uses the same rules.

Other automatic defaults are:

| Question | Default |
|----|----|
| Estimate one proportion | Exact binomial confidence interval |
| Correlate two continuous variables | Pearson for approximately symmetric variables; otherwise Spearman |
| Estimate an event rate | Exact Poisson confidence interval |

## Proportions are estimates, not automatically tests

[`proportion_stats()`](https://gtstats.thinkdenominator.com/reference/proportion_stats.md)
estimates a proportion and Wilson score confidence interval. It does not
test whether groups differ.

``` r

proportion_stats(mtcars, var = vs, by = am)
```

To compare categorical distributions, use
[`compare_groups()`](https://gtstats.thinkdenominator.com/reference/compare_groups.md),
[`add_p()`](https://gtstats.thinkdenominator.com/reference/add_p.md), or
[`crosstabs()`](https://gtstats.thinkdenominator.com/reference/crosstabs.md).

``` r

compare_groups(mtcars, variable = vs, group = am)
crosstabs(mtcars, row = am, col = vs)
```

In automatic mode, expected cell counts are calculated. Fisher’s exact
test is selected if any expected count is below 5; otherwise chi-square
is used. Returned objects expose the expected counts and the minimum
expected count.

The analyst must still confirm:

- observations are independent;
- each observation contributes to one cell;
- categories are mutually exclusive;
- row and column levels have been defined in the intended direction.

For paired binary observations, supply an identifier and use McNemar’s
test:

``` r

compare_groups(
  paired_data,
  variable = status,
  group = period,
  paired = TRUE,
  id = participant_id
)
```

## Continuous outcomes

Welch’s t-test is the two-group parametric default because it does not
require equal variances. Welch ANOVA is the corresponding default for
three or more groups. When equal variances are justified in a
prespecified analysis plan, `var_equal = TRUE` changes the non-skewed
independent automatic route to Student’s t-test or classical ANOVA. It
does not run, infer, or prove an equal-variance hypothesis test.

Use
[`assess_variance()`](https://gtstats.thinkdenominator.com/reference/assess_variance.md)
to make the observed group spread visible before interpreting a
comparison. It reports SDs, variances, and largest/smallest spread
ratios but deliberately does not run a variance-test gatekeeper or
change the automatic choice.

``` r

assess_variance(mtcars, vars = mpg, by = am)
```

The same observed-spread diagnostic is retained in an independent
continuous
[`compare_groups()`](https://gtstats.thinkdenominator.com/reference/compare_groups.md)
result. It is descriptive context, not a test-selection rule: Welch
t-tests and Welch ANOVA do not require equal variances. The value of
`var_equal` is a transparent user choice, not a data-driven variance
test.

``` r

compare_groups(
  mtcars,
  variable = mpg,
  group = am,
  test = "auto"
)

compare_groups(mtcars, variable = mpg, group = cyl)
compare_groups(mtcars, variable = mpg, group = cyl, test = "anova")
```

Distribution guidance primarily uses skewness. Shapiro-Wilk results are
supporting information and are not used alone to select a test. Analysts
should also inspect outliers and plots. To see the exact automatic
decision for one analysis, inspect the saved result:

``` r

result <- compare_groups(mtcars, variable = mpg, group = am)
result$method$selection_rule
result$method$selection_inputs
diagnostics_stats(result)
```

Wilcoxon rank-sum and Kruskal-Wallis tests compare ranks. Interpreting
them specifically as median comparisons requires broadly similar
distribution shapes across groups.

For paired continuous analyses, distribution guidance is applied to the
within-pair differences rather than each measurement occasion
separately.

## Summary-table p-values

[`add_p()`](https://gtstats.thinkdenominator.com/reference/add_p.md)
uses the same automatic selection policy as
[`compare_groups()`](https://gtstats.thinkdenominator.com/reference/compare_groups.md).
Distribution guidance is enabled by default.

``` r

summary_table(mtcars, by = am, overall = TRUE) |>
  add_summary(vars = c(mpg, wt, vs)) |>
  add_p()
```

Tests can be prespecified per variable:

``` r

summary_table(mtcars, by = am) |>
  add_summary(vars = c(mpg, wt, vs)) |>
  add_p(
    method = c(
      mpg = "welch_t",
      wt = "wilcox",
      vs = "fisher"
    ),
    normality_check = FALSE
)
```

To use the equal-variance parametric route deliberately:

``` r

compare_groups(trial_data, change_score, group = arm, var_equal = TRUE)
```

The table footnote records tests used and reminds readers that
independence must be confirmed from the study design.

## Correlation

Automatic correlation selection uses marginal distribution shape, but
this cannot confirm the shape of the relationship. Inspect a
scatterplot:

- Pearson requires an approximately linear relationship.
- Spearman requires a monotonic relationship.

With `method = "auto"`,
[`correlation()`](https://gtstats.thinkdenominator.com/reference/correlation.md)
uses Pearson only when both marginal absolute sample skewness values are
below 1; otherwise it uses Spearman. This is a transparent default, not
proof that the relationship is linear or monotonic. Inspect
[`plot_correlation()`](https://gtstats.thinkdenominator.com/reference/plot_correlation.md)
before reporting the coefficient.
[`diagnostics_stats()`](https://gtstats.thinkdenominator.com/reference/diagnostics_stats.md)
records the two skewness values, selected rule, and the number of
complete finite pairs used. - Both require independent observation pairs
without dominating influential observations.

## Rates

[`rate_stats()`](https://gtstats.thinkdenominator.com/reference/rate_stats.md)
estimates rates with exact Poisson confidence intervals. Confirm that:

- events are valid counts;
- person-time or exposure time is positive and correctly accumulated;
- observations or event processes are suitably independent;
- a Poisson process is a reasonable approximation.

Counts per 100 people at a single time point are proportions, not
incidence rates, unless genuine observation time is represented.

## Inspect what was checked

Inferential objects retain transparent metadata:

``` r

result <- compare_groups(mtcars, variable = vs, group = am)

result$inferential
result$method
result$assumptions
result$diagnostics
result$denominators
result$notes
```

`$inferential` records the selected test and reason. `$method` contains
detected variable types and method metadata. `$assumptions`
distinguishes automatic checks from requirements that must be confirmed
from the study design. `$diagnostics` records check results, values,
thresholds and interpretation. `$denominators` records total,
non-missing and missing observations together with the numerator,
denominator, group and rule used. `$notes` remains a short
human-readable explanation.

Use the inspection helpers for a consistent tibble or formatted table:

``` r

assumptions_stats(result)
diagnostics_stats(result)
denominators_stats(result)

denominators_stats(result, output = "gt")
```

These audit helpers are intentionally separate from the publication
table:

- [`assumptions_stats()`](https://gtstats.thinkdenominator.com/reference/assumptions_stats.md)
  records what the method assumes, including items that require design
  or clinical judgement rather than a software check.
- [`diagnostics_stats()`](https://gtstats.thinkdenominator.com/reference/diagnostics_stats.md)
  shows numerical checks and automatic decisions in plain language; use
  `view = "audit"` for the underlying technical codes.
- [`denominators_stats()`](https://gtstats.thinkdenominator.com/reference/denominators_stats.md)
  shows the analysed observations, missing values, numerators and
  denominators behind reported percentages, rates and risks;
  `view = "audit"` returns the underlying field names.

Use them to review an analysis before reporting it; they are not
normally included in a manuscript table.
