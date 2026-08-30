# Assess variation of continuous variables across groups

Describe the spread of continuous numeric variables within groups. This
is a diagnostic companion to
[`assess_distribution()`](https://gtstats.thinkdenominator.com/reference/assess_distribution.md)
and is intended to make variation visible before a group comparison is
interpreted.

## Usage

``` r
assess_variance(
  data,
  vars = NULL,
  by,
  digits = 2,
  test = c("levene", "none", "bartlett"),
  format = c("table", "tibble")
)
```

## Arguments

- data:

  A data frame.

- vars:

  Continuous numeric variables to assess. Bare names or a character
  vector are accepted. When omitted, all detected continuous variables
  are assessed. Categorical, ordinal, logical, date-time, and binary
  variables are rejected when explicitly selected.

- by:

  Grouping variable, supplied as a bare name or character string. It
  must be categorical, binary, logical, or ordinal and contain at least
  two observed groups.

- digits:

  Number of decimal places.

- test:

  Variance hypothesis test to display: `"levene"` (default), `"none"`,
  or `"bartlett"`. Levene's test is median-centred (the robust
  Brown-Forsythe form). Both are supporting diagnostics, not gatekeepers
  for ANOVA or Welch methods.

- format:

  Output format: `"table"` (default) or `"tibble"`.

## Value

With `format = "table"`, a `gt_variance` object that prints as one
readable row per variable: each group's `n` and SD, the observed SD
ratio, the requested test p-value, and a plain-language interpretation.
`$summary` contains the full group-level values and `$diagnostics`
retains technical test metadata. With `format = "tibble"`, the detailed
summary tibble is returned.

## Details

`assess_variance()` reports group sample sizes, standard deviations,
variances, and the ratio of the largest to the smallest group SD and
variance. These ratios are descriptive diagnostics, not pass/fail tests.
The function deliberately does not run a variance hypothesis test by
default, and it does not choose an inferential test. Welch t-tests and
Welch ANOVA do not require equal variances for *independent* groups;
this function does not assess pairing, repeated-measures sphericity, or
select a repeated-measures method. The default is the median-centred
Levene test (often called the Brown-Forsythe modification) as supporting
information. It is less sensitive to non-normality than Bartlett's test.
Set `test = "none"` for descriptive spread only, or `test = "bartlett"`
when the normal-distribution assumption is justified. Neither test is
used to select a test in
[`compare_groups()`](https://gtstats.thinkdenominator.com/reference/compare_groups.md).

## Examples

``` r
assess_variance(mtcars, vars = c(mpg, wt), by = am)
assess_variance(mtcars, vars = "mpg", by = am, digits = 1)
assess_variance(mtcars, vars = "mpg", by = am, test = "bartlett")
assess_variance(mtcars, vars = "mpg", by = am, test = "levene")
```
