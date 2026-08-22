# Estimate an effect size

Quantify the magnitude of a group difference or association without
adding the full hypothesis-test output produced by
[`compare_groups()`](https://gtstats.thinkdenominator.com/reference/compare_groups.md).
For directional two-group measures, the Contrast column names the
grouping variable and reports first group minus second group. Factor
order is therefore meaningful. Cramer's V and omnibus measures have no
direction.

## Usage

``` r
effect_size(
  data,
  variable,
  group,
  method = c("auto", "hedges_g", "rank_biserial", "omega_squared", "epsilon_squared",
    "cramers_v"),
  paired = FALSE,
  id = NULL,
  conf.level = 0.95,
  interpretation = FALSE,
  digits = 2,
  format = c("table", "tibble")
)
```

## Arguments

- data:

  A data frame.

- variable:

  Outcome or response variable.

- group:

  Grouping variable.

- method:

  Effect-size method: `"auto"`, `"hedges_g"`, `"rank_biserial"`,
  `"omega_squared"`, `"epsilon_squared"`, or `"cramers_v"`.

- paired:

  Logical; whether the two-group comparison is paired.

- id:

  Pair or participant identifier required when `paired = TRUE`.

- conf.level:

  Confidence level for supported intervals.

- interpretation:

  Logical; display a conventional magnitude label. These labels are
  generic teaching aids and are not clinical importance thresholds.

- digits:

  Number of decimal places.

- format:

  Output format: `"table"` (default) or a plain console `"tibble"`.

## Value

A publication-ready `gt_effect` object containing `summary`, `table`,
`inputs`, `method`, `assumptions`, `diagnostics`, `denominators`, and
`notes`.

## Details

The default `method = "auto"` selects one measure from the outcome and
comparison structure:

- Hedges' g for two-group parametric comparisons

- rank-biserial correlation for two-group rank comparisons

- omega-squared for comparisons involving more than two continuous
  groups

- epsilon-squared when a multi-group rank method is requested

- Cramer's V for categorical associations

Risk ratios, odds ratios, and risk differences are intentionally not
duplicated here; use
[`crosstabs()`](https://gtstats.thinkdenominator.com/reference/crosstabs.md)
for those epidemiological measures.

## Examples

``` r
effect_size(mtcars, variable = mpg, group = am)

effect_size(
  mtcars,
  variable = mpg,
  group = am,
  method = "hedges_g",
  interpretation = TRUE
)
```
