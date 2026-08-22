# Compare groups using common inferential tests

Compare a variable across groups using a practical set of common
inferential tests.

## Usage

``` r
compare_groups(
  data,
  variable,
  group,
  paired = FALSE,
  id = NULL,
  test = c("auto", "t_test", "welch_t", "wilcox", "anova", "welch_anova", "kruskal",
    "chisq", "fisher", "mcnemar", "rm_anova", "friedman", "cochran_q"),
  effect_size = FALSE,
  conf.level = 0.95,
  digits = 2,
  var_equal = FALSE,
  fisher_seed = 1049L,
  format = c("table", "tibble"),
  ...
)
```

## Arguments

- data:

  A data.frame.

- variable:

  Variable to compare. Can be supplied as a bare name or as a character
  string.

- group:

  Grouping variable. Can be supplied as a bare name or as a character
  string.

- paired:

  Logical; whether the comparison is paired. If `TRUE`, paired t-test,
  Wilcoxon signed-rank test, or McNemar test will be used where
  appropriate.

- id:

  Pair or participant identifier required when `paired = TRUE`. Each
  identifier must occur at most once in each group.

- test:

  Test to use. One of `"auto"`, `"t_test"`, `"welch_t"`, `"wilcox"`,
  `"anova"`, `"welch_anova"`, `"kruskal"`, `"chisq"`, `"fisher"`,
  `"mcnemar"`, `"rm_anova"`, `"friedman"`, or `"cochran_q"`. See
  **Automatic selection policy** for the exact rules used by `"auto"`.

- effect_size:

  Logical; calculate and display the effect size selected for the
  comparison structure. Default is `FALSE`.

- conf.level:

  Confidence level for intervals.

- digits:

  Number of decimal places for formatting.

- var_equal:

  Logical; for independent, non-skewed continuous outcomes with
  `test = "auto"`, use equal-variance Student's t-test (two groups) or
  classical one-way ANOVA (three or more groups). The default `FALSE`
  uses Welch methods. This is a prespecified user choice and is not
  tested or inferred from the observed variances. It does not affect
  paired, categorical, ordinal, or rank-based comparisons.

- fisher_seed:

  Integer seed used only for simulated Fisher exact tests on tables
  larger than 2 x 2. The default makes results reproducible. Set to
  `NULL` to use the current random-number state.

- format:

  Output format: `"table"` (default) or a plain console `"tibble"`.

- ...:

  Reserved for internal package use.

## Value

A `gt_compare` object containing:

- `inputs` — function inputs and settings

- `descriptives` — descriptive summaries by group

- `inferential` — inferential test results

- `table` — display-ready results table

- `method` — metadata on detected variable types

- `notes` — explanatory notes

- `call` — matched function call

For paired or repeated analyses, only complete, uniquely matched
identifiers are analysed. The number retained and excluded is available
in `$denominators` and `$notes`; rendered tables also identify the
complete-pair denominator. Friedman and Cochran's Q require
within-participant variation and fail clearly when it is absent.

## Details

This function is designed for beginner-friendly and teaching-focused
workflows. It combines:

- descriptive summaries by group

- automatic or user-specified test selection

- effect size calculation where supported

- a simple display-ready results table

Supported outcome types are:

- continuous

- binary

- categorical

- ordinal

Supported tests include:

- `"auto"`

- `"t_test"`

- `"welch_t"`

- `"wilcox"`

- `"anova"`

- `"welch_anova"`

- `"kruskal"`

- `"chisq"`

- `"fisher"`

- `"mcnemar"`

- `"rm_anova"`

- `"friedman"`

- `"cochran_q"`

### Automatic selection policy

`test = "auto"` uses the following fixed, data-driven rules. These rules
are intended as transparent defaults, not a substitute for a
prespecified analysis plan.

- **Continuous outcome, two independent groups:** Welch t-test by
  default, or Student's t-test when `var_equal = TRUE`, unless marked
  skewness is flagged in either group, then Wilcoxon rank-sum test.

- **Continuous outcome, three or more independent groups:** Welch ANOVA
  by default, or classical one-way ANOVA when `var_equal = TRUE`, unless
  marked skewness is flagged in any group, then Kruskal-Wallis test.

- **Paired continuous outcome:** for two occasions, paired t-test unless
  marked skewness in within-pair differences is flagged, then Wilcoxon
  signed-rank; for three or more occasions, repeated-measures ANOVA
  unless marked skewness is flagged, then Friedman test.
  Repeated-measures ANOVA reports a conservative
  Greenhouse-Geisser-corrected p-value.

- **Independent ordinal, binary, or nominal categorical outcome:**
  Pearson chi-square test when no expected count is below 1 and no more
  than 20% are below 5; Fisher's exact test otherwise (Monte Carlo
  p-value for larger tables). This compares the distribution of all
  levels, which is the usual Table 1 question. Use an explicit rank test
  (`"wilcox"` or `"kruskal"`) when the ordered scale itself is the
  intended estimand.

- **Paired ordinal outcome:** Wilcoxon signed-rank for two occasions;
  Friedman for three or more paired occasions.

- **Paired binary outcome:** McNemar test for two occasions; Cochran's Q
  test for three or more occasions.

Distribution guidance uses the package's skewness assessment within each
group (or within-pair differences). Shapiro-Wilk is supporting
information; it does not by itself change the selected test. Automatic
decisions, the values used, and the selected method are retained in
`$method`, `$diagnostics`, and `$notes`.

For independent continuous comparisons, `$diagnostics` also reports the
observed standard deviation and variance ratios across groups. These are
descriptive context only: they have no pass/fail threshold and do not
alter automatic test selection. `var_equal` is a user-specified
analytical assumption, not a variance hypothesis test: gtstats never
infers it using Levene, Bartlett, or F tests. Welch t-tests and Welch
ANOVA are the conservative defaults because they do not require equal
variances.

When `effect_size = TRUE`, the function selects an effect size from the
comparison structure:

- Hedges' g for two-group parametric comparisons

- rank-biserial correlation for two-group rank comparisons

- omega-squared for ANOVA or Welch ANOVA

- epsilon-squared for Kruskal-Wallis comparisons

- Cramer's V for categorical contingency tables

Hedges' g is accompanied by a large-sample confidence interval. Other
effect-size intervals are omitted unless a supported interval method is
available. Conventional magnitude labels are retained in `inferential`
for teaching but are not displayed as clinical importance thresholds.

## Examples

``` r
compare_groups(mtcars, variable = mpg, group = am)

compare_groups(
  mtcars,
  variable = mpg,
  group = am,
  effect_size = TRUE
)

compare_groups(
  mtcars,
  variable = vs,
  group = am,
  test = "chisq",
  effect_size = TRUE
)

compare_groups(
  mtcars,
  variable = mpg,
  group = am,
  paired = FALSE,
  test = "welch_t"
)

compare_groups(mtcars, variable = mpg, group = am, var_equal = TRUE)

tbl_stats(compare_groups(mtcars, variable = mpg, group = am))


  

Variable
```
