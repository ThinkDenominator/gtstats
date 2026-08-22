# Add p-values to a descriptive table

Add a p-value column to a descriptive table by comparing each displayed
variable across the grouping variable. P-values are calculated using
[`compare_groups()`](https://gtstats.thinkdenominator.com/reference/compare_groups.md)
and inserted once per variable, with optional superscript markers
indicating which statistical test was used.

## Usage

``` r
add_p(
  x,
  method = "auto",
  include = tidyselect::everything(),
  paired = FALSE,
  id = NULL,
  distribution_check = TRUE,
  var_equal = FALSE,
  correction = TRUE,
  fisher_seed = 1049L,
  p_adjust = c("none", setdiff(stats::p.adjust.methods, "none")),
  digits = 3
)
```

## Arguments

- x:

  A `gt_desc_table` object created with
  [`summary_table()`](https://gtstats.thinkdenominator.com/reference/summary_table.md).

- method:

  Statistical test to use. Either a single method string, or a named
  character vector/list specifying methods for individual variables.
  Names may match either displayed variable labels or underlying
  variable names.

- include:

  Variables in the descriptive table for which p-values should be
  calculated. Uses tidy-select syntax and defaults to all summarized
  variables. For example, `include = -bwt` keeps birth weight in the
  descriptive table but omits its p-value when the grouping variable was
  derived from birth weight.

- paired:

  Logical; whether comparisons should be treated as paired.

- id:

  Pair or participant identifier required when `paired = TRUE`.

- distribution_check:

  Logical; when `method = "auto"`, use distribution guidance to choose
  parametric or rank-based tests. This guidance is based on skewness;
  Shapiro-Wilk is supporting information only. For paired analyses the
  check is applied to within-pair differences.

- var_equal:

  Logical; for independent, non-skewed continuous comparisons in
  `method = "auto"`, use Student's t-test or classical ANOVA. The
  default `FALSE` uses Welch methods. This is a user-specified
  assumption, not a variance test, and does not affect paired,
  categorical, ordinal, or rank-based comparisons.

- correction:

  Logical; apply continuity correction to chi-square and McNemar tests
  where applicable.

- fisher_seed:

  Integer seed for simulated Fisher exact tests on tables larger than 2
  x 2. Use `NULL` to use the current random-number state.

- p_adjust:

  Multiplicity adjustment applied across displayed variable tests. One
  of [stats::p.adjust.methods](https://rdrr.io/r/stats/p.adjust.html);
  default `"none"`.

- digits:

  Number of decimal places used when formatting p-values.

## Value

An updated `gt_desc_table` object with a `p-value` column added. When
`paired = TRUE`, `$paired_p_notes` records the complete-pair denominator
for each displayed p-value;
[`tbl_stats()`](https://gtstats.thinkdenominator.com/reference/tbl_stats.md)
displays this as a concise p-value footnote.

## Details

This function works only for descriptive tables created in
`mode = "summary"` and requires a grouping variable supplied via
[`summary_table()`](https://gtstats.thinkdenominator.com/reference/summary_table.md).

Supported methods include:

- `"auto"`

- `"welch_t"`

- `"t_test"`

- `"wilcox"`

- `"anova"`

- `"welch_anova"`

- `"kruskal"`

- `"chisq"`

- `"fisher"`

- `"mcnemar"`

You may also provide a named character vector or named list to specify
different methods for individual variables.

### Automatic selection and audit trail

With `method = "auto"`, `add_p()` delegates each comparison to
[`compare_groups()`](https://gtstats.thinkdenominator.com/reference/compare_groups.md)
using the same fixed selection policy: Welch t-test or Welch ANOVA by
default when distribution guidance does not flag skewness; Student's
t-test or classical ANOVA when `var_equal = TRUE`; rank-based tests when
marked skewness is flagged; and chi-square or Fisher's exact test
according to expected cell counts. For independent ordered factors,
automatic mode uses the same chi-square/Fisher distribution comparison
as other categorical variables; select `"wilcox"` or `"kruskal"`
explicitly when a rank-based ordinal comparison is wanted. Shapiro-Wilk
is supporting information only and does not itself select a test.

The publication table contains only the p-value and compact test
markers. The full per-variable audit trail is retained in
`$assumptions`, `$diagnostics`, `$p_values`, and `$denominators`. In
particular, `diagnostics_stats(x)` records automatic selection,
distribution guidance, expected cell counts where relevant, and observed
group spread for independent continuous comparisons. Observed spread is
descriptive context, not a variance-test gatekeeper; Welch methods do
not require equal variances.

## Examples

``` r
summary_table(mtcars, by = am, include = c(mpg, wt, cyl)) |>
  add_p()

summary_table(mtcars, by = am, include = c(mpg, wt, cyl)) |>
  add_p(method = c(mpg = "welch_t", wt = "wilcox", cyl = "chisq"))

summary_table(mtcars, by = am, include = c(mpg, wt, cyl)) |>
  add_p(include = c(mpg, wt))
```
