# Outbreak and surveillance summary table

Build a publication-ready epidemiology table from either individual
line-list records or aggregate numerator/denominator data. Unlike
[`summary_table()`](https://gtstats.thinkdenominator.com/reference/summary_table.md),
this function always makes the event and denominator explicit and always
reports a confidence interval.

## Usage

``` r
epi_table(
  data,
  outcomes = NULL,
  by = NULL,
  event = NULL,
  numerator = NULL,
  denominator = NULL,
  label = NULL,
  person_time = NULL,
  measure = c("proportion", "prevalence", "attack_rate", "incidence_rate"),
  multiplier = NULL,
  ci_method = c("wilson", "exact"),
  conf.level = 0.95,
  p_value = FALSE,
  p_adjust = c("none", "holm", "bonferroni", "BH", "fdr"),
  effects = "none",
  layout = c("auto", "wide", "long"),
  digits = 1,
  format = c("table", "tibble")
)
```

## Arguments

- data:

  A data frame.

- outcomes:

  Line-list outcome variables selected with tidyselect syntax.

- by:

  Optional grouping variable.

- event:

  Event level to count. Supply one value for all outcomes or a named
  vector, for example `c(infected = "Yes", admitted = "Yes")`.

- numerator, denominator:

  Aggregate count and denominator columns. For an incidence rate,
  `denominator` is accumulated person-time.

- label:

  Optional aggregate outcome-label column or a single text label.

- person_time:

  Optional line-list person-time column. Required when
  `measure = "incidence_rate"`.

- measure:

  One of `"proportion"`, `"prevalence"`, `"attack_rate"`, or
  `"incidence_rate"`.

- multiplier:

  Scale used for estimates. Defaults to 100 for proportions, prevalence
  and attack rates, and 1,000 for incidence rates.

- ci_method:

  Binomial interval method: `"wilson"` or `"exact"`. Incidence rates
  always use an exact Poisson interval.

- conf.level:

  Confidence level.

- p_value:

  Add an association/rate-comparison p-value when `by` is used.

- p_adjust:

  Optional multiplicity adjustment passed to
  [`stats::p.adjust()`](https://rdrr.io/r/stats/p.adjust.html).

- effects:

  Optional two-group effect measures. Use `"none"` (default), `"all"`,
  or any of `"rr"`, `"rd"`, and `"or"`. Incidence-rate tables support
  `"irr"`.

- layout:

  `"auto"`, `"wide"`, or `"long"`. Auto uses wide output for four or
  fewer groups and long output otherwise.

- digits:

  Number of decimal places.

- format:

  `"table"` (default) or `"tibble"`.

## Value

A `gt_epi_table` object containing `$summary`, `$table`,
`$denominators`, `$p_values`, `$effects`, `$inputs`, and `$notes`.

## Examples

``` r
epi_table(
  birthwt, outcomes = low, by = smoke,
  event = "Low birth weight", measure = "prevalence"
)

aggregate_data <- data.frame(
  ward = c("A", "B"), cases = c(12, 7), population = c(80, 65)
)
epi_table(
  aggregate_data, numerator = cases, denominator = population,
  by = ward, label = "Influenza", measure = "attack_rate"
)
```
